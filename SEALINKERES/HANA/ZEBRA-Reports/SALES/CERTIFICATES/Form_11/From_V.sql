alter view From_V as
SELECT dln."DocEntry", dln."CardName", dln."DocDate", NM1."SeriesName" || '/' || CAST(dln."DocNum" AS varchar) AS "Document Number", 
dln."NumAtCard" AS "PO NO", dln."U_BPRefDt" AS "PO DATE", CASE WHEN dln."U_tcaddrs" = 'Bill To' THEN dln."Address" ELSE dln."Address2" END AS "bill to address", 
dn1."ItemCode", IFNULL(dn1."U_ItemDesc3", dn1."Dscription") AS "Dscription", dn1."Quantity", DN7.U_TCDT AS "TEST DATE", 
dn7.U_PRROFLOAD AS "PROOF LOAD", DN7.U_SWL AS "SWL", '' AS "DISTING MARK", '' AS "TYPE OF", '' AS "SERIAL NO", 
dn7.U_LIFT AS "LIFT", 0 AS "Item Quanitity", dn1."VisOrder", '' AS "ItmsGrpNam", 
(SELECT IFNULL(SUM(IFNULL("Quantity", 0)), 0) FROM ODLN dln1 INNER JOIN dln1 dn2 ON DLN1."DocEntry" = dn2."DocEntry" 
LEFT OUTER JOIN CRD1 CD2 ON DLN1."ShipToCode" = CD2."Address" AND "AdresType" = 'S' AND cd2."CardCode" = dln1."CardCode" 
WHERE CANCELED <> 'Y' AND dln1."CardCode" = dln."CardCode" AND DLN1."DocEntry" < dln."DocEntry" AND CD2."County" = CD3."County" 
AND CAST(CAST(year(NOW()) AS char(4)) || '0401' AS date) <= CAST(CAST(year(dln."DocDate") AS char(4)) || '0401' AS date) AND dln1."U_DFVReq" = 'YES' 
AND dn2."U_TCReq" = 'YES' AND dn2."TargetType" <> 16) + 
IFNULL((SELECT "U_markno" FROM OCRD WHERE "CardCode" = dln."CardCode" AND NOW() < '20200401'), 0) AS "start_quantity", 
IFNULL((SELECT "CardFName" FROM OCRD WHERE "CardCode" = dln."CardCode") || '  -', '') || (SELECT "Name" FROM "@TC_YR" WHERE "Code" = year(dln."DocDate")) AS "TC_YEAR", 
dln."TaxDate", IFNULL((SELECT "U_TCPrefix" FROM "@TC_NUM" WHERE "Code" = 'FV'), '') || dln."U_DFVNum" AS "TC Number", dln.U_SHIP, dln.U_SHIPNAME, dln."U_OffNum", 
dln."U_Csign", dln."U_Poreg", dln."U_Owner", IFNULL(CD3."County" || '-', '') ||(SELECT "Name" FROM "@TC_YR" WHERE "Code" = year(dln."DocDate")) AS "COUNTY", 
DN7.U_ITEMDESC AS "ITEM DECRIPTION 3", CASE WHEN DN7.U_ITEMDESC IS NULL OR CAST(dn7.U_ITEMDESC AS nvarchar(5000)) = '' THEN dn1."U_ItemDesc3" 
ELSE dn7.U_ITEMDESC END AS "Dscription ALT", DN7."U_issno" AS "ISSUE_NUMBER", 
CASE WHEN dln."U_tcaddrs" = 'Bill To' THEN dln."PayToCode" ELSE dln."ShipToCode" END AS "THIRD_PARTY" 

FROM ODLN dln 
INNER JOIN DLN1 dn1 ON dln."DocEntry" = dn1."DocEntry" 
LEFT OUTER JOIN CRD1 CD3 ON DLN."ShipToCode" = CD3."Address" AND CD3."AdresType" = 'S' AND cd3."CardCode" = dln."CardCode" 
LEFT OUTER JOIN OITM itm ON dn1."ItemCode" = itm."ItemCode" 
LEFT OUTER JOIN OITB itb ON itm."ItmsGrpCod" = itb."ItmsGrpCod" 
LEFT OUTER JOIN NNM1 NM1 ON NM1."Series" = dln."Series" 
LEFT OUTER JOIN CRD1 cd1 ON dln."CardCode" = cd1."CardCode" AND dln."PayToCode" = cd1."Address" AND CD1."AddrType" = 'B' AND cd1."CardCode" = dln."CardCode" 
LEFT OUTER JOIN OWHS WHS ON dn1."WhsCode" = WHS."WhsCode" 
LEFT OUTER JOIN OLCT LCT ON dn1."LocCode" = LCT."Code"
LEFT OUTER JOIN OCST CST ON LCT."State" = CST."Code" AND LCT."Country" = CST."Country" 
LEFT OUTER JOIN DLN8 DN8 ON DLN."DocEntry" = DN8."DocEntry" AND dn1."ItemCode" = dn8."ItemCode" 
LEFT OUTER JOIN DLN7 DN7 ON DN7."DocEntry" = DLN."DocEntry" AND DN7."PackageNum" = DN8."PackageNum" 
WHERE dln."U_DFVReq" = 'YES' AND dn1."U_TCReq" = 'YES' AND dn1."TargetType" <> 16