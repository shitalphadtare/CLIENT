SELECT "DocNum", "DocDate" AS "Sales Order Date", "DocDueDate" AS "Delivery Date", "CardCode", "CardName", "DocTotal", 
CASE WHEN "DocDueDate" >= NOW() THEN 'Pending' ELSE 'Overdue' END AS "Status", 
CASE WHEN "DocDueDate" < NOW() THEN DAYS_BETWEEN("DocDueDate", NOW()) ELSE 0 END AS "Overdue Days" 
FROM ORDR t0 
WHERE (CAST(ADD_DAYS(T0."DocDueDate", -2) AS varchar(50))) = CAST(NOW() AS varchar(50)) AND t0."DocStatus" = 'O'

