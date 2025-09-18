/*
1. Customer Spending Analysis#
Write a query that uses variables to find the total amount spent by customer ID 1. 
Display a message showing whether they are a VIP customer (spent > $5000) or regular customer.
*/

declare @x int 
select @x=sum(total) from(
select c.customer_id, sum(quantity*list_price*1-discount) as total from sales.customers c 
join sales.orders o on c.customer_id=o.customer_id
join  sales.order_items oi on o.order_id=oi.order_id
where c.customer_id=1
group by o.order_id ,c.customer_id
) as t
group by t.customer_id
if @x >5000
   print'VIP customer'
else
   print'regular customer' 

/*
2. Product Price Threshold Report#
Create a query using variables to count how many products cost more than $1500. 
Store the threshold price in a variable and display both the threshold and count in a formatted message.
*/
declare @x int
select @x=count(p.product_id)   from production.products p
where list_price>1500
PRINT 'Threshold: 1500'  + ' | Count: ' +cast(@x as varchar);
/*
3. Staff Performance Calculator#
Write a query that calculates the total sales for staff member ID 2 in the year 2017. 
Use variables to store the staff ID, year, and calculated total. Display the results with appropriate labels.
*/
declare @id int =2
declare @year int =2017
declare @total int 
select @total=sum(total)  from (
select s.staff_id,o.order_id,sum(list_price*quantity*(1-discount))as total from sales.staffs s
join sales.orders o on s.staff_id= o.staff_id
join sales.order_items oi on o.order_id=oi.order_id
where year(order_date)=@year and s.staff_id=@id 
group by s.staff_id,o.order_id
) t
SELECT 
    @id AS [Staff ID],
    @year AS [Year],
    @total AS [Total Sales];

/*
4. Global Variables Information#
Create a query that displays the current server name, SQL Server version, 
and the number of rows affected by the last statement. 
Use appropriate global variables.
*/
SELECT @@SERVERNAME AS server_name,@@VERSION AS sql_version,@@ROWCOUNT AS last_rowcount

/*
5.Write a query that checks the inventory level for product ID 1 in store ID 1.
Use IF statements to display different messages based on stock levels:#
If quantity > 20: Well stocked
If quantity 10-20: Moderate stock
If quantity < 10: Low stock - reorder needed
*/ 
declare @stok_level varchar(50)
declare @quan int 
select @quan=quantity from production.products p 
join production.stocks s on p.product_id=s.product_id
where p.product_id=1 and s.store_id=1
if @quan>20
   set @stok_level='Well stocked'
else if @quan between 9 and 21
     set @stok_level='Moderate stock'
else 
    set @stok_level='Low stock - reorder needed'
print 'stock levels '+@stok_level

/*
6.Create a WHILE loop that updates low-stock items (quantity < 5) in batches of 3 products at a time. 
Add 10 units to each product and display progress messages after each batch.
*/
DECLARE @batch_size INT = 3;
DECLARE @rows_updated INT = 1;

WHILE @rows_updated > 0

BEGIN

    UPDATE TOP (@batch_size) production.stocks
    SET quantity = quantity + 10
    WHERE quantity < 5;

    SET @rows_updated = @@ROWCOUNT;

    PRINT 'Updated ' + CAST(@rows_updated AS VARCHAR(10)) + ' records';
END

/*
7. Product Price Categorization#
Write a query that categorizes all products using CASE WHEN based on their list price:
Under $300: Budget
$300-$800: Mid-Range
$801-$2000: Premium
Over $2000: Luxury
*/

select product_name,list_price,
case
    when list_price<300 then 'Budget' 
    when list_price between 299 and 801 then 'Mid-Range'
    when list_price between 800 and 2001 then 'Premium'
    when list_price >2000 then 'Luxury'
end as price_category
from production.products

/*
8. Customer Order Validation#
Create a query that checks if customer ID 5 exists in the database. 
If they exist, show their order count. If not, display an appropriate message.
*/

DECLARE @customer_id INT = 5;
IF EXISTS (SELECT 1 FROM sales.customers WHERE customer_id = @customer_id)
    BEGIN
           select customer_id,COUNT(order_id) as order_count  from sales.orders
           WHERE customer_id = @customer_id
           group by customer_id

     END
ELSE
   BEGIN
       PRINT 'Customer not found. Please create customer record first.';
   END
/*
9. Shipping Cost Calculator Function#
Create a scalar function named CalculateShipping that takes an order total as input and returns shipping cost:
Orders over $100: Free shipping ($0)
Orders $50-$99: Reduced shipping ($5.99)
Orders under $50: Standard shipping ($12.99)
*/

CREATE FUNCTION dbo.CalculateShipping (@total DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @shipping DECIMAL(10,2);

    IF @total > 100
        SET @shipping = 0.00;
    ELSE IF @total >= 50 AND @total < 100
        SET @shipping = 5.99;
    ELSE
        SET @shipping = 12.99;

    RETURN @shipping;
END;
GO
declare @id int =11
declare @total decimal(10,2) 
select  @total=sum(list_price*quantity*(1-discount)) from sales.orders o join sales.order_items oi
on o.order_id=oi.order_id
where o.order_id=@id
group by o.order_id
SELECT dbo.CalculateShipping(@total) AS ShippingCost
/*
10. Product Category Function#
Create an inline table-valued function named GetProductsByPriceRange that accepts minimum and maximum price parameters and 
returns all products within that price range with their brand and category information.
*/
CREATE FUNCTION GetProductsByPriceRange (@max decimal(10,2),@mn decimal(10,2))
RETURNS TABLE
AS
RETURN
(
select * from(
select product_name,b.brand_name,c.category_name,(oi.list_price*(1-discount))as price 
from  production.products p  join production.brands b on b.brand_id=p.brand_id
join production.categories c on c.category_id=p.category_id
join sales.order_items oi on p.product_id=oi.product_id ) t
where price >@mn and price <@max 
);
go
declare @max decimal(10,2),@mn decimal(10,2)
select @max=max(oi.list_price*(1-discount)),@mn=min(oi.list_price*1-discount) from sales.order_items oi
select *from  dbo.GetProductsByPriceRange(@max,@mn)

/*
11. Customer Sales Summary Function#
Create a multi-statement function named GetCustomerYearlySummary that takes a customer ID and 
returns a table with yearly sales data including total orders, total spent, and average order value for each year.
*/
create function GetCustomerYearlySummary (@customer_ID int)
returns @summary table 
(
 _year int,
total_orders int 
,total_spent decimal(10,2)
, avrg decimal(10,2)

)
AS
Begin
insert into @summary
select year(o.order_date)as _year,count(o.order_id) as total_orders,sum(oi.list_price*(1-oi.discount)*oi.quantity) as total_spent
,AVG(oi.list_price*(1-oi.discount)*oi.quantity) as avrg 
from sales.orders o join sales.order_items oi on o.order_id=oi.order_id
where o.customer_id=@customer_ID
group by YEAR(o.order_date)

RETURN;
End
go
select * from dbo.GetCustomerYearlySummary(1);
/*
12. Discount Calculation Function#
Write a scalar function named CalculateBulkDiscount that determines discount percentage based on quantity:
1-2 items: 0% discount
3-5 items: 5% discount
6-9 items: 10% discount
10+ items: 15% discount
*/
CREATE FUNCTION CalculateBulkDicount (@p_id int)
RETURNS Decimal(10,2)
AS
BEGIN
 declare @x int ,@total decimal(10,2),@dis decimal(10,2)

 select @x=sum(quantity) from sales.order_items oi
 where oi.product_id=@p_id
 group by quantity
  if @x>0 and @x<3
     set @dis=0
  else if @x>2 and @x<6
     set @dis=0.05
  else if @x>5 and @x<10
      set @dis=0.1
   else 
      set  @dis=0.15
 select @total=sum(list_price*(1-@dis)*quantity) from sales.order_items
 group by product_id
 return @total
END
go 
select dbo.CalculateBulkDicount(11) as total

/*
13. Customer Order History Procedure#
Create a stored procedure named sp_GetCustomerOrderHistory that accepts a customer ID and optional start/end dates.
Return the customer's order history with order totals calculated.
*/

CREATE PROCEDURE sp_GetCustomerOrderHistory
   @customer_id INT,
    @start_date DATE = NULL,
    @end_date DATE = NULL
AS
BEGIN
SELECT o.order_id, o.order_date,o.order_status,SUM(oi.quantity * oi.list_price * (1 - oi.discount)) as order_total
FROM sales.orders o JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE o.customer_id = @customer_id     
AND (@start_date IS NULL OR o.order_date >= @start_date)
AND (@end_date IS NULL OR o.order_date <= @end_date)
GROUP BY o.order_id, o.order_date, o.order_status
ORDER BY o.order_date DESC;
END;
go
EXEC sp_GetCustomerOrderHistory @customer_id = 1;
EXEC sp_GetCustomerOrderHistory @customer_id = 1, @start_date = '2017-01-01';

/*
14. Inventory Restock Procedure#
Write a stored procedure named sp_RestockProduct with input parameters for store ID, product ID, and restock quantity. 
Include output parameters for old quantity, new quantity, and success status.
*/
CREATE PROCEDURE sp__RestockProduct
  @store_ID int, @product_ID int,  @restock_quantity int  
AS
BEGIN
    declare @x int 
select @x=quantity from sales.order_items oi join sales.orders o on o.order_id=oi.order_id  where o.store_id= @store_ID and oi.product_id= @product_ID
  if @x is NULL
      set  @x=0
         return;
select quantity,quantity+@restock_quantity as new_quantity from sales.order_items oi join sales.orders o on o.order_id=oi.order_id
where o.store_id= @store_ID and oi.product_id= @product_ID

END;

exec sp__RestockProduct @store_ID=11, @product_ID=10,  @restock_quantity=50 

/*
15. Order Processing Procedure#
Create a stored procedure named sp_ProcessNewOrder that handles complete order creation with proper transaction control and
error handling. Include parameters for customer ID, product ID, quantity, and store ID.
*/

CREATE PROCEDURE spProcessNewOrder
   @customer_ID  int, @product_ID int , @quantity int ,  @store_ID int
AS
BEGIN

DECLARE @order_id INT;
  BEGIN TRY
      BEGIN TRANSACTION;
        INSERT INTO sales.orders (customer_id, order_status,required_date, order_date, store_id, staff_id)
        VALUES (@customer_ID, 1,GETDATE()+5, GETDATE(), @store_ID, 1);

        SET @order_id = SCOPE_IDENTITY();

        INSERT INTO sales.order_items (order_id, item_id, product_id, quantity, list_price, discount)
        SELECT 
            @order_id,1,  @product_ID,  @quantity,p.list_price,0
        FROM production.products p
        WHERE p.product_id = @product_ID;

        COMMIT TRANSACTION;
        PRINT  CAST(@order_id AS VARCHAR);

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT  ERROR_MESSAGE();
    END CATCH
END;
EXEC spProcessNewOrder  @customer_ID = 1,  @product_ID = 5,  @quantity = 3, @store_ID = 2;

/*
16. Dynamic Product Search Procedure#
Write a stored procedure named sp_SearchProducts that builds dynamic SQL based on optional parameters: 
product name search term, category ID, minimum price, maximum price, and sort column.
*/
CREATE PROCEDURE sp_SearchProducts
    @productName NVARCHAR(100) = NULL,
    @categoryID INT = NULL,
    @minPrice DECIMAL(10,2) = NULL,
    @maxPrice DECIMAL(10,2) = NULL,
    @sortColumn NVARCHAR(50) = 'product_name'
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    SET @sql = N'
    SELECT p.product_id, p.product_name, p.list_price, c.category_name
    FROM production.products p
    JOIN production.categories c ON p.category_id = c.category_id
    WHERE 1=1';

    IF @productName IS NOT NULL
        SET @sql += N' AND p.product_name LIKE ''%' + @productName + '%''';

    IF @categoryID IS NOT NULL
        SET @sql += N' AND p.category_id = ' + CAST(@categoryID AS NVARCHAR);

    IF @minPrice IS NOT NULL
        SET @sql += N' AND p.list_price >= ' + CAST(@minPrice AS NVARCHAR);

    IF @maxPrice IS NOT NULL
        SET @sql += N' AND p.list_price <= ' + CAST(@maxPrice AS NVARCHAR);

    SET @sql += N' ORDER BY ' + QUOTENAME(@sortColumn);

    EXEC sp_executesql @sql;
END;
GO

EXEC sp_SearchProducts @productName = 'zara';

/*
17. Staff Bonus Calculation System#
Create a complete solution that calculates quarterly bonuses for all staff members.
Use variables to store date ranges and bonus rates.
Apply different bonus percentages based on sales performance tiers.
*/
DECLARE @start_date DATE = '2022-01-01';
DECLARE @end_date DATE = '2022-03-31';
declare @total decimal(10,2)
select o.staff_id,
    SUM(oi.list_price * oi.quantity * (1 - oi.discount)) AS total_sales,
    CASE 
        WHEN SUM(oi.list_price * oi.quantity * (1 - oi.discount)) < 10000 THEN SUM(oi.list_price * oi.quantity * (1 - oi.discount)) * 0.05
        WHEN SUM(oi.list_price * oi.quantity * (1 - oi.discount)) BETWEEN 10000 AND 20000 THEN SUM(oi.list_price * oi.quantity * (1 - oi.discount)) * 0.10
        ELSE SUM(oi.list_price * oi.quantity * (1 - oi.discount)) * 0.15
    END AS bonus_amount 
from sales.orders o join sales.order_items oi on o.order_id=oi.order_id
where  o.order_date between  @start_date and @end_date
group by o.staff_id 

/*
18. Smart Inventory Management#
Write a complex query with nested IF statements that manages inventory restocking. 
Check current stock levels and apply different reorder quantities based on product categories and current stock levels.
*/
SELECT p.product_id,p.product_name, c.category_name,
    oi.quantity,
    CASE 
      WHEN oi.quantity < 10 AND c.category_name = 'Women''s T-Shirts & Tops' THEN 50
        WHEN oi.quantity < 20 AND c.category_name = 'Men''s Athletic Shoes' THEN 100
        WHEN oi.quantity < 15 AND c.category_name = 'Women''s Shorts' THEN 30
        ELSE 0
    END AS reorder_quantity
FROM production.products p JOIN production.categories c ON p.category_id = c.category_id
join sales.order_items oi on p.product_id=oi.product_id

/*
19. Customer Loyalty Tier Assignment#
Create a comprehensive solution that assigns loyalty tiers to customers based on their total spending. 
Handle customers with no orders appropriately and use proper NULL checking.
*/
select o.customer_id,
    isnull(SUM(oi.list_price * oi.quantity * (1 - oi.discount)),0) AS total_sales,
    CASE 
        WHEN SUM(oi.list_price * oi.quantity * (1 - oi.discount)) > 10000 THEN 'Platinum'
        WHEN SUM(oi.list_price * oi.quantity * (1 - oi.discount)) BETWEEN 5000 AND 10000 THEN 'Gold'
        WHEN SUM(oi.list_price * oi.quantity * (1 - oi.discount)) BETWEEN 1000 AND 5000 THEN 'Silver'
        WHEN SUM(oi.list_price * oi.quantity * (1 - oi.discount))  BETWEEN 0 AND 1000 THEN 'Bronze'
        ELSE 'No order'
    END AS status
from sales.orders o join sales.order_items oi on o.order_id=oi.order_id
group by o.customer_id 
/*
20. Product Lifecycle Management#
Write a stored procedure that handles product discontinuation including checking for pending orders,
optional product replacement in existing orders, clearing inventory, and providing detailed status messages.
*/
