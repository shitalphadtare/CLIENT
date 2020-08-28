Create Procedure PTS_STOCK_MOVEMENT_REPORT_FOR_ALL_WAREHOUSE
(IN FromDate Datetime,
IN ToDate Datetime)
LANGUAGE SQLSCRIPT 
SQL SECURITY INVOKER 
AS
 Begin  
SELECT  A."ItemCode",  MAX(A."Dscription") AS "ItemName",  SUM(A."OpeningBalance") AS "OpeningBalance",  SUM(A."INq") AS "In",  SUM(A."OUT") AS "Out",  
((SUM(A."OpeningBalance") + SUM(A."INq")) - SUM(A."OUT")) AS "Closing" ,  
(SELECT I."InvntryUom" FROM OITM I WHERE I."ItemCode"=A."ItemCode") AS "Inventory_UOM"

 FROM (
 
 SELECT N1."ItemCode", N1."Dscription", (SUM(N1."InQty") - SUM(n1."OutQty")) AS "OpeningBalance", 0 AS "INq", 0 "OUT"
 FROM OINM N1 WHERE N1."DocDate" < :FromDate GROUP BY N1."ItemCode", N1."Dscription" 
 
 UNION ALL 
 
 SELECT N1."ItemCode", N1."Dscription", 0 AS "OpeningBalance", SUM(N1."InQty"), 0 
 FROM OINM N1 WHERE N1."DocDate" >= :FromDate AND N1."DocDate" <= :ToDate AND N1."InQty" > 0 
 GROUP BY N1."ItemCode", N1."Dscription" 
 
 UNION ALL 
 
 SELECT N1."ItemCode", N1."Dscription", 0 AS "OpeningBalance", 0, SUM(N1."OutQty") FROM OINM N1 
 WHERE N1."DocDate" >= :FromDate AND N1."DocDate" <= :ToDate AND N1."OutQty" > 0 GROUP BY N1."ItemCode", N1."Dscription"
 
 ) A,   
 OITM I1  
WHERE A."ItemCode"=I1."ItemCode"  
GROUP BY A."ItemCode"  
HAVING SUM(A."OpeningBalance") + SUM(A."INq") + SUM(A."OUT") > 0  
ORDER BY A."ItemCode";
end;