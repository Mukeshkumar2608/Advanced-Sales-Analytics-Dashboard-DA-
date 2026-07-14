create database complete_sales;
use complete_sales;

select * from sample_superstore;

#	Find Total Sales, Total Profit, Total Orders, and Total Customers.
SELECT 
    ROUND(SUM(Sales), 2) AS Total_sales,
    ROUND(SUM(Profit), 2) AS Total_Profite,
    COUNT(Order_ID) AS total_order,
    COUNT(DISTINCT Order_ID) AS total_customer
FROM
    sample_superstore;
# 	Find Category-wise Sales and Profit.
SELECT 
    Category,
    ROUND(SUM(Sales), 2) AS Total_sales,
    ROUND(SUM(Profit), 2) AS Total_Profite
FROM
    sample_superstore
GROUP BY Category;
 
 # 	Find Sub-Category-wise Sales and rank them from highest to lowest.
 SELECT 
    Sub_Category, ROUND(SUM(Sales), 2) AS Total_sales,
    RANK() OVER (order by SUM(Sales) desc ) as Ranks 
FROM
    sample_superstore
GROUP BY Sub_Category
ORDER BY Total_sales DESC;
 
#	Find Region-wise Sales, Profit, and Profit Margin (%).
SELECT 
    Region,
    ROUND(SUM(Sales), 2) AS Total_sales,
    ROUND(SUM(Profit), 2) AS total_profite,
    concat(round((SUM(Profit) / SUM(Sales) * 100), 2),"%") AS Margin
FROM
    sample_superstore
GROUP BY Region
;
 
# Find State-wise Top 10 Sales with RANK() or DENSE_RANK().
WITH State_rank AS (
    SELECT 
        State,
        ROUND(SUM(Sales),2) AS Total_sale,
        RANK() OVER (ORDER BY SUM(Sales) DESC) AS Rank_wises
    FROM sample_superstore
    GROUP BY State
)

SELECT *
FROM State_rank
WHERE Rank_wises <= 10;

# 	Find Monthly Sales Trend (Year-Month wise Sales & Profit).
SELECT 
    Order_year,
    Order_month,
    ROUND(SUM(Sales), 2) AS Total_sales,
    ROUND(SUM(Profit), 2) AS Total_Profite
FROM
    sample_superstore
GROUP BY Order_year , Order_month
ORDER BY Order_month ASC , Order_year ASC;
 
 # 	Find Top 10 Customers based on Total Sales using Window Functions.
 SELECT Customer_ID, 
       ROUND(SUM(Sales), 2) AS Total_sales,
       dense_rank() OVER (ORDER BY SUM(Sales) DESC) AS Rank_cst
FROM sample_superstore
GROUP BY Customer_ID
ORDER BY Rank_cst ASC
LIMIT 10;


# Find Top 10 Products based on Sales and Profit.
SELECT 
    Product_Name,
    ROUND(SUM(Sales), 2) AS Total_sales,
    ROUND(SUM(Profit), 2) AS Total_profite
FROM
    sample_superstore
GROUP BY Product_Name
ORDER BY Total_profite DESC , Total_sales DESC
LIMIT 10;

# 	Find Bottom 5 Products with the highest Loss (Negative Profit).
SELECT 
    Product_Name, ROUND(SUM(Profit), 2) AS Total_loss
FROM
    sample_superstore
GROUP BY Product_Name
HAVING SUM(Profit) < 0
ORDER BY Total_loss ASC
LIMIT 5;

# 	Find Average Delivery Days by Ship Mode.
SELECT 
    Ship_Mode, ROUND(AVG(Shiping_days), 2) AS Avg_Delivery_days
FROM
    sample_superstore
GROUP BY Ship_Mode;


# 	Find Repeat Customers (Customers having more than one Order).
SELECT 
    Customer_Name, COUNT(distinct Order_ID) AS Total_orders
FROM
    sample_superstore
GROUP BY Customer_Name
HAVING COUNT(distinct Order_ID) > 1;

# 	Find Year-over-Year (YoY) Sales Growth using LAG() Window Function.
WITH yearly_sales AS
(
    SELECT
        Order_year,
        ROUND(SUM(Sales),2) AS Total_sales
    FROM sample_superstore
    GROUP BY Order_year
)

SELECT
    Order_year,
    Total_sales,
    LAG(Total_sales) OVER (ORDER BY Order_year) AS Previous_Sales,
    
    round(
    ((Total_sales -LAG(Total_sales) OVER (ORDER BY Order_year))/ LAG(Total_sales) OVER (ORDER BY Order_year) *100)
    ,2) AS Rate_percentage 
FROM yearly_sales;

#	Find Month-over-Month (MoM) Sales Growth using LAG().
with Month_sales as 
(
select Order_month , Round(sum(Sales),2) as Total_sales
from  sample_superstore
group by Order_month

 )

select 
Order_month , 
Total_sales,
lag(Total_sales) over (order by Order_month ) as Prious_sales ,
concat(
Round((Total_sales -lag(Total_sales) over (order by Order_month ) )/lag(Total_sales) over (order by Order_month ) *100 ,2) ,"%"
) as Rate_Percentage
from Month_sales
;


# 	Find Running Total (Cumulative Sales) Month-wise.
WITH Monthly_sales AS
(
    SELECT 
        Order_month,
   
        ROUND(SUM(Sales),2) AS Total_sales
    FROM sample_superstore
    GROUP BY Order_month
    
    
)

SELECT 
    Order_month,
    Total_sales,
    round(Sum(Total_sales) OVER(ORDER BY Order_month),2) AS Recent_month_sale
FROM Monthly_sales;

# 	Find the Highest Selling Product in each Category using ROW_NUMBER().
with cataory_sales as 
(
select Category ,
Product_Name,
round(sum(Sales),2) as total_sales
 from sample_superstore
 group by Category,
 Product_Name
 )
 ,
 product_rank as
 (
 select Category,
 Product_Name,
 total_sales ,
 row_number() over (Partition by Category order by total_sales desc) as Rank_sale
 from cataory_sales 
 )
 
 select * from product_rank 
 where Rank_sale = 1
 ;
 
#	Find the Most Profitable Product in each Region.
with region_sale as
(
select Region , Product_Name ,
round(Sum(Sales),2) as total_sale
 from sample_superstore 
 group by Region,
 Product_Name 
 ),
 product_sale as
 (
 select Region,
 Product_Name,
 total_sale,
 row_number() over (partition by Region order by total_sale desc ) as Rank_sale
 from region_sale 
 )
 select * from product_sale
 where Rank_sale = 1
 ;
 
 # 	Find Customer Lifetime Value (Total Sales & Profit per Customer).
 with customer_name as
 (
 select  Customer_Name ,
 round(sum(Sales),2) as Total_sales,
 round(sum(Profit),2) as Total_profit,
 count( distinct Order_ID) as Total_order
 from sample_superstore
 group by Customer_Name 
 )
select * from customer_name;

# Find Sales Contribution (%) of each Category to Overall Sales.
with catatory_sales as 
(
select Category , round(sum(Sales),2) as total_sales
from sample_superstore
group by Category 
)
select Category,
    ROUND(SUM(Total_sales) OVER(),2) AS Overall_sales,
   
   concat( Round
   (( total_sales  /  ROUND(SUM(Total_sales) OVER(),2) 
   )*100,2 ),'%') 
   as contribution_sale
from catatory_sales
group by Category
;
#	Create a Sales Performance View for Dashboard Reporting.
 create view Sales_performance as 
 select Category , Order_year,
 round(sum(Sales),2) as Total_sales,
 round(sum(Profit),2) as Total_profite ,
 count(distinct Order_ID) as Total_order,
 sum(Quantity) as Total_Quantity
 from sample_superstore 
 group by Category ,
 Order_year;

/* Showing Data */ 
 select * from Sales_performance
 ;
 
# Create a Stored Procedure to return Sales Report by Year and Region.

DELIMITER $$

CREATE PROCEDURE GetSalesReportByYearRegion(
    IN p_year INT,
    IN p_region VARCHAR(50)
)
BEGIN

    SELECT
        Order_year,
        Region,
        SUM(Sales) AS Total_Sales,
        SUM(Profit) AS Total_Profit,
        SUM(Quantity) AS Total_Quantity,
        COUNT(DISTINCT Order_ID) AS Total_Orders,
        COUNT(DISTINCT Customer_ID) AS Total_Customers,
        ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin
    FROM sample_superstore
    WHERE Order_year = p_year
      AND Region = p_region
    GROUP BY Order_year, Region;

END $$

DELIMITER ;


CALL GetSalesReportByYearRegion(2017, 'West');