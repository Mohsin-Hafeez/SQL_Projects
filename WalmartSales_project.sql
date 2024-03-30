----------------- CREATE DATABASE -------------- CREATE DATABASE--------------

Create DATABASE Walmart_SalesData

---------------- DATA CLEANING --------------=--- DATA CLEANING ---------------

SELECT * 
FROM WalmartSalesData

--------------------- SELECTING FIRST 100 ROWS FOR CHECKINGG DATA ---------------------------

SELECT TOP (1000) [Invoice_ID]
      ,[Branch]
      ,[City]
      ,[Customer_type]
      ,[Gender]
      ,[Product_line]
      ,[Unit_price]
      ,[Quantity]
      ,[Tax_5]
      ,[Total]
      ,[Date]
      ,[Time]
      ,[Payment]
      ,[cogs]
      ,[gross_margin_percentage]
      ,[gross_income]
      ,[Rating]
  FROM [Walmart_SalesData].[dbo].[WalmartSalesData]

  ---------------------- ADD THE time_of_day column ---------------------------

  ALTER TABLE WalmartSalesData
  ADD time_of_day VARCHAR(20);


  select * from 
  WalmartSalesData


  SELECT
	Time,
	(CASE
		WHEN Time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN Time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END
	)AS time_of_day
FROM WalmartSalesData


UPDATE WalmartSalesData
SET time_of_day = (CASE
		WHEN Time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN Time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END
	)

------------------------ DAY NAME -----------------------------DAY NAME--------------------------------DAY NAME---------------

SELECT *
FROM WalmartSalesData

ALTER TABLE WalmartSalesData
ADD Day_Name varchar(20)


SELECT Date, DATENAME(DW,Date) as Day_Name
from WalmartSalesData


UPDATE WalmartSalesData
SET Day_Name = DATENAME(Dw,Date)


-----------------------	MONTH NAME----------------------------MONTH NAME--------------MONTH NAME--------------------


ALTER TABLE WalmartSalesData
ADD Month_Name varchar(20)


SELECT DATE , DATENAME(MONTH,Date) AS Month_Name
FROM WalmartSalesData


UPDATE WalmartSalesData
SET Month_Name = DATENAME(MONTH,Date)

SELECT * 
FROM WalmartSalesData

-------------------------- BUSINESS  QUESTION  TO ANSWER ------------------------
----------------------------------------------------------------------------------

------------------------------------- Generic Question ---------------------------

--- Q1: How many unique cities does the data have ?

SELECT DISTINCT(City)
FROM WalmartSalesData

--- Q2: In which city is each branch ?

SELECT DISTINCT(City), Branch
FROM WalmartSalesData
ORDER BY Branch
 
------------------------------- PRODUCT ------------------- PRODUCT ------------------------------
---------------------------------------------------------------------------------------------------

-- Q1: How many unique product lines does the data have?

SELECT DISTINCT(Product_line)
FROM WalmartSalesData

--Q2:  What is the most selling product line

SELECT * 
FROM WalmartSalesData

SELECT Product_line, SUM(Quantity) AS Most_selling_pro
FROM WalmartSalesData
GROUP BY Product_line
ORDER BY Most_selling_pro DESC

--4. What is the total revenue by month?

SELECT Month_Name AS Month, sum(Total)AS Total_revenue
FROM WalmartSalesData
GROUP BY Month_NAme
ORDER BY Total_revenue DESC

--5. What month had the largest COGS?

SELECT Month_Name AS MONTH, SUM(cogs) AS Cogs
FROM WalmartSalesData
GROUP BY Month_Name
ORDER BY cogs DESC


--6. What product line had the largest revenue?

SELECT Product_line, SUM(Total) AS Total_revenue
FROM WalmartSalesData
Group by Product_line
order by Total_revenue DESC

---5. What is the city with the largest revenue?

SELECT City, SUM(Total) AS Total_revenue 
FROM WalmartSalesData
GROUP BY City
ORDER BY Total_revenue DESC

--6. What product line had the largest VAT?

SELECT Product_line, AVG(Tax_5) AS AVG_Tax
FROM WalmartSalesData
GROUP BY Product_line
ORDER BY AVG_Tax DESC


--7. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

SELECT 
	AVG(quantity) AS avg_qnty
FROM WalmartSalesData;

SELECT
	product_line,
	CASE
		WHEN AVG(quantity) >= (SELECT AVG(quantity) AS avg_qnty FROM WalmartSalesData) THEN 'Good'
        ELSE 'Bad'
    END AS remark
FROM WalmartSalesData
GROUP BY product_line;

--8. Which branch sold more products than average product sold?

SELECT 
	branch, 
    SUM(quantity) AS qnty
FROM WalmartSalesData
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM WalmartSalesData);

--9. What is the most common product line by gender?

SELECT Gender, Product_line,
COUNT(Gender) AS Total_count
FROM WalmartSalesData
group by Gender , Product_line
order by Total_count desc

--12. What is the average rating of each product line?

SELECT
	ROUND(AVG(rating), 2) as avg_rating,
    product_line
FROM WalmartSalesData
GROUP BY product_line
ORDER BY avg_rating DESC;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------
-------------- CUSTOMERS ----------------------------- CUSTOMERS ---------------------- CUSTOMERS ------------
-- --------------------------------------------------------------------
-- -------------------------- Customers -------------------------------
-- --------------------------------------------------------------------



--1. How many unique customer types does the data have?

SELECT DISTINCT(Customer_type) 
FROM WalmartSalesData

--2. How many unique payment methods does the data have?

SELECT DISTINCT(Payment) 
FROM WalmartSalesData

--3. What is the most common customer type?

SELECT Customer_type, COUNT(*) AS Common_customer
FROM WalmartSalesData
GROUP BY Customer_type
order by Common_customer desc

--4. Which customer type buys the most?

SELECT Customer_type ,SUM(Quantity) AS Regular_Cus
FROM WalmartSalesData
GROUP BY Customer_type
ORDER BY Regular_Cus DESC

----- I DONT KNOW WHICH QUERY IS CORRECT MY QUERY (ABOVE ONE) OR THIS ANOTHER QUERY (BELOW ONE )

SELECT
	customer_type,
    COUNT(*)
FROM WalmartSalesData
GROUP BY customer_type;


--5. What is the gender of most of the customers?

SELECT Customer_type , Gender, COUNT(*) AS Cus_gender_tyoe
FROM WalmartSalesData
GROUP BY Customer_type, Gender
ORDER BY Cus_gender_tyoe DESC
 
 ------ BOTH ARE CORRECT -----------------


SELECT
	gender,
	COUNT(*) as gender_cnt
FROM WalmartSalesData
GROUP BY gender
ORDER BY gender_cnt DESC;


--6. What is the gender distribution per branch?

SELECT Branch, Gender, COUNT(*) AS Gen_Dis_by_Bra
FROM WalmartSalesData
GROUP BY Branch, Gender
ORDER BY Gen_Dis_by_Bra

--7. Which time of the day do customers give most ratings?

SELECT time_of_day, COUNT(Rating) AS RATING_TOD
FROM WalmartSalesData
GROUP BY time_of_day
ORDER BY RATING_TOD DESC
 --- I DONT KNOW WHICH ONE IS  CORRECT  ???????????????
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM WalmartSalesData
GROUP BY time_of_day
ORDER BY avg_rating DESC;


--8. Which time of the day do customers give most ratings per branch?

SELECT time_of_day, Branch,AVG(Rating) AS RATING_TOD
FROM WalmartSalesData
GROUP BY time_of_day,Branch
ORDER BY RATING_TOD DESC


--9. Which day fo the week has the best avg ratings?

SELECT TOP 1 Day_Name, AVG(Rating) AS AVG_Rating
FROM WalmartSalesData
GROUP BY Day_Name
ORDER BY AVG_Rating DESC

--10. Which day of the week has the best average ratings per branch?

SELECT Branch,Day_Name, AVG(Rating) AS AVG_Rating
FROM WalmartSalesData
GROUP BY Day_Name,Branch
ORDER BY AVG_Rating DESC

SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM WalmartSalesData
WHERE branch = 'B'
GROUP BY day_name
ORDER BY total_sales DESC;


-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- ---------------------------- Sales ---------------------------------
-- --------------------------------------------------------------------
--1. Number of sales made in each time of the day per weekday
 
 SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM WalmartSalesData
WHERE day_name = 'Sunday'
GROUP BY time_of_day 
ORDER BY total_sales DESC;
-- Evenings experience most sales, the stores are 
-- filled during the evening hours

--2. Which of the customer types brings the most revenue?

SELECT Customer_type, SUM(Total) AS Total_revenue
FROM WalmartSalesData
GROUP BY Customer_type
ORDER BY Total_revenue


--3. Which city has the largest tax percent/ VAT (**Value Added Tax**)?

SELECT City, ROUND(AVG(Tax_5),2) AS TAX_PERCENTAGE
FROM WalmartSalesData
GROUP BY City 
ORDER BY TAX_PERCENTAGE DESC

--- BOTH METHOD ARE CORRECT 

SELECT
	city,
    ROUND(AVG(Tax_5), 2) AS avg_tax_pct
FROM WalmartSalesData
GROUP BY city 
ORDER BY avg_tax_pct DESC;


--4. Which customer type pays the most in VAT or tax_5?

SELECT Customer_type,ROUND(AVG(Tax_5),2) as avg_tax
FROM WalmartSalesData
GROUP BY Customer_type
ORDER BY avg_tax

------ ANOTHER WAY -------------- ANOTHER WAY

SELECT
	customer_type,
	ROUND(AVG(Tax_5),2) AS total_tax
FROM WalmartSalesData
GROUP BY customer_type
ORDER BY total_tax;


