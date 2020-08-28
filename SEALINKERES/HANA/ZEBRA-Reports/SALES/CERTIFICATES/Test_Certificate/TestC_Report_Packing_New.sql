create view TestC_Report_Packing_New
as
SELECT dln."DocEntry", dln."CardName", dln."DocDate", NM1."SeriesName" || '/' || CAST(dln."DocNum" AS varchar) AS "Document Number", 
dln."NumAtCard" AS "PO NO", dln."U_BPRefDt" AS "PO DATE", 
CASE WHEN dln."U_tcaddrs" = 'Bill To' THEN dln."Address" ELSE dln."Address2" END AS "bill to address", 
dn1."ItemCode", IFNULL(dn1."U_ItemDesc3", dn1."Dscription") AS "Dscription", dn1."Quantity", 
DN7.U_TCDT AS "TEST DATE", dn7.U_PRROFLOAD AS "PROOF LOAD", DN7.U_SWL AS "SWL", '' AS "DISTING MARK", '' AS "TYPE OF", '' AS "SERIAL NO", 
dn1.U_LIFT AS "LIFT", 0 AS "Item Quanitity", dn1."VisOrder", '' AS "ItmsGrpNam", 
(SELECT "U_Start_Qty" FROM "@TC_D" WHERE "DocEntry" = dln."DocEntry" AND "VisOrder" = dn1."VisOrder") AS "start_quantity", 
(SELECT "U_End_Qty" FROM "@TC_D" WHERE "DocEntry" = dln."DocEntry" AND "VisOrder" = dn1."VisOrder") AS "end_quantity", 
IFNULL((SELECT "CardFName" FROM OCRD WHERE "CardCode" = dln."CardCode") || '  -', '') || (SELECT "Name" FROM "@TC_YR" WHERE "Code" = year(dln."DocDate")) AS "TC_YEAR", 
dln."TaxDate", dln.U_SIGN, CASE WHEN year(dln."DocDate") = '2019' THEN IFNULL((SELECT "U_TCPrefix" FROM "@TC_NUM" WHERE "Code" = 'TC'), '') 
ELSE (SELECT "U_TCPrefix" FROM "@TC_NUM" WHERE right("Code", 4) = CAST(year(dln."DocDate") AS varchar) AND left("Code", 2) = 'TC') END ||
 dln."U_DTCNum" AS "TC Number", IFNULL(CD3."County" || '-', '') || (SELECT "Name" FROM "@TC_YR" WHERE "Code" = year(dln."DocDate")) AS "COUNTY", 
 CASE WHEN dln."U_tcaddrs" = 'Bill To' THEN dln."PayToCode" ELSE dln."ShipToCode" END AS "THIRD_PARTY", 
 DN7.U_ITEMDESC AS "ITEM DECRIPTION 3", DN7."U_issno" AS "ISSUE_NUMBER" 
 FROM ODLN dln 
 INNER JOIN DLN1 dn1 ON dln."DocEntry" = dn1."DocEntry" 
 LEFT OUTER JOIN CRD1 CD3 ON DLN."ShipToCode" = CD3."Address" AND CD3."AdresType" = 'S' AND dln."CardCode" = cd3."CardCode" 
 LEFT OUTER JOIN OITM itm ON dn1."ItemCode" = itm."ItemCode" 
 LEFT OUTER JOIN OITB itb ON itm."ItmsGrpCod" = itb."ItmsGrpCod" 
 LEFT OUTER JOIN NNM1 NM1 ON NM1."Series" = dln."Series" 
 LEFT OUTER JOIN CRD1 cd1 ON dln."CardCode" = cd1."CardCode" AND dln."PayToCode" = cd1."Address" AND cd1."AdresType" = 'B' 
 LEFT OUTER JOIN OWHS WHS ON dn1."WhsCode" = WHS."WhsCode" 
 LEFT OUTER JOIN OLCT LCT ON dn1."LocCode" = LCT."Code" 
 LEFT OUTER JOIN OCST CST ON LCT."State" = CST."Code" AND LCT."Country" = CST."Country" 
 LEFT OUTER JOIN DLN8 DN8 ON DLN."DocEntry" = DN8."DocEntry" AND dn1."ItemCode" = dn8."ItemCode" 
 LEFT OUTER JOIN DLN7 DN7 ON DN7."DocEntry" = DLN."DocEntry" AND DN7."PackageNum" = DN8."PackageNum" 
 WHERE dln."U_DTCWCReq" = 'TC' AND dn1."U_RTCReq" = 'YES' AND dn1."TargetType" <> 16
