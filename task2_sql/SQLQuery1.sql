--1-List all products with list price greater than 1000
select product_id,product_name,list_price from production.products where list_price>1000
--2-Get customers from "CA" or "NY" states
select customer_id,first_name+' '+last_name as full_name,state from sales.customers
where state ='CA' or state = 'NY'
--3-Retrieve all orders placed in 2023
select order_id ,order_date from sales.orders where year(order_date)=2023
--4-Show customers whose emails end with @gmail.com
select customer_id,first_name+' '+last_name as full_name,email from sales.customers
where email like '%@gmail.com'
--5-Show all inactive staff
select * from sales.staffs where active =0
--6-List top 5 most expensive products
select top 5 product_id,product_name,list_price from production.products order by list_price desc
--7-Show latest 10 orders sorted by date
select top 10 order_id ,order_date from sales.orders order by order_date desc
--8-Retrieve the first 3 customers alphabetically by last name
select top 3 customer_id,first_name,last_name from sales.customers  order by last_name 
--9-Find customers who did not provide a phone number
select customer_id,first_name,last_name,phone from sales.customers  where phone is null or phone =''
--10-Show all staff who have a manager assigned
select staff_id,first_name+' '+last_name as full_name,manager_id from sales.staffs where manager_id is not  null
--11-Count number of products in each category
select category_id,count(product_id) from production.products
group by category_id
--12-Count number of customers in each state
select state,count(customer_id)  from sales.customers
group by state
--13-Get average list price of products per brand
select brand_id, avg(list_price) from production.products
group by brand_id
order by avg(list_price)

select brand_name, avg(list_price) from production.products p
inner join production.brands b on b.brand_id =p.brand_id
group by b.brand_name
order by avg(list_price)
--14-Show number of orders per staff
select staff_id,count(order_id) from sales.orders
group by staff_id

select s.first_name,s.last_name,count(order_id) from sales.orders o
inner join sales.staffs s on s.staff_id =o.staff_id
group by s.first_name,s.last_name


--15-Find customers who made more than 2 orders
select customer_id,count(order_id) from sales.orders
group by customer_id
having count(order_id)>2
--16-Products priced between 500 and 1500
select product_id,product_name,list_price from production.products where list_price between 500 and 1500
--17-Customers in cities starting with "S"
select customer_id,first_name+' '+last_name as full_name,city from sales.customers
where city like 'S%'
--18-Orders with order_status either 2 or 4
select order_id ,order_status from sales.orders where order_status=2 or order_status=4
--19-Products from category_id IN (1, 2, 3)
select product_id,product_name,category_id from production.products where category_id IN (1, 2, 3)

--20-Staff working in store_id = 1 OR without phone number
select staff_id,first_name+' '+last_name as full_name,store_id,phone from sales.staffs where phone is null or store_id=1
