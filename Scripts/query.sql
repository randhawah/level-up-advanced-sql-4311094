-- challange 1: 
-- select name of employee and their manager
SELECT  e.firstName,
        e.lastName,
        e.title,
        m.firstName AS ManagerFirstName,
        m.lastName AS ManagerLastName
FROM employee e
INNER JOIN employee m
    ON e.managerId = m.employeeId;

-- Challange 2:
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

-- Challange 3:
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

-- Challange 4:
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

-- Challange 5:
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

-- Challange 6:
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

-- Challange 7:
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

-- Challange 8:
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

-- Challange 9:
-- Find sales of cars which are electric by using a subquery

select  s.soldDate, s.salesAmount, i.colour, i.year
from sales s 
join inventory i on s.inventoryId = i.inventoryId
where i.modelId in (select modelId from model where EngineType = 'Electric');
