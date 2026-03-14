/*
Purpose:
- Common SQL Server date boundary snippets for reporting and maintenance queries.
*/

-- 1. Get today.
SELECT GETDATE() AS [Today];

-- 2. Get yesterday.
SELECT DATEADD(DAY, -1, GETDATE()) AS [Yesterday];

-- 3. Start of the current day.
SELECT DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0) AS [Start of this day];

-- 4. End of the current day.
SELECT DATEADD(MILLISECOND, -3, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AS [End of this day];

-- 5. Start of yesterday.
SELECT DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) - 1, 0) AS [Start of yesterday];

-- 6. End of yesterday.
SELECT DATEADD(MILLISECOND, -3, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0)) AS [End of yesterday];

-- 7. First day of the current week.
SELECT DATEADD(WEEK, DATEDIFF(WEEK, 0, GETDATE()), 0) AS [First day of the current week];

-- 8. Last day of the current week.
SELECT DATEADD(WEEK, DATEDIFF(WEEK, 0, GETDATE()), 6) AS [Last day of the current week];

-- 9. First day of last week.
SELECT DATEADD(WEEK, DATEDIFF(WEEK, 7, GETDATE()), 0) AS [First day of last week];

-- 10. Last day of last week.
SELECT DATEADD(WEEK, DATEDIFF(WEEK, 7, GETDATE()), 6) AS [Last day of last week];

-- 11. First day of the current month.
SELECT DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0) AS [First day of the current month];

-- 12. Last day of the current month.
SELECT DATEADD(MILLISECOND, -3, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0)) AS [Last day of current month];

-- 13. First day of last month.
SELECT DATEADD(MONTH, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)) AS [First day of last month];

-- 14. Last day of last month.
SELECT DATEADD(MILLISECOND, -3, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)) AS [Last day of last month];

-- 15. First day of this year.
SELECT DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0) AS [First day of this year];

-- 16. Last day of this year.
SELECT DATEADD(MILLISECOND, -3, DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()) + 1, 0)) AS [Last day of this year];

-- 17. First day of last year.
SELECT DATEADD(YEAR, -1, DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0)) AS [First day of last year];

-- 18. Last day of last year.
SELECT DATEADD(MILLISECOND, -3, DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0)) AS [Last day of last year];

-- 19. First day of the next month.
SELECT DATEADD(MONTH, 1, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)) AS [First day of next month];

-- 20. Last day of the next month.
SELECT DATEADD(MILLISECOND, -3, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 2, 0)) AS [Last day of next month];
