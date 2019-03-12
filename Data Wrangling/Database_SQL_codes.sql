/* This is the SQL code for the Udacity Businesss Analysis project: Create Reports from a Database
   using the Northwest Databae. Written by Shane Gore 2018

    /* Analysis of Stock: Slide 2 */

    WITH tab1 AS (
        SELECT Products.ProductID, Products.SupplierID, Products.UnitsInStock,Products.UnitsOnOrder, Products.ReorderLevel,
        OrderDetails.OrderID,  OrderDetails.Quantity,
            CASE WHEN Products.UnitsInStock  < Products.ReorderLevel AND Products.UnitsOnOrder = 0 THEN 'Needs to be ordered'
            WHEN Products.UnitsInStock  < Products.ReorderLevel AND Products.UnitsOnOrder > 0 THEN 'Products ordered'
            ELSE 'Products in stock' END AS stock_detail
        FROM Products
        JOIN OrderDetails ON Products.ProductID = OrderDetails .ProductID
        GROUP BY Products.ProductID
        ORDER BY stock_detail),

    tab2 AS (SELECT OrderDetails.ProductID, (count(OrderDetails.ProductID) * sum(OrderDetails.Quantity)) AS demand
        FROM OrderDetails
        GROUP BY 1)

    SELECT tab1.*, tab2.demand,
        CASE WHEN tab2.demand  < (SELECT avg(demand) FROM tab2) THEN 'High'
        ELSE 'Low' END AS demand_level
        FROM tab1
        JOIN tab2 ON tab2.ProductID = tab1.ProductID
        GROUP BY 1
        ORDER BY stock_detail

	/* Analysis of stock level, demand and lead time: Slide 3 */

    WITH tab1 AS (
        SELECT   OrderDetails.ProductID, Orders.EmployeeID,  Orders.OrderDate, Orders.RequiredDate, Orders.ShippedDate,
            julianday(Orders.ShippedDate) - julianday(Orders.OrderDate) AS Lead_time,
            julianday(Orders.RequiredDate)  - julianday(Orders.ShippedDate) AS Shipped_Required
        FROM Orders
        JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
        WHERE  ShippedDate IS NOT NULL
        ORDER BY Shipped_Required),

    tab2 AS (
        SELECT OrderDetails.ProductID, (count(OrderDetails.ProductID) * sum(OrderDetails.Quantity)) AS demand
        FROM OrderDetails
        GROUP BY 1)

    SELECT tab1.ProductID, avg(Lead_time) AS avg_lead_time,
           Products.UnitsInStock, tab2.demand
    FROM tab1
    JOIN Products on Products.ProductID =  tab1.ProductID
    JOIN  tab2 on   tab2.ProductID = tab1.ProductID
    GROUP BY 1
    ORDER BY avg_lead_time desc;

    /* Analysis of staff lead time, and late shipments: Slide 4*/


    WITH tab1 AS (
SELECT   OrderDetails.ProductID, Orders.EmployeeID,  Orders.OrderDate, Orders.RequiredDate, Orders.ShippedDate, Orders.OrderId,
	julianday(Orders.ShippedDate) - julianday(Orders.OrderDate) AS Lead_time,
	julianday(Orders.RequiredDate)  - julianday(Orders.ShippedDate) AS Shipped_Required
	FROM Orders
	JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
	WHERE  ShippedDate IS NOT NULL
	ORDER BY Shipped_Required),

tab2 AS (SELECT tab1.EmployeeID,  tab1.Shipped_Required,
        SUM(CASE WHEN tab1.Shipped_Required <1 THEN 1 ELSE 0 END) AS Late_Count
        FROM tab1
		GROUP BY 1)


SELECT tab2.*, avg(tab1.Lead_time) AS avg_lead_time, count(tab1.OrderId) AS num_orders,
			CAST (tab2.Late_Count AS FLOAT) /count(tab1.OrderId) AS relative_late_time
        FROM tab1
		JOIN tab2 on tab2.EmployeeID = tab1.EmployeeID
		GROUP BY 1


/* Analysis of staff lead time, grouped by Product: Slide 5. */

WITH tab1 AS (
SELECT   OrderDetails.ProductID, Orders.EmployeeID,  Orders.OrderDate, Orders.RequiredDate, Orders.ShippedDate, Orders.OrderId,
	julianday(Orders.ShippedDate) - julianday(Orders.OrderDate) AS Lead_time,
	julianday(Orders.RequiredDate)  - julianday(Orders.ShippedDate) AS Shipped_Required
	FROM Orders
	JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
	WHERE  ShippedDate IS NOT NULL
	ORDER BY Shipped_Required)

SELECT tab1.EmployeeID, tab1.ProductID, avg(tab1.Lead_time) AS avg_lead_time
        FROM tab1
		GROUP BY 2, 1

/* Analysis of staff order count: Slide 6 */

WITH tab1 AS (
    SELECT Employees.EmployeeID, Employees.HireDate,
        substr(Employees.HireDate,1,instr(Employees.HireDate, ' ')) AS start_date,
        substr(Employees.HireDate,1,instr(Employees.HireDate, '/')-1) AS Month,
        substr(Employees.HireDate, instr(Employees.HireDate, '/')+1, 4) AS day_temp,
        replace(substr(Employees.HireDate, instr(Employees.HireDate, '/')+3, 5) ,'/','') AS Year
        FROM Employees),

tab2 AS
    (SELECT tab1.EmployeeID, tab1.Year, tab1.Month, date('now') AS today,
        substr(tab1.day_temp,1,instr(tab1.day_temp,'/')-1) AS day,
        CASE WHEN Length(substr(tab1.day_temp,1,instr(tab1.day_temp,'/')-1))  = 1
    	   THEN '0' || substr(tab1.day_temp,1,instr(tab1.day_temp,'/')-1)
    	   ELSE substr(tab1.day_temp,1,instr(tab1.day_temp,'/')-1)
    	   END AS newday,
        CASE WHEN Length(tab1.Month)  = 1
    	   THEN '0' || tab1.Month
    	   ELSE tab1.Month
    	   END AS newmonth
    FROM tab1)

SELECT tab1.EmployeeID AS Employee_ID,
    julianday(date('now') ) - julianday(replace (tab1.Year || '-'|| tab2.newmonth || '-'|| tab2.newday,' ','')) AS Emplotment_days,
    count(Orders.OrderId) AS order_count,
    count(Orders.OrderId)/(julianday(date('now') ) - julianday(replace (tab1.Year || '-'|| tab2.newmonth || '-'|| tab2.newday,' ','')) ) AS relative_order_count
    FROM tab1
    JOIN tab2 ON tab1.EmployeeID = tab2.EmployeeID
    JOIN Orders ON Orders.EmployeeID = tab1.EmployeeID
    GROUP BY Employee_ID
