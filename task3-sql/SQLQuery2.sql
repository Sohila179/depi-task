--1. Count the total number of products in the database.
select count(product_id) as total_product from production.products
--2. Find the average, minimum, and maximum price of all products.
select avg(list_price)as avg_product,min(list_price) as min_product ,max(list_price) as max_product from production.products
--3. Count how many products are in each category.
select category_name,count(product_id) as total_product_cat from production.products p 
inner join production.categories c on c.category_id=p.category_id
group by c.category_id,category_name

select category_id,count(product_id) as total_product_cat from production.products p 
group by category_id

--4. Find the total number of orders for each store.
select  store_name ,COUNT(order_id) as total_order_store from sales.orders o
inner join sales.stores s on s.store_id = o.store_id
group by s.store_id,store_name

select  store_id ,COUNT(order_id) as total_order_store from sales.orders 
group by store_id

--5. Show customer first names in UPPERCASE and last names in lowercase for the first 10 customers.
select top 10 upper(first_name) as first_name,lower(last_name) as last_name from  sales.customers  

--6. Get the length of each product name. Show product name and its length for the first 10 products.
select top 10 product_name,len(product_name) as len_p_name from production.products

--7. Format customer phone numbers to show only the area code (first 3 digits) for customers 1-15.
select top 15 first_name+' '+last_name as full_name ,left(phone,3) as code from sales.customers
where phone is not null
--8. Show the current date and extract the year and month from order dates for orders 1-10.
select  top 10 GETDATE()as currentdate, order_date,year(order_date) as year, month(order_date) as month   from sales.orders
--9. Join products with their categories. Show product name and category name for first 10 products.
select top 10 product_name,category_name from production.products p
inner join production.categories c on c.category_id=p.category_id

--10. Join customers with their orders. Show customer name and order date for first 10 orders.
select top 10  first_name+' '+last_name as full_name,order_date from sales.orders o
inner join sales.customers c on c.customer_id=o.customer_id

--11. Show all products with their brand names, even if some products don't have brands. Include product name, brand name (show 'No Brand' if null).
select product_name,isnull(brand_name,'NO Brand') as brand_name  from production.products p left join production.brands b
on b.brand_id =p.brand_id 

--12. Find products that cost more than the average product price. Show product name and price.
select  product_name,list_price from production.products
where list_price> (select avg(list_price)from production.products)
--13. Find customers who have placed at least one order. Use a subquery with IN. Show customer_id and customer_name.
select customer_id,first_name+' '+last_name as full_name from sales.customers 
where customer_id in (select customer_id from sales.orders)

--14. For each customer, show their name and total number of orders using a subquery in the SELECT clause.
select customer_id,first_name+' '+last_name as full_name ,
(select COUNT(order_id) from sales.orders o WHERE o.customer_id = c.customer_id )  as total_order_customer
from sales.customers c 

--15. Create a simple view called easy_product_list that shows product name, category name, and price. Then write a query to select all products from this view where price > 100.
create view easy_product_list as
select product_name,category_name,list_price from production.products p inner join production.categories c on c.category_id =p.category_id
select * from easy_product_list where list_price>100

--16. Create a view called customer_info that shows customer ID, full name (first + last), email, and city and state combined. Then use this view to find all customers from California (CA).
create view customer_info as 
select customer_id,first_name+' '+last_name as full_name ,email,city+', '+state as location from sales.customers
select * from customer_info where right(location,2)='ca' or location like '%ca'

--17. Find all products that cost between $50 and $200. Show product name and price, ordered by price from lowest to highest.
select product_name,list_price from production.products 
where list_price between 50 and 200
order by list_price
--18. Count how many customers live in each state. Show state and customer count, ordered by count from highest to lowest.
select state,COUNT(customer_id) as total_customer from sales.customers 
group by state
order by total_customer desc

--19. Find the most expensive product in each category. Show category name, product name, and price.
SELECT 
  c.category_name,
  p.product_name,
  p.list_price
FROM production.categories c
CROSS APPLY (
  SELECT TOP 1 product_name, list_price
  FROM production.products
  WHERE category_id = c.category_id
  ORDER BY list_price DESC
) p;

--20. Show all stores and their cities, including the total number of orders from each store. Show store name, city, and order count.
SELECT s.store_name, s.city,  COUNT(o.order_id) AS order_count
FROM sales.stores s
LEFT JOIN sales.orders o ON s.store_id = o.store_id
GROUP BY s.store_id,s.store_name, s.city;
