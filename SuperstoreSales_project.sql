---										 DATA CLEANING

-- First we making the primary key of OrderID from OrderList
-- because OrderID is null right now so first we make OrderID is not null

ALTER TABLE OrdersList
alter column OrderID nvarchar (255) not null

ALTER TABLE OrdersList
add constraint PK_OrderID primary key (OrderID)

-- Now we making Foregin key of OrderID from EachOrderBreakdown
-- because OrderID is null right now so first we make OrderID is not null

ALTER TABLE EachOrderBreakdown
alter column OrderID nvarchar (255) not null

-- Q1: Establish the relationship between the tables as per the ER diagram.

ALTER TABLE EachOrderBreakdown
add constraint FK_OrderID Foreign key (OrderID) references OrdersList(OrderID)	


-- Q2: Split City , State and Country into 3 individual columns namely 'City', 'State' and 'Country'.

ALTER TABLE OrdersList
ADD City nvarchar(255),
	State nvarchar(255),
	Country nvarchar(255);

UPDATE OrdersList
SET City = PARSENAME(REPLACE([City State Country],',','.'),3),
	State = PARSENAME(REPLACE([City State Country],',','.'),2),
	Country = PARSENAME(REPLACE([City State Country],',','.'),1);

-- now we are dropping City State Country column from table


ALTER TABLE OrdersList
drop column [City State Country];

-- Add a new Category Column using the following mapping as per the first 3 Characters in the 
--- Product name column;
--	a) TEC- Technology
--	b) OFS- Office Supplies
--	c) FUR- Furniture

ALTER TABLE EachOrderBreakdown
ADD Category nvarchar(255)

UPDATE EachOrderBreakdown
SET Category = CASE WHEN LEFT(ProductName,3) = 'OFS' THEN 'Office Supplies'
					WHEN LEFT(ProductName,3) = 'TEC' THEN 'Technology'
					WHEN LEFT(ProductName,3) = 'FUR' THEN 'Furniture'

				END;

SELECT * FROM 
EachOrderBreakdown

-- Q4: DELETE THE FIRST 4 CHARACTERS FROM THE ProductName Column.

UPDATE EachOrderBreakdown 
SET ProductName = SUBSTRING(ProductName,5,LEN(ProductName)-4)

-- Q5: Remove Duplicate rows from EachOrderBrealdown table, if all column values are matching.

WITH CTE AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY OrderID, ProductName, Discount, Sales, Profit, Quantity, SubCategory, Category
							ORDER BY OrderID) as Row_no
		From EachOrderBreakdown
)
DELETE FROM CTE
WHERE Row_no > 1

--- Q6: Replace blank with NA in OrderPriority Column in OrderList table.

UPDATE OrdersList
SET OrderPriority = 'NA'
WHERE OrderPriority = 'NULL';

-------------------------------------------------	  DATA EXPLORATION      -------------------------------------------------------

------------------------ BEGINNER

--Q1: List the top 10 Orders with the heighest sales from the EachOrderBreakdown table.

 select  TOP 10 *
 from EachOrderBreakdown
 ORDER BY Sales DESC

 -- Q2: Show the number of Orders from each Product Category in the EachOrderBreakdown table .

 select Category, COUNT(*) AS Num_of_Orders
 from EachOrderBreakdown
 group by Category
 order by Num_of_Orders desc

 -- Q3: Find the total profit for each sub-category in the EachOrderBreakdown table.

 select SubCategory, SUM(Profit) as total_Profit
 from EachOrderBreakdown
 group by SubCategory
 order by total_Profit desc


 ---------------------------------------- INTERMEDIATE -----------------------------------------------

 -- Q1: Identify the customer with the highest total sales across all orders.

 select top 1 CustomerName, SUM(sales) as total_Sales
 from OrdersList Or_L
 join EachOrderBreakdown Eob
 on Or_L.OrderID = Eob.OrderID
 group by CustomerName
 order by total_Sales desc

 -- Q2: Find the month with the highest average sales in the OrdersList table.

 select top 1 MONTH(OrderDate) as Month , AVG(Sales) as Avg_sales 
 from OrdersList Or_L
 join EachOrderBreakdown Eob
 on Or_L.OrderID = Eob.OrderID
 group by MONTH(OrderDate)
 order by Avg_sales desc

 -- Q3: Find out the average quantity ordered by customers whose first name starts with alphabet "s"?

 select AVG(Quantity) as Avg_Quantity
 from OrdersList Or_L 
 join EachOrderBreakdown Eob
 on Or_L.OrderID = Eob.OrderID
 where CustomerName like 'S%'

 ------------------------------------------- Another way to solve above question ---------------------------------------------

 
 select AVG(Quantity) as Avg_Quantity
 from OrdersList Or_L 
 join EachOrderBreakdown Eob
 on Or_L.OrderID = Eob.OrderID
 where Left(CustomerName,1) = 'S'

 ---------------------------------------------- ADVANCED ------------------------ADVANCED-----------------------------------------------

 -- Q1: Find out how many new customers were acquried in the year 2014 ?

 select COUNT(*) as Num_of_New_Customer 
 from (
		select CustomerName, MIN(OrderDate) as First_Order_Date
		from OrdersList
		group by CustomerName
		Having YEAR(MIN(OrderDate)) = '2014'
	   ) as Cus_with_First_Order_2014

 -- Q2: Calculate the percentage of total profit contributed by each sub_category to the overall profit.

 select SubCategory, SUM(profit) as SubCategory_profit,
 SUM(profit)/(select SUM(profit) from EachOrderBreakdown) * 100 as Per_of_totalProfit_contribution
 from EachOrderBreakdown
 group by SubCategory


 -- Q3: Find the average sales per customer, considering only customers who have made more than one order.

 with Cus_Avg_sales as (
		 select CustomerName, AVG(sales)as Avg_sales, COUNT(distinct Or_L.OrderID) as Num_Of_Orders 
		 from OrdersList Or_L
		 join EachOrderBreakdown Eob
		 on Or_L.OrderID = Eob.OrderID
		 group by CustomerName
								)
select CustomerName, Avg_sales , Num_Of_Orders
from Cus_Avg_sales
where Num_Of_Orders > 1


 -- Q4: Identify the top perfrming sub_category in each category based on total sales.
 --- Include the sub_category name, total sales and a ranking of sub_catoegory within each category.

 select Category, SubCategory, SUM(sales) as total_sales,
 RANK() over(Partition by category order by sum(sales) desc) as SubCategory_Rank
 from EachOrderBreakdown
 group by Category, SubCategory


------------------------------------ANOTHER WAY ------------------------- ANOTHER WAY-------------------------------------
WITH Topsubcategory as (
 select Category, SubCategory, SUM(sales) as total_sales,
 RANK() over(Partition by category order by sum(sales) desc) as SubCategory_Rank
 from EachOrderBreakdown
 group by Category, SubCategory
 )
 select * 
 From Topsubcategory
 where SubCategory_Rank = 1
















       
