Create Procedure PTS_STOCK_DETAILS_WAREHOUSE_WISE
(IN ToDate Datetime)
LANGUAGE SQLSCRIPT 
SQL SECURITY INVOKER 
AS
 Begin

select T1."LocCode", T3."WhsName", T1."ItemCode", T2."ItemName", T1."NetQty", T1."Price", T1."SumStock" 
from 
( SELECT T0."LocCode", T0."ItemCode", SUM(T0."InQty" - T0."OutQty") AS "NetQty", 
(CASE WHEN SUM(T0."InQty" - T0."OutQty") = 0 THEN 0 ELSE ((SUM(T0."SumStock")) / (SUM(T0."InQty" - T0."OutQty"))) END) AS "Price", 
SUM("SumStock") AS "SumStock" FROM OIVL T0 WHERE T0."DocDate" <= :ToDate 
GROUP BY T0."ItemCode", "LocCode"
) T1
INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode" 
LEFT OUTER JOIN OWHS T3 ON T1."LocCode" = T3."WhsCode" 
WHERE T1."SumStock" <> 0 ORDER BY T1."LocCode", T1."ItemCode";
end;