--Create View PENDING_SALES_ORDER_CUSTOMER_WISE
--as

SELECT T0."CardCode" AS "Cust Code", T0."CardName" AS "Cust Name", t0."NumAtCard" AS "Cust Ref No", 
(SELECT "SlpName" FROM OSLP t7 WHERE t7."SlpCode" = t0."SlpCode") AS "Sales Person", T0."DocEntry", 
T1."SeriesName" || '/' || CAST(T0."DocNum" AS char(20)) AS "Order Doc Number", T0."DocDate" AS "Doc Date", 
T4."ItemCode", T4."Dscription", T0."DocCur" AS "Currency", T4."Quantity" AS "Ordered Qty", T4."Price" AS "Unit Price", 
(T4."Quantity" * T4."Price") AS "Order Value", T0."DocDueDate" AS "Order Due Date", T4."OpenQty" AS "Pending Qty", (T4."OpenQty" * T4."Price") AS "Pending Value" 
FROM RDR1 T4 
LEFT OUTER JOIN (SELECT "BaseEntry", "BaseLine", "ItemCode", SUM("Quantity") AS "InvQty" 
				FROM INV1 GROUP BY "BaseEntry", "BaseLine", "ItemCode") AS T6 ON T4."DocEntry" = T6."BaseEntry" AND T4."ItemCode" = T6."ItemCode" AND T4."LineNum" = T6."BaseLine" 
LEFT OUTER JOIN ORDR T0 ON T4."DocEntry" = T0."DocEntry" LEFT OUTER JOIN NNM1 T1 ON T0."Series" = T1."Series" 
LEFT OUTER JOIN OINV T2 ON T4."TrgetEntry" = T2."DocEntry" 
LEFT OUTER JOIN (SELECT "DocEntry", SUM("Quantity") AS "SQty", SUM("OpenQty") AS "PQty" FROM RDR1 GROUP BY "DocEntry") AS T5 ON T4."DocEntry" = T5."DocEntry" 
WHERE T4."LineStatus" = 'O' 
ORDER BY T0."CardCode", T0."SlpCode"