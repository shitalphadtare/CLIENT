alter view TestC_Report_OLD
as
SELECT dln."DocEntry", dln."CardName", dln."DocDate", NM1."SeriesName" || '/' || CAST(dln."DocNum" AS varchar) AS "Document Number", 
dln."NumAtCard" AS "PO NO", dln."U_BPRefDt" AS "PO DATE", CASE WHEN dln."U_tcaddrs" = 'Bill To' 
THEN dln."Address" ELSE dln."Address2" END AS "bill to address", dn1."ItemCode", 
IFNULL(dn1."U_ItemDesc3", dn1."Dscription") AS "Dscription", dn1."Quantity", dn1.U_TCDT AS "TEST DATE", 
dn1.U_PROOFLOAD AS "PROOF LOAD", dn1.U_SWL AS "SWL", '' AS "DISTING MARK", '' AS "TYPE OF",
 '' AS "SERIAL NO", dn1.U_LIFT AS "LIFT", 0 AS "Item Quanitity", dn1."VisOrder", '' AS "ItmsGrpNam", 
 (SELECT IFNULL(SUM(IFNULL("Quantity", 0)), 0) 
 FROM ODLN dln1 
 INNER JOIN dln1 dn2 ON DLN1."DocEntry" = dn2."DocEntry" 
 LEFT OUTER JOIN CRD1 CD2 ON DLN1."ShipToCode" = CD2."Address" AND "AdresType" = 'S'
  WHERE CANCELED <> 'Y' AND dln1."CardCode" = dln."CardCode" AND DLN1."DocEntry" < dln."DocEntry" AND CD2."County" = CD3."County" 
  AND dn2."U_RTCReq" = 'YES' AND year(DLN1."DocDate") = year(DLN1."DocDate") AND dln1."U_DTCWCReq" = 'TC'
   AND dn2."TargetType" <> 16) + IFNULL((SELECT CASE WHEN crd."CardFName" = cd1."County" THEN crd."U_markno" ELSE cd1."U_TC_Qty" END AS "a" 
      FROM ODLN dln1 
   LEFT OUTER JOIN OCRD crd ON dln1."CardCode" = crd."CardCode" 
   LEFT OUTER JOIN CRD1 cd1 ON dln1."CardCode" = cd1."CardCode" AND dln1."ShipToCode" = cd1."Address" AND cd1."AdresType" = 'S' 
   WHERE dln1."DocEntry" = dln."DocEntry" AND dln1."DocDate" < '20200101'), 0) AS "start_quantity",
    IFNULL((SELECT "CardFName" FROM OCRD WHERE "CardCode" = dln."CardCode") || '  -', '') || 
    (SELECT "Name" FROM "@TC_YR" WHERE "Code" = year(dln."DocDate")) AS "TC_YEAR", dln."TaxDate", dln.U_SIGN, 
    IFNULL((SELECT "U_TCPrefix" FROM "@TC_NUM" WHERE "Code" = 'TC'), '') || dln."U_DTCNum" AS "TC Number", 
    IFNULL(CD3."County" || '-', '') ||(SELECT "Name" FROM "@TC_YR" WHERE "Code" = year(dln."DocDate")) AS "COUNTY", 
    CASE WHEN dln."U_tcaddrs" = 'Bill To' THEN dln."PayToCode" ELSE dln."ShipToCode" END AS "THIRD_PARTY" 
    
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
    WHERE dln."U_DTCWCReq" = 'TC' AND dn1."U_RTCReq" = 'YES' AND dn1."TargetType" <> 16
