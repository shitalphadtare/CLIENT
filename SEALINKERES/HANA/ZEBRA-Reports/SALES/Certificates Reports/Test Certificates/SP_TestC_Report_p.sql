

CREATE Procedure SP_TestC_Report_p
LANGUAGE SQLSCRIPT 
SQL SECURITY INVOKER
--READ SQL DATA 
AS
 Begin

with CTE_RunningTotal as
		( SELECT "Number", "Quantity" AS "Quantity", "County", "DocEntry", "VisOrder", "quantity1" FROM 
(SELECT ROW_NUMBER() OVER (PARTITION BY "b","County" ORDER BY "DocEntry","VisOrder") AS "Number", * FROM (
SELECT ROW_NUMBER() OVER (PARTITION BY "VisOrder",dn1."DocEntry" ORDER BY dn1."DocEntry",dn1."VisOrder") AS "b", 
"Quantity", IFNULL((SELECT CASE WHEN crd."CardFName" = cd1."County" THEN crd."U_markno" ELSE cd1."U_TC_Qty" END AS "a" 
FROM ODLN dln1 INNER JOIN DLN1 dn2 ON dn2."DocEntry" = DLN1."DocEntry" LEFT OUTER JOIN OCRD crd ON dln1."CardCode" = crd."CardCode" 
LEFT OUTER JOIN CRD1 cd1 ON dln1."CardCode" = cd1."CardCode" AND DLN1."ShipToCode" = cd1."Address" AND cd1."AdresType" = 'S'
 WHERE DLN1."DocEntry" = dln."DocEntry" AND dln1."CardCode" = dln1."CardCode" AND dn2."VisOrder" = dn1."VisOrder" AND cd1."County" = cd3."County" 
 AND NOW() < '20200101'), 0) AS "quantity1", dn1."VisOrder", dn1."DocEntry", cd3."County" 
 FROM ODLN dln INNER JOIN DLN1 dn1 ON dln."DocEntry" = dn1."DocEntry" 
 LEFT OUTER JOIN CRD1 CD3 ON DLN."ShipToCode" = CD3."Address" AND CD3."AdresType" = 'S' AND dln."CardCode" = cd3."CardCode" WHERE dln."U_DTCWCReq" = 'TC'
 AND dn1."U_RTCReq" = 'YES' AND dln.CANCELED <> 'Y' AND dn1."TargetType" <> 16 AND dln.CANCELED <> 'Y') AS A) AS b),
-----------------------------------------------------------------------------			
	TestC_Report_p as(SELECT dln."DocEntry", dln."CardName", dln."DocNum", dln."DocDate", NM1."SeriesName" || '/' || CAST(dln."DocNum" AS varchar) AS "Document Number", 
dln."NumAtCard" AS "PO NO", dln."U_BPRefDt" AS "PO DATE", CASE WHEN dln."U_tcaddrs" = 'Bill To' THEN dln."Address" ELSE dln."Address2" 
END AS "bill to address", dn1."ItemCode", IFNULL((SUBSTRING(dn1."U_ItemDesc3", 0, LOCATE(dn1."U_ItemDesc3", ' '))), 
(SUBSTRING(dn1."Dscription", 0, LOCATE(dn1."Dscription", ' ')))) AS "Dscription", dn1."Quantity", 
CASE WHEN DN7.U_TCDT = '' OR dn7.U_TCDT IS NULL THEN dn1.U_TCDT ELSE dn7.U_TCDT END AS "TEST DATE", 
CASE WHEN dn7.U_PRROFLOAD = '' OR dn7.U_PRROFLOAD IS NULL THEN dn1.U_PROOFLOAD ELSE 
dn7.U_PRROFLOAD END AS "PROOF LOAD", CASE WHEN DN7.U_SWL = '' OR dn7.U_SWL IS NULL 
THEN dn1.U_SWL ELSE dn7.U_SWL END AS "SWL", CASE WHEN dn7.U_LIFT = '' OR dn7.U_LIFT IS NULL THEN dn1.U_LIFT ELSE dn7.U_LIFT END AS "LIFT", 0 AS "Item Quanitity",
 dn1."VisOrder", IFNULL((SELECT "CardFName" FROM OCRD WHERE "CardCode" = dln."CardCode") || '  -', '') ||
  (SELECT "Name" FROM "@TC_YR" WHERE "Code" = year(dln."DocDate")) AS "TC_YEAR", dln."TaxDate", dln.U_SIGN, 
  IFNULL((SELECT "U_TCPrefix" FROM "@TC_NUM" WHERE "Code" = 'TC'), '') || dln."U_DTCNum" AS "TC Number", IFNULL(CD3."County" || '-', '') ||
   (SELECT "Name" FROM "@TC_YR" WHERE "Code" = year(dln."DocDate")) AS "COUNTY", 
   CASE WHEN dln."U_tcaddrs" = 'Bill To' THEN dln."PayToCode" ELSE dln."ShipToCode" END AS "THIRD_PARTY" 
   
   FROM ODLN dln INNER JOIN DLN1 dn1 ON dln."DocEntry" = dn1."DocEntry" 
   LEFT OUTER JOIN CRD1 CD3 ON DLN."ShipToCode" = CD3."Address" AND CD3."AdresType" = 'S' AND dln."CardCode" = cd3."CardCode" 
   LEFT OUTER JOIN OITM itm ON dn1."ItemCode" = itm."ItemCode" 
   LEFT OUTER JOIN OITB itb ON itm."ItmsGrpCod" = itb."ItmsGrpCod" LEFT OUTER JOIN NNM1 NM1 ON NM1."Series" = dln."Series" 
   LEFT OUTER JOIN CRD1 cd1 ON dln."CardCode" = cd1."CardCode" AND dln."PayToCode" = cd1."Address" AND cd1."AdresType" = 'B' 
   LEFT OUTER JOIN OWHS WHS ON dn1."WhsCode" = WHS."WhsCode" LEFT OUTER JOIN OLCT LCT ON dn1."LocCode" = LCT."Code" 
   LEFT OUTER JOIN OCST CST ON LCT."State" = CST."Code" AND LCT."Country" = CST."Country" 
   LEFT OUTER JOIN DLN8 DN8 ON DLN."DocEntry" = DN8."DocEntry" AND dn1."ItemCode" = dn8."ItemCode" 
   LEFT OUTER JOIN DLN7 DN7 ON DN7."DocEntry" = DLN."DocEntry" AND DN7."PackageNum" = DN8."PackageNum" 
WHERE dln."U_DTCWCReq" = 'TC' AND dn1."U_RTCReq" = 'YES' AND dn1."TargetType" <> 16 AND dln.CANCELED <> 'Y')
------------------------------------------------------------------------------------------------------------------------

SELECT CAST(CAST((CASE WHEN "Mark_Qty" = 1 THEN "Mark_Qty" ELSE "Mark_Qty" + 1 - "Quantity" END) AS integer) AS varchar) 
|| '-' || CAST(CAST("Mark_Qty" AS integer) AS varchar) AS "Mark_No", * FROM (
SELECT (SELECT SUM("Quantity") 
FROM CTE_RunningTotal c WHERE c."Number" <= b."Number" AND IFNULL(c."County", '') = IFNULL(b."County", '')) 
+ b."quantity1" AS "Mark_Qty",
 b."Number", b."Quantity" AS "B_Qty", b."County" AS "B_County", b."VisOrder" AS "B_Vis", a.* 

FROM TestC_Report_p A LEFT OUTER JOIN CTE_RunningTotal B ON a."DocEntry" = b."DocEntry" AND a."VisOrder" = b."VisOrder"
) AS final 
ORDER BY final."DocEntry", final."VisOrder";
end;



