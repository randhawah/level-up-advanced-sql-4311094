-- challange 1-1: 
-- select name of employee and their manager
SELECT  e.firstName,
        e.lastName,
        e.title,
        m.firstName AS ManagerFirstName,
        m.lastName AS ManagerLastName
FROM employee e
INNER JOIN employee m
    ON e.managerId = m.employeeId;

-- Challange 1-2:
-- Select name of sales person with 0 sales
select  e.firstName,
        e.lastName,  
        e.title, 
        e.startDate, 
        s.salesId
from employee e
left join sales s
on e.employeeId = s.employeeId
where e.title = 'Sales Person' and 
e.employeeId not in (select employeeId from sales);

-- Challange 1-3:
-- get all data from customer table and sales table even if some of the
-- data is missing because of the routine data cleanup jobs in place

-- Sol: for this we need a full outter join, which is not compatible
-- in SQLite we can create a inner join, left and right join then 
-- combine all with a UNION to get the same results
select  c.firstName, 
        c.lastName, 
        c.email,
        s.salesAmount,
        s.soldDate
from customer c
inner join sales s
on c.customerId = s.customerId
UNION
select  c.firstName, 
        c.lastName, 
        c.email,
        s.salesAmount,
        s.soldDate
from customer c
left join sales s
on c.customerId = s.customerId
where s.salesId is NULL
UNION
select  c.firstName, 
        c.lastName, 
        c.email,
        s.salesAmount,
        s.soldDate
from customer c
right join sales s
on c.customerId = s.customerId
where c.customerId is NULL;

-- Challange 2-1:
-- pull a report that totals the number of cars sold by each employee

select  e.employeeId, 
        e.firstName, 
        e.lastName,
        count(*) as TotalSales
from employee e
join sales s
on e.employeeId = s.employeeId
group by e.employeeId, e.firstName, e.lastName
order by TotalSales DESC;

-- Challange 2-2:
-- Find the least and most expensive car sold by each employee this year
select  e.employeeId,
        e.firstName,
        e.lastName,
        min(s.salesAmount) as MinimumSale,
        max(s.salesAmount) as MaximumSale
from employee e
join sales s
on e.employeeId = s.employeeId
where s.soldDate between '2023-01-01' and '2023-12-31'
group by e.employeeId;

-- Challange 2-3:
-- Display report for employees who have sold at least 5 cars
select  e.employeeId,
        e.firstName,
        e.lastName,
        count(*) as CarsSold,
        min(s.salesAmount) as MinimumSale,
        max(s.salesAmount) as MaximumSale
from employee e
join sales s
on e.employeeId = s.employeeId
where s.soldDate between '2023-01-01' and '2023-12-31'
group by e.employeeId, e.firstName, e.lastName
having CarsSold > 5;

-- Challange 3-1:
-- Summarise sales per year by using a CTE
with cte as(
select  strftime('%Y', soldDate) as year,
        salesAmount
from sales
)
select  year,
        format("$%.2f", sum(salesAmount)) as yearlySales
from cte
group by year
order by year;

-- Challange 3-2:
-- Display cars sold for each employee by month for 2021
-- rows per employee, with first name and last name, 
-- columns with month names and values

select  e.firstName, 
        e.lastName,
        SUM(case when strftime('%m', soldDate) = '01'
        then salesAmount END) AS JanSales,
        SUM(case when strftime('%m', soldDate) = '02'
        then salesAmount END) AS FebSales,
        SUM(case when strftime('%m', soldDate) = '03'
        then salesAmount END) AS MarSales,
        SUM(case when strftime('%m', soldDate) = '04'
        then salesAmount END) AS AprSales,
        SUM(case when strftime('%m', soldDate) = '05'
        then salesAmount END) AS MaySales,
        SUM(case when strftime('%m', soldDate) = '06'
        then salesAmount END) AS JunSales,
        SUM(case when strftime('%m', soldDate) = '07'
        then salesAmount END) AS JulSales,
        SUM(case when strftime('%m', soldDate) = '08'
        then salesAmount END) AS AugSales,
        SUM(case when strftime('%m', soldDate) = '09'
        then salesAmount END) AS SepSales,
        SUM(case when strftime('%m', soldDate) = '10'
        then salesAmount END) AS OctSales,
        SUM(case when strftime('%m', soldDate) = '11'
        then salesAmount END) AS NovSales,
        SUM(case when strftime('%m', soldDate) = '12'
        then salesAmount END) AS DecSales
from employee e
join sales s on e.employeeId = s.employeeId
where soldDate between '2021-01-01' and '2021-12-31'
group by e.firstName, e.lastName
order by e.lastName, e.firstName;

-- Challange 3-3:
-- Find sales of cars which are electric by using a subquery

select  s.soldDate, s.salesAmount, i.colour, i.year
from sales s 
join inventory i on s.inventoryId = i.inventoryId
where i.modelId in (select modelId from model where EngineType = 'Electric');

-- Challange 4-1:
-- For each sales person rank the car models they've sold most

-- First join the tables to get the necessary data
SELECT emp.firstName, emp.lastName, mdl.model, sls.salesId
FROM sales sls
INNER JOIN employee emp
  ON sls.employeeId = emp.employeeId
INNER JOIN inventory inv
  ON inv.inventoryId = sls.inventoryId
INNER JOIN model mdl
  ON mdl.modelId = inv.modelId

-- apply the grouping
SELECT emp.firstName, emp.lastName, mdl.model,
  count(model) AS NumberSold
FROM sales sls
INNER JOIN employee emp
  ON sls.employeeId = emp.employeeId
INNER JOIN inventory inv
  ON inv.inventoryId = sls.inventoryId
INNER JOIN model mdl
  ON mdl.modelId = inv.modelId
GROUP BY emp.firstName, emp.lastName, mdl.model

-- add in the windowing function
SELECT emp.firstName, emp.lastName, mdl.model,
  count(model) AS NumberSold,
  rank() OVER (PARTITION BY sls.employeeId 
              ORDER BY count(model) desc) AS Rank
FROM sales sls
INNER JOIN employee emp
  ON sls.employeeId = emp.employeeId
INNER JOIN inventory inv
  ON inv.inventoryId = sls.inventoryId
INNER JOIN model mdl
  ON mdl.modelId = inv.modelId
GROUP BY emp.firstName, emp.lastName, mdl.model

-- Challange 4-2
-- Create a report showing sales per month and an annual total

-- get the needed data
SELECT strftime('%Y', soldDate) AS soldYear, 
  strftime('%m', soldDate) AS soldMonth, 
  salesAmount
FROM sales

-- apply the grouping
SELECT strftime('%Y', soldDate) AS soldYear, 
  strftime('%m', soldDate) AS soldMonth,
  SUM(salesAmount) AS salesAmount
FROM sales
GROUP BY soldYear, soldMonth
ORDER BY soldYear, soldMonth

-- add the window function - simplify with cte
with cte_sales as (
SELECT strftime('%Y', soldDate) AS soldYear, 
  strftime('%m', soldDate) AS soldMonth,
  SUM(salesAmount) AS salesAmount
FROM sales
GROUP BY soldYear, soldMonth
)
SELECT soldYear, soldMonth, salesAmount,
  SUM(salesAmount) OVER (
    PARTITION BY soldYear 
    ORDER BY soldYear, soldMonth) AS AnnualSales_RunningTotal
FROM cte_sales
ORDER BY soldYear, soldMonth

-- Challange 4-3
-- Displays the number of cars sold this month, and last month

-- Get the data
SELECT strftime('%Y-%m', soldDate) AS MonthSold,
  COUNT(*) AS NumberCarsSold
FROM sales
GROUP BY strftime('%Y-%m', soldDate)

-- Apply the window function
SELECT strftime('%Y-%m', soldDate) AS MonthSold,
  COUNT(*) AS NumberCarsSold,
  LAG (COUNT(*), 1, 0 ) OVER calMonth AS LastMonthCarsSold
FROM sales
GROUP BY strftime('%Y-%m', soldDate)
WINDOW calMonth AS (ORDER BY strftime('%Y-%m', soldDate))
ORDER BY strftime('%Y-%m', soldDate)
