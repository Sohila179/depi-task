
/*
1.Write a query that classifies all products into price categories:

Products under $300: "Economy"
Products $300-$999: "Standard"
Products $1000-$2499: "Premium"
Products $2500 and above: "Luxury"
*/
select product_name,list_price,
case
    when list_price<300 then 'Economy' 
    when list_price between 299 and 1000 then 'Standard'
    when list_price between 1000 and 2500 then 'Premium'
    when list_price >2500 then 'Luxury'
end as price_category
from production.products

/*
2.Create a query that shows order processing information with user-friendly status descriptions:

Status 1: "Order Received"
Status 2: "In Preparation"
Status 3: "Order Cancelled"
Status 4: "Order Delivered"
Also add a priority level:

Orders with status 1 older than 5 days: "URGENT"
Orders with status 2 older than 3 days: "HIGH"
All other orders: "NORMAL"
*/
select order_id,order_status,
case 
    when order_status=1 and DATEDIFF(DAY, order_date, GETDATE()) > 5 THEN 'URGENT'
    when order_status=2 and DATEDIFF(DAY, order_date, GETDATE()) > 3  then 'HIGH'
    else  'NORMAL'
end as order_processing_information
from sales.orders

/*
3.Write a query that categorizes staff based on the number of orders they've handled:

0 orders: "New Staff"
1-10 orders: "Junior Staff"
11-25 orders: "Senior Staff"
26+ orders: "Expert Staff"
*/
select s.staff_id,count(order_id) as orders_staff ,
case 
    when count(order_id)=0 then 'New Staff'
    when count(order_id) in(1,10) then 'Junior Staff'
    when count(order_id) in(11,25) then 'Senior Staff'
    when count(order_id) > 26 then 'Expert Staff'
end as categorizes_staff
from sales.orders o join sales.staffs s
on s.staff_id=o.staff_id
group by s.staff_id

/*
4.Create a query that handles missing customer contact information:

Use ISNULL to replace missing phone numbers with "Phone Not Available"
Use COALESCE to create a preferred_contact field (phone first, then email, then "No Contact Method")
Show complete customer information
*/
select  first_name,last_name,ISNULL(phone,'Phone Not Available') as phone ,coalesce(phone,email,'No Contact Method') as preferred_contact 
from sales.customers

/*
5.Write a query that safely calculates price per unit in stock:

Use NULLIF to prevent division by zero when quantity is 0
Use ISNULL to show 0 when no stock exists
Include stock status using CASE WHEN
Only show products from store_id = 1
*/

select s.product_id,product_name,quantity ,list_price AS unit_price, 
ISNULL(s.quantity * p.list_price, 0) AS total_stock_value, 
    CASE 
        WHEN s.quantity = 0 THEN 'Out of Stock'
        WHEN s.quantity < 10 THEN 'Low Stock'
        ELSE 'In Stock'
    END AS stock_status
from production.products p join production.stocks  s
on s.product_id=p.product_id
where s.store_id =1


/*
6.Create a query that formats complete addresses safely:

Use COALESCE for each address component
Create a formatted_address field that combines all components
Handle missing ZIP codes gracefully
*/
select first_name,last_name , 
CONCAT( COALESCE(zip_code, '---'), ' , ',COALESCE(state, '---'), ' , ', COALESCE(city, '--') ) AS address 
from  sales.customers

/*
7.Use a CTE to find customers who have spent more than $1,500 total:

Create a CTE that calculates total spending per customer
Join with customer information
Show customer details and spending
Order by total_spent descending
*/
WITH t AS (
  SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(oi.quantity * oi.list_price * (1-oi.discount)) AS total_discount
  FROM sales.customers c
  JOIN sales.orders o ON c.customer_id = o.customer_id
  JOIN sales.order_items oi ON o.order_id = oi.order_id 
  GROUP BY c.customer_id, c.first_name, c.last_name,o.order_id
)
select * from t
where total_discount>1500
order by total_discount desc ;


/*
8.Create a multi-CTE query for category analysis:

CTE 1: Calculate total revenue per category
CTE 2: Calculate average order value per category
Main query: Combine both CTEs
Use CASE to rate performance: >$50000 = "Excellent", >$20000 = "Good", else = "Needs Improvement"
*/
with cte1 as (
select c.category_id,sum(oi.list_price*oi.quantity*(1-oi.discount)) as total from production.products p 
join production.categories c on c.category_id=p.category_id 
JOIN sales.order_items oi ON p.product_id = oi.product_id 
group by c.category_id
)
,
 cte2 as (
select cte1.category_id,avg(total) as _avg from cte1
group by cte1.category_id
)
,
main_cte as(
select cte1.category_id,cte1.total,cte2._avg,
CASE
  WHEN total > 50000 THEN 'Excellent'
  WHEN total > 20000 THEN 'Good'
  ELSE 'Needs Improvement'
END AS performance
from cte1,cte2
)
select * from main_cte

/*
9.Use CTEs to analyze monthly sales trends:

CTE 1: Calculate monthly sales totals
CTE 2: Add previous month comparison
Show growth percentage
*/
with cte1 as (
select month(o.order_date) as month_number,sum(oi.list_price*oi.quantity*(1-oi.discount)) as total from sales.orders o
join sales.order_items oi on o.order_id=oi.order_id
group by month(order_date)
)
,cte2 as(
 select *,LAG(total) OVER (ORDER BY month_number) AS prev_month_sales from cte1
)
,
cte as (
select *,total- isnull(prev_month_sales,0) as diff ,total- isnull(prev_month_sales,0)/nullif(prev_month_sales,0) *100 as percent_ from cte2 
)
select * from cte 

/*
10.Create a query that ranks products within each category:

Use ROW_NUMBER() to rank by price (highest first)
Use RANK() to handle ties
Use DENSE_RANK() for continuous ranking
Only show top 3 products per category
*/
select  *
from (
select p.* ,
rank() over(order by list_price desc) as rank_,
ROW_NUMBER() over(PARTITION BY c.category_id order by list_price desc) as ROW_NUMBER_,
DENSE_RANK() over(PARTITION BY c.category_id order by list_price desc) as DENSE_RANK_
from production.products p join production.categories c on c.category_id=p.category_id 
) as new
where ROW_NUMBER_<=3 
ORDER BY category_id, ROW_NUMBER_;
/*
11.Rank customers by their total spending:

Calculate total spending per customer
Use RANK() for customer ranking
Use NTILE(5) to divide into 5 spending groups
Use CASE for tiers: 1="VIP", 2="", 3="Silver", 4="Bronze", 5="Standard"
*/
select *,
rank() over(order by total ),
NTILE(5) over(order by total ) as n,
case
    when NTILE(5) over(order by total )=1 then 'VIP'
    when NTILE(5) over(order by total )=2 then 'Gold'
    when NTILE(5) over(order by total )=3 then 'Silver'
    when NTILE(5) over(order by total )=4 then 'Bronze'
    when NTILE(5) over(order by total )=5 then 'Standard'
end  as  CASE_for_tiers
from
 (SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(oi.quantity * oi.list_price * (1-oi.discount)) AS total
  FROM sales.customers c
  JOIN sales.orders o ON c.customer_id = o.customer_id
  JOIN sales.order_items oi ON o.order_id = oi.order_id 
  GROUP BY c.customer_id, c.first_name, c.last_name,o.order_id
  ) as new 
/*
12.Create a comprehensive store performance ranking:

Rank stores by total revenue
Rank stores by number of orders
Use PERCENT_RANK() to show percentile performance
*/
select table_.*,
rank() over( order by total_revenue desc) as Rank_,
rank() over( order by number_orders desc) as Rank1,
PERCENT_RANK() OVER (ORDER BY total_revenue DESC) AS revenue_percentile
from
(select s.store_id,sum(quantity*list_price*(1-discount))as total_revenue ,count(o.order_id)  as number_orders
from sales.stores  s
join sales.orders o on s.store_id=o.store_id
join sales.order_items oi on o.order_id=oi.order_id
group by s.store_id
) as table_

/*
13.Create a PIVOT table showing product counts by category and brand:

Rows: Categories
Columns: Top 4 brands (Electra, Haro, Trek, Surly)
Values: Count of products
*/
select * from(
select  category_name,brand_name,p.product_id from production.products p
join production.brands b on b.brand_id =p.brand_id
join production.categories c on c.category_id=p.category_id)
t pivot (
COUNT(product_id)
 for brand_name in (
    ['Electra'], ['Haro'], ['Trek'], ['Surly']
 )
) as pivot_table;

/*
14.Create a PIVOT showing monthly sales revenue by store:

Rows: Store names
Columns: Months (Jan through Dec)
Values: Total revenue
Add a total column
*/
SELECT *
FROM (
  SELECT 
    DATENAME(MONTH, o.order_date) AS month_name,
    s.store_name,
    oi.quantity * oi.list_price * (1 - oi.discount) AS total
  FROM sales.orders o
  JOIN sales.order_items oi ON o.order_id = oi.order_id
  JOIN sales.stores s ON o.store_id = s.store_id
  WHERE s.store_name IN (
    'Manhattan Fifth Avenue Flagship',
    'Beverly Hills Rodeo Drive',
    'Chicago Magnificent Mile',
    'Miami Design District',
    'Boston Newbury Street',
    'San Francisco Union Square',
    'Seattle Downtown',
    'Las Vegas Forum Shops',
    'Atlanta Buckhead',
    'Dallas NorthPark Center',
    'Houston Galleria',
    'Denver Cherry Creek',
    'Phoenix Scottsdale Fashion Square',
    'Orlando Mall at Millenia',
    'Digital Commerce Center'
  )
) AS source_table
PIVOT (
  SUM(total)
  FOR store_name IN (
    [Manhattan Fifth Avenue Flagship],
    [Beverly Hills Rodeo Drive],
    [Chicago Magnificent Mile],
    [Miami Design District],
    [Boston Newbury Street],
    [San Francisco Union Square],
    [Seattle Downtown],
    [Las Vegas Forum Shops],
    [Atlanta Buckhead],
    [Dallas NorthPark Center],
    [Houston Galleria],
    [Denver Cherry Creek],
    [Phoenix Scottsdale Fashion Square],
    [Orlando Mall at Millenia],
    [Digital Commerce Center]
  )
) AS pivot_table;

/*
15.PIVOT order statuses across stores:

Rows: Store names
Columns: Order statuses (Pending, Processing, Completed, Rejected)
Values: Count of orders
*/
select * from(
select store_name, o.order_status,o.order_id  as number_orders,
 CASE o.order_status
    WHEN 1 THEN 'Order Received'
    WHEN 2 THEN 'In Preparation'
    WHEN 3 THEN 'Order Cancelled'
    WHEN 4 THEN 'Order Delivered'
    ELSE 'Unknown'
  END AS status_text
from sales.stores  s
join sales.orders o on s.store_id=o.store_id
join sales.order_items oi on o.order_id=oi.order_id
) t 
pivot(
count(number_orders) 
FOR store_name IN (
    [Manhattan Fifth Avenue Flagship],
    [Beverly Hills Rodeo Drive],
    [Chicago Magnificent Mile],
    [Miami Design District],
    [Boston Newbury Street],
    [San Francisco Union Square],
    [Seattle Downtown],
    [Las Vegas Forum Shops],
    [Atlanta Buckhead],
    [Dallas NorthPark Center],
    [Houston Galleria],
    [Denver Cherry Creek],
    [Phoenix Scottsdale Fashion Square],
    [Orlando Mall at Millenia],
    [Digital Commerce Center]
  )
) as pivot_
/*
16.Create a PIVOT comparing sales across years:

Rows: Brand names
Columns: Years (2016, 2017, 2018)
Values: Total revenue
Include percentage growth calculations
*/

SELECT *
FROM (
  SELECT 
    year (o.order_date) as years,
    b.brand_name,
    oi.quantity * oi.list_price * (1 - oi.discount) AS total
  FROM sales.orders o
  JOIN sales.order_items oi ON o.order_id = oi.order_id
  join production.products p on p.product_id=oi.product_id
  JOIN production.brands b ON b.brand_id=p.brand_id

) AS source_table1
PIVOT (
  SUM(total) for years in ( [2016],[2017],[2022])
) AS pivot_table;

/*
17.Use UNION to combine different product availability statuses:

Query 1: In-stock products (quantity > 0)
Query 2: Out-of-stock products (quantity = 0 or NULL)
Query 3: Discontinued products (not in stocks table)
*/
select product_name,quantity from production.products p join production.stocks s on s.product_id=p.product_id 
where quantity>0
union 
select product_name,quantity from production.products p join production.stocks s on s.product_id=p.product_id 
where quantity is null or quantity =0
union 
select product_name,quantity from production.products p left  join production.stocks s on s.product_id=p.product_id
WHERE s.product_id IS NULL

/*
18.Use INTERSECT to find loyal customers:

Find customers who bought in both 2017 AND 2018
Show their purchase patterns
*/
select  c.customer_id from sales.customers c
join sales.orders o on c.customer_id=o.customer_id 
WHERE YEAR(order_date) = 2017

INTERSECT
select customer_id from sales.orders
where year(order_date) =2018
/*
19.Use multiple set operators to analyze product distribution:

INTERSECT: Products available in all 3 stores
EXCEPT: Products available in store 1 but not in store 2
UNION: Combine above results with different labels
*/
(select  p.product_name from sales.orders o join sales.order_items oi on o.order_id=oi.order_id
join production.products p on p.product_id =oi.product_id
where o.store_id=1
INTERSECT
select  p.product_name from sales.orders o join sales.order_items oi on o.order_id=oi.order_id
join production.products p on p.product_id =oi.product_id
where o.store_id=2
INTERSECT
select  p.product_name from sales.orders o join sales.order_items oi on o.order_id=oi.order_id
join production.products p on p.product_id =oi.product_id
where o.store_id=3)
union
(select  p.product_name from sales.orders o join sales.order_items oi on o.order_id=oi.order_id
join production.products p on p.product_id =oi.product_id
where store_id=1
EXCEPT
select  p.product_name from sales.orders o join sales.order_items oi on o.order_id=oi.order_id
join production.products p on p.product_id =oi.product_id
where store_id=2
)
/*
20.Complex set operations for customer retention:

Find customers who bought in 2016 but not in 2017 (lost customers)
Find customers who bought in 2017 but not in 2016 (new customers)
Find customers who bought in both years (retained customers)
Use UNION ALL to combine all three groups
*/
(select c.customer_id,first_name from sales.customers c join sales.orders o on c.customer_id=o.customer_id 
where year(order_date)=2016
EXCEPT
select c.customer_id,first_name from sales.customers c join sales.orders o on c.customer_id=o.customer_id 
where year(order_date)=2017)
UNION ALL
(select c.customer_id,first_name from sales.customers c join sales.orders o on c.customer_id=o.customer_id 
where year(order_date)=2017
EXCEPT
select c.customer_id,first_name from sales.customers c join sales.orders o on c.customer_id=o.customer_id 
where year(order_date)=2016)
UNION ALL
(select c.customer_id,first_name from sales.customers c join sales.orders o on c.customer_id=o.customer_id 
where year(order_date)=2017
INTERSECT
select c.customer_id,first_name from sales.customers c join sales.orders o on c.customer_id=o.customer_id 
where year(order_date)=2016)

