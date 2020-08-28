CREATE view TC_Report as
SELECT dln."DocEntry", dln."CardName", dln."DocDate", NM1."SeriesName" || '/' || CAST(dln."DocNum" AS varchar) AS "Document Number", 
dln."NumAtCard" AS "PO NO", dln."U_BPRefDt" AS "PO DATE", 
CASE WHEN dln."U_tcaddrs" = 'Bill To' THEN dln."Address" ELSE dln."Address2" END AS "bill to address", dn1."ItemCode", 
IFNULL(dn1."U_ItemDesc3", dn1."Dscription") AS "Dscription", dn1."Quantity", DN7.U_TCDT AS "TEST DATE", 
dn7.U_PRROFLOAD AS "PROOF LOAD", DN7.U_SWL AS "SWL", '' AS "DISTING MARK", '' AS "TYPE OF", '' AS "SERIAL NO", dn7.U_LIFT AS "LIFT", '' AS "Item master SWLAD", 
0 AS "Item Quanitity", dn1."VisOrder", '' AS "ItmsGrpNam", (SELECT IFNULL(SUM(IFNULL("Quantity", 0)), 0) 
FROM ODLN dln1 INNER JOIN dln1 dn2 ON DLN1."DocEntry" = dn2."DocEntry" WHERE CANCELED <> 'Y' AND DLN1."DocEntry" < dln."DocEntry" 
AND dln1."CardCode" = dln."CardCode" AND year(NOW()) = year(DLN1."DocDate")) AS "start_quantity", 
IFNULL((SELECT "CardFName" FROM OCRD WHERE "CardCode" = dln."CardCode") || '  -', '') || (SELECT "Name" FROM "@TC_YR" WHERE "Code" = year(dln."DocDate")) AS "TC_YEAR", 
dln."TaxDate", OSRN."MnfSerial" AS "DistNumber", 
(SELECT "U_TCPrefix" FROM "@TC_NUM" WHERE "Name" = dn1."U_Category") || dn1."U_RBCNum" AS "TC No", dn1."U_RBCNum", dn1."U_Category", 
(SELECT "U_TCNum" FROM "@TC_NUM" WHERE "Name" = dn1."U_Category") ||
(SELECT SUM("Quantity") FROM dln1 WHERE "DocEntry" < dn1."DocEntry" AND "U_Category" = dn1."U_Category" AND "U_RBCReq" = 'YES') AS "Pre_TCnum", 
(SELECT "U_TCPrefix" FROM "@TC_NUM" WHERE "Name" = dn1."U_Category") AS "TC_Prefix", 
(SELECT "U_TCPrefix" FROM "@TC_NUM" WHERE "Code" = 'BC') || CAST(OSRN."U_TC_Num" AS char) AS "u_TC_NUM", DN7.U_ITEMDESC AS "ITEM DECRIPTION 3", 
DN7."U_issno" AS "ISSUE_NUMBER", CASE WHEN dln."U_tcaddrs" = 'Bill To' THEN dln."PayToCode" ELSE dln."ShipToCode" END AS "THIRD_PARTY" 

FROM ODLN dln 
INNER JOIN DLN1 dn1 ON dln."DocEntry" = dn1."DocEntry" 
LEFT OUTER JOIN OITM itm ON dn1."ItemCode" = itm."ItemCode" 
LEFT OUTER JOIN OITB itb ON itm."ItmsGrpCod" = itb."ItmsGrpCod" 
LEFT OUTER JOIN NNM1 NM1 ON NM1."Series" = dln."Series" 
LEFT OUTER JOIN CRD1 cd1 ON dln."CardCode" = cd1."CardCode" AND dln."PayToCode" = cd1."Address" AND "AddrType" = 'B' 
LEFT OUTER JOIN OWHS WHS ON dn1."WhsCode" = WHS."WhsCode" 
LEFT OUTER JOIN OLCT LCT ON dn1."LocCode" = LCT."Code" 
LEFT OUTER JOIN OCST CST ON LCT."State" = CST."Code" AND LCT."Country" = CST."Country" 
INNER JOIN OITL ON dn1."DocEntry" = OITL."ApplyEntry" AND dn1."LineNum" = OITL."ApplyLine" AND OITL."ApplyType" = 15 
INNER JOIN ITL1 ON OITL."LogEntry" = ITL1."LogEntry" 
INNER JOIN OSRN ON ITL1."ItemCode" = OSRN."ItemCode" AND ITL1."MdAbsEntry" = OSRN."AbsEntry" 
LEFT OUTER JOIN DLN8 DN8 ON DLN."DocEntry" = DN8."DocEntry" AND dn1."ItemCode" = dn8."ItemCode" 
LEFT OUTER JOIN DLN7 DN7 ON DN7."DocEntry" = DLN."DocEntry" AND DN7."PackageNum" = DN8."PackageNum" 
WHERE dn1."U_RBCReq" = 'YES'
