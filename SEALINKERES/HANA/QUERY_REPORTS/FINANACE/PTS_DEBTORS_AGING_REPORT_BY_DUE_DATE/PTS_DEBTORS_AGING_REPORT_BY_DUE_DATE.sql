CREATE PROCEDURE PTS_DEBTORS_AGING_REPORT_BY_DUE_DATE 
(IN ToDate Timestamp)
LANGUAGE SQLSCRIPT 
SQL SECURITY INVOKER
--READ SQL DATA 
AS
 Begin
SELECT T1."CardCode", T1."CardName", T1."CreditLine", T0."RefDate", T0."Ref1" AS "Document Number", 
CASE WHEN T0."TransType" = 13 THEN 'Invoice' WHEN T0."TransType" = 14 THEN 'Credit Note' 
WHEN T0."TransType" = 30 THEN 'Journal' WHEN T0."TransType" = 24 THEN 'Receipt' END AS "Document Type", T0."DueDate", 
(T0."Debit" - T0."Credit") AS "Balance", 
CASE WHEN DAYS_BETWEEN(T0."DueDate", :ToDate) <= -1 THEN (T0."Debit" - T0."Credit") ELSE 0 END "Future",
CASE WHEN DAYS_BETWEEN(T0."DueDate", :ToDate) >= 0 AND DAYS_BETWEEN(T0."DueDate", :ToDate) <= 30 THEN 
T0."Debit" - T0."Credit" END "Current", 
CASE WHEN DAYS_BETWEEN(T0."DueDate",:ToDate) > 30 AND DAYS_BETWEEN(T0."DueDate", :ToDate) <= 60 THEN 
T0."Debit" - T0."Credit" END  "31-60 Days", 
CASE WHEN DAYS_BETWEEN(T0."DueDate", :ToDate) > 60 AND DAYS_BETWEEN(T0."DueDate", :ToDate) <= 90 THEN 
T0."Debit" - T0."Credit" END   "61-90 Days", 
CASE WHEN DAYS_BETWEEN(T0."DueDate", :ToDate) > 90 AND DAYS_BETWEEN(T0."DueDate",:ToDate) <= 120 THEN 
T0."Debit" - T0."Credit" END  "91-120 Days", 
CASE WHEN DAYS_BETWEEN(T0."DueDate", :ToDate) >= 121 THEN T0."Debit" - T0."Credit" END  AS "121+ Days" 

FROM JDT1 T0 
INNER JOIN OCRD T1 ON T0."ShortName" = T1."CardCode" 
WHERE (T0."MthDate" IS NULL OR T0."MthDate" > :ToDate) AND T0."RefDate" <= :ToDate AND T1."CardType" = 'C' 
ORDER BY T1."CardCode", T0."DueDate", T0."Ref1";
END;