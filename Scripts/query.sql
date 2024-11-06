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
select e.employeeId, e.firstName, e.lastName, e.title, e.startDate, s.salesId
from employee e
left join sales s
on e.employeeId = s.employeeId
where e.title = 'Sales Person' and 
e.employeeId not in (select employeeId from sales);