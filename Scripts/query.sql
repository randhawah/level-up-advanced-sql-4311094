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
where s.soldDate between '2022-01-01' and '2022-12-31'
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
where s.soldDate between '2022-01-01' and '2022-12-31'
group by e.employeeId, e.firstName, e.lastName
having CarsSold > 5;