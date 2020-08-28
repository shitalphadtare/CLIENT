Create view PTS_TDS_REGISTER_WITH_CHALLAN_DATE as
select * from 
(SELECT T0."DocEntry", CAST(MONTH(T0."DocDate") AS nvarchar(2)) || '/' || CAST(YEAR(T0."DocDate") AS nvarchar(4)) AS "Month", 
T4."WTName", OSEC."Code" AS "Section", T0."CardCode" AS "BPCode", T0."CardName" AS "Party Name", T3."TaxId0" AS "PAN No.", 
CASE WHEN T5."TypWTReprt" = 'P' THEN 'Others' ELSE CASE WHEN T5."TypWTReprt" = 'C' THEN 'Company' END END AS "Status", 
IFNULL(T0."NumAtCard", '') || ' - ' || CAST(CAST(T0."TaxDate" AS date) AS varchar) AS "Bill No & Date", 
T0."DocDate" AS "EntryDate", T0."DocNum" AS "A/P Num", 'Advance Payment' AS "Type", (T0."DocTotal" + T1."WTAmnt") AS "Total Bill Amount", 
T1."TaxbleAmnt" AS "Amount Debited to P&L", T1."Rate" AS "TDS Rate", T1."WTAmnt" AS "TDS", T1."WTCode", T4."BaseType", 
vpm."ChallanNo" AS "Challan No.", vpm."ChallanDat" AS "Challan Date", vpm."BSRCode" AS "BSR Code", vpm."ChallanBak" AS "Bank Name", T0."DocDate" 

FROM ODPO T0 
INNER JOIN DPO5 T1 ON T0."DocEntry" = T1."AbsEntry" 
INNER JOIN DPO12 T3 ON T0."DocEntry" = T3."DocEntry" 
INNER JOIN OWHT T4 ON T1."WTCode" = T4."WTCode" 
INNER JOIN OCRD T5 ON T0."CardCode" = T5."CardCode" 
LEFT OUTER JOIN OWHT ON OWHT."WTCode" = T1."WTCode" 
LEFT OUTER JOIN OSEC ON OSEC."AbsId" = OWHT."Section" 
LEFT OUTER JOIN VPM8 vm8 ON vm8."DocEntry" = t0."DocEntry" AND vm8."InvType" = 204 
LEFT OUTER JOIN OVPM vpm ON vm8."DocNum" = vpm."DocNum" 
WHERE T0."CANCELED" <> 'Y' AND T0."CANCELED" <> 'C'

Union All


SELECT T0."DocEntry", CAST(MONTH(T0."DocDate") AS nvarchar(2)) || '/' || CAST(YEAR(T0."DocDate") AS nvarchar(4)) AS "Month", T4."WTName", 
OSEC."Code" AS "Section", T0."CardCode" AS "BPCode", T0."CardName" AS "Party Name", T3."TaxId0" AS "PAN No.", 
CASE WHEN T5."TypWTReprt" = 'P' THEN 'Others' ELSE CASE WHEN T5."TypWTReprt" = 'C' THEN 'Company' END END AS "Status", 
IFNULL(T0."NumAtCard", '') || ' - ' || CAST(CAST(T0."TaxDate" AS date) AS varchar) AS "Bill No & Date", T0."DocDate" AS "EntryDate", 
T0."DocNum" AS "A/P Num", 'Invoice' AS "Type", (T0."DocTotal" + T1."WTAmnt") AS "Total Bill Amount", T1."TaxbleAmnt" AS "Amount Debited to P&L", 
T1."Rate" AS "TDS Rate", T1."WTAmnt" AS "TDS", T1."WTCode", T4."BaseType", vpm."ChallanNo" AS "Challan No.", vpm."ChallanDat" AS "Challan Date", 
vpm."BSRCode" AS "BSR Code", vpm."ChallanBak" AS "Bank Name", T0."DocDate" 

FROM OPCH T0 
INNER JOIN PCH5 T1 ON T0."DocEntry" = T1."AbsEntry" 
INNER JOIN PCH12 T3 ON T0."DocEntry" = T3."DocEntry" 
INNER JOIN OWHT T4 ON T1."WTCode" = T4."WTCode" 
INNER JOIN OCRD T5 ON T0."CardCode" = T5."CardCode" 
LEFT OUTER JOIN OWHT ON OWHT."WTCode" = T1."WTCode" 
LEFT OUTER JOIN OSEC ON OSEC."AbsId" = OWHT."Section" 
LEFT OUTER JOIN VPM8 vm8 ON vm8."DocEntry" = t0."DocEntry" AND vm8."InvType" = 18 
LEFT OUTER JOIN OVPM vpm ON vm8."DocNum" = vpm."DocNum" 
WHERE T0."CANCELED" <> 'Y' AND T0."CANCELED" <> 'C'

) a