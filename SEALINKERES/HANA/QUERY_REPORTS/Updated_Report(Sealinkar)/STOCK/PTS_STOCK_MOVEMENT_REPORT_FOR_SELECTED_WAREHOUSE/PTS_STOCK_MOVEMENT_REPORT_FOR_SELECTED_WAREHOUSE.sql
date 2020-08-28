Create Procedure PTS_STOCK_MOVEMENT_REPORT_FOR_SELECTED_WAREHOUSE
(IN FromDate Datetime,
IN ToDate Datetime,
IN Whse varchar(30))
LANGUAGE SQLSCRIPT 
SQL SECURITY INVOKER 
AS
 Begin  
Select :Whse as "Warehouse", a."ItemCode", max(a."Dscription") as "ItemName",
sum(a."OpeningBalance") as "OpeningBalance", sum(a."INq") as "IN", sum(a."OUT") as "OUT",
((sum(a."OpeningBalance") + sum(a."INq")) - Sum(a."OUT")) as Closing ,
(Select i."InvntryUom" from OITM i where i."ItemCode"=a."ItemCode") as UOM
from( 
SELECT N1."Warehouse", N1."ItemCode", N1."Dscription", (SUM(N1."InQty") - SUM(n1."OutQty")) AS "OpeningBalance", 0 AS "INq", 0 "OUT"
FROM OINM N1 WHERE N1."DocDate" < :FromDate AND N1."Warehouse" = :Whse 
GROUP BY N1."Warehouse", N1."ItemCode", N1."Dscription" 

UNION ALL 

SELECT N1."Warehouse", N1."ItemCode", N1."Dscription", 0 AS "OpeningBalance", SUM(N1."InQty"), 0 
FROM OINM N1 WHERE N1."DocDate" >= :FromDate AND N1."DocDate" <= :ToDate 
AND N1."InQty" > 0 AND N1."Warehouse" = :Whse 
GROUP BY N1."Warehouse", N1."ItemCode", N1."Dscription" 

UNION ALL 

SELECT N1."Warehouse", N1."ItemCode", N1."Dscription", 0 AS "OpeningBalance", 0, SUM(N1."OutQty") 
FROM OINM N1 WHERE N1."DocDate" >= :FromDate AND N1."DocDate" <= :ToDate AND N1."OutQty" > 0 AND N1."Warehouse" = :Whse 
GROUP BY N1."Warehouse", N1."ItemCode", N1."Dscription"
) A, OITM I1
where a."ItemCode"=I1."ItemCode"
Group By a."ItemCode" Having sum(a."OpeningBalance") + sum(a."INq") + sum(a."OUT") > 0 
Order By a."ItemCode";
end;