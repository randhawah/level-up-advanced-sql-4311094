challange 1: 
SELECT  e.firstName,
        e.lastName,
        e.title,
        m.firstName AS ManagerFirstName,
        m.lastName AS ManagerLastName
FROM employee e
INNER JOIN employee m
    ON e.managerId = m.employeeId

Challange 2: