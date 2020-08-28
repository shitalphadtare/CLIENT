Create view PTS_TDS_REGISTER as
SELECT T0."DocEntry", CAST(MONTH(T0."DocDate") AS nvarchar(2)) || '/' || CAST(YEAR(T0."DocDate") AS nvarchar(4)) AS "Month", 
T4."WTName", OSEC."Code" AS "Section", T0."CardCode" AS "BPCode", T0."CardName" AS "Party Name", 
T3."TaxId0" AS "PAN No.", CASE WHEN T5."TypWTReprt" = 'P' THEN 'Others' ELSE CASE WHEN T5."TypWTReprt" = 'C' 
THEN 'Company' END END AS "Status", IFNULL(T0."NumAtCard", '') || ' - ' || CAST(CAST(T0."TaxDate" AS date) AS varchar) AS "Bill No & Date", 
T0."DocDate" AS "EntryDate", T0."DocNum" AS "A/P Num", T0."DocTotal" AS "Amount Debited to P&L", 
T1."TaxbleAmnt" AS "Amount Chargeable to TDS", T1."Rate" AS "TDS Rate", T1."WTAmnt" AS "TDS", T1."WTCode" 
,T0."DocDate"
FROM OPCH T0 
INNER JOIN PCH5 T1 ON T0."DocEntry" = T1."AbsEntry" 
INNER JOIN PCH12 T3 ON T0."DocEntry" = T3."DocEntry" 
INNER JOIN OWHT T4 ON T1."WTCode" = T4."WTCode" 
INNER JOIN OCRD T5 ON T0."CardCode" = T5."CardCode" 
LEFT OUTER JOIN OWHT ON OWHT."WTCode" = T1."WTCode" 
LEFT OUTER JOIN OSEC ON OSEC."AbsId" = OWHT."Section"