1. To get today.
SELECT GETDATE() 'Today'
2. To get yesterday.
SELECT DATEADD(d,-1,GETDATE()) 'Yesterday'
3. Start of the current day.
SELECT DATEADD(dd,DATEDIFF(dd,0,GETDATE()),0) 'Start of this day'
4. End of current day
SELECT DATEADD(ms,-3,DATEADD(dd,DATEDIFF(dd,0,GETDATE()),1)) 'End of this day'
5. Home yesterday.
SELECT DATEADD(dd,DATEDIFF(dd,0,GETDATE()),-1) 'Start from yesterday'
6. End of yesterday.
SELECT DATEADD(ms,-3,DATEADD(dd,DATEDIFF(dd,0,GETDATE()),0)) 'End of yesterday'
7. First day of the current week.
SELECT DATEADD(wk,DATEDIFF(wk,0,GETDATE()),0) 'First day of the current week'
8. Last day of the current week.
SELECT DATEADD(wk,DATEDIFF(wk,0,GETDATE()),6) 'Last day of the current week'
9. First day of last week.
SELECT DATEADD(wk,DATEDIFF(wk,7,GETDATE()),0) 'First day of last week'
10. Last day of last week.
SELECT DATEADD(wk,DATEDIFF(wk,7,GETDATE()),6) 'Last day of last week'
11. First day of the current month.
SELECT DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0) 'First day of the current month'
12. Last day of the current month.
SELECT DATEADD(ms,-3,DATEADD(mm,0,DATEADD(mm,DATEDIFF(mm,0,GETDATE())+1,0))) 'Last day of current month'
13. First day of last month.
SELECT DATEADD(mm,-1,DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0)) 'First day of last month'
14. Last day of last month.
SELECT DATEADD(ms,-3,DATEADD(mm,0,DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0))) 'Last day of last month'
15. First day of this year.
SELECT DATEADD(yy,DATEDIFF(yy,0,GETDATE()),0) 'First day of this year'
16. Last day of this year.
SELECT DATEADD(ms,-3,DATEADD(yy,0,DATEADD(yy,DATEDIFF(yy,0,GETDATE())+1,0))) 'Last day of this year'
17. First day of last year.
SELECT DATEADD(yy,-1,DATEADD(yy,DATEDIFF(yy,0,GETDATE()),0)) 'First day of last year'
18. Last day of last year.
SELECT DATEADD(ms,-3,DATEADD(yy,0,DATEADD(yy,DATEDIFF(yy,0,GETDATE()),0))) 'Last day of last year'
19. First day of the next month.
SELECT DATEADD(mm,1,DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0)) 'First day of next month'
20. Last day of the next month.
SELECT DATEADD(ms,-3,DATEADD(mm,DATEADD(mm,(DATEDIFF(mm,0,GETDATE()),0))) 'Last day of next month'

