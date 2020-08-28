
Create VIEW GST_DELIVERY_CHALLAN
AS

SELECT DLN."DocEntry" AS "Docentry", DLN."DocNum" AS "Docnum", DLN."DocCur", NM1."SeriesName" AS "Docseries", 
DLN."DocDate" AS "Docdate", 
(CASE WHEN nm1."BeginStr" IS NULL THEN IFNULL(NM1."BeginStr", '') ELSE IFNULL(NM1."BeginStr", '') END || RTRIM(LTRIM(CAST(DLN."DocNum" AS char(20)))) 
|| (CASE WHEN nm1."EndStr" IS NULL THEN IFNULL(NM1."EndStr", '') ELSE (IFNULL(NM1."EndStr", '')) END)) AS "Invoice No", 
DLN."NumAtCard" AS "RefNo", NM11."SeriesName" AS "ordseries", DLN."NumAtCard" AS "OrdNo", DLN."U_BPRefDt" AS "OrdDate", 
DLN."PayToCode" AS "BuyerName", DLN."Address" AS "BuyerAdd", DLN."ShipToCode" AS "DeilName", DLN."Address2" AS "DelAdd", LCT."Block", 
LCT."Street", WHS."StreetNo", LCT."Building", LCT."City", LCT."Location", LCT."Country", LCT."ZipCode", LCT."GSTRegnNo" AS "LocationGSTNO" 
,GTY."GSTType" AS "LocationGSTType", 
(CASE WHEN DLN."ExcRefDate" IS NULL THEN CAST(DLN."DocTime" AS Time) ELSE DLN."ExcRefDate" END) AS "Supply Time", 

CST."Name" AS "Supply place", CASE WHEN SLP."SlpName" = '-No Sales Employee-' THEN '' ELSE SLP."SlpName" END AS "SalesPrsn", 
SLP."Mobil" AS "salesmob", SLP."Email" AS "SalesEmail", CPR."Name" AS "CnctName", 
CPR."Cellolar" AS "CnctMob", 
(SELECT "Name" FROM OCST WHERE "Code" = DC12."StateS" AND "Country" = DC12."CountryS") AS "Delplaceofsupply", CPR."E_MailL" AS "CnctPrsnEmail", 
(SELECT CRD1."GSTRegnNo" FROM CRD1 INNER JOIN OCRD ON OCRD."CardCode" = CRD1."CardCode" 
WHERE OCRD."CardCode" = DLN."CardCode" AND CRD1."AdresType" = 'S' AND DLN."ShipToCode" = CRD1."Address") AS "ShipToGSTCode", 
GTY1."GSTType" AS "ShipToGSTType", 
(SELECT "GSTCode" FROM OCST WHERE "Code" = DC12."StateS" AND "Country" = DC12."CountryS") AS "ShipToStateCode", 
(SELECT "Name" FROM OCST WHERE "Code" = DC12."StateB" AND "Country" = DC12."CountryB") AS "BillToState", 
(SELECT "GSTCode" FROM OCST WHERE "Code" = DC12."StateB" AND "Country" = DC12."CountryB") AS "BillToStateCode", 
(SELECT GTY1."GSTType" FROM CRD1 CD1 LEFT OUTER JOIN OGTY GTY1 ON CD1."GSTType" = GTY1."AbsEntry" 
WHERE CD1."CardCode" = DLN."CardCode" AND cd1."Address" = DLN."PayToCode" AND CD1."AdresType" = 'B') AS "BillToGSTType", 
(SELECT DISTINCT CRD1."GSTRegnNo" FROM CRD1 INNER JOIN OCRD ON OCRD."CardCode" = CRD1."CardCode" 
WHERE OCRD."CardCode" = DLN."CardCode" AND CRD1."AdresType" = 'B' AND DLN."PayToCode" = CRD1."Address") AS "BillToGSTCode", 
(SELECT DISTINCT "TaxId0" FROM CRD7 WHERE DLN."CardCode" = "CardCode" AND DLN."ShipToCode" = CRD7."Address" AND "AddrType" = 's') AS "shipPANNo", 
(SELECT DISTINCT CD7."TaxId0" FROM CRD7 cd7 WHERE DLN."CardCode" = CD7."CardCode" AND DLN."ShipToCode" = cd7."Address" AND CD7."AddrType" = 's') AS "bILLPANNo", 
CPR."Name" AS "ContactPerson", CPR."Cellolar" AS "ContactMob", 
CPR."E_MailL" AS "ContactMail", cpr."Title", cst."GSTCode"

,DN1."LineNum", DN1."ItemCode", CASE WHEN dn1."U_ItemDesc2" = '' OR dn1."U_ItemDesc2" IS NULL THEN dn1."Dscription" ELSE dn1."U_ItemDesc2" END AS "Dscription", 
(CASE WHEN ITM."ItemClass" = 1 THEN (SELECT "ServCode" FROM OSAC WHERE "AbsEntry" = 
(CASE WHEN DN1."SacEntry" = NULL THEN ITM."SACEntry" ELSE DN1."SacEntry" END)) WHEN ITM."ItemClass" = 2 
THEN (SELECT "ChapterID" FROM OCHP WHERE "AbsEntry" = (CASE WHEN DN1."HsnEntry" = NULL THEN ITM."ChapterID" ELSE DN1."HsnEntry" END)) ELSE '' END) AS "HSN Code", 
(SELECT "ServCode" FROM OSAC WHERE "AbsEntry" = DN1."SacEntry") AS "Service_SAC_Code", DN1."Quantity", DN1."unitMsr", DN1."PriceBefDi", DN1."DiscPrcnt", 
(IFNULL(DN1."Quantity", 0) * IFNULL(DN1."PriceBefDi", 0)) AS "TotalAmt", ((IFNULL(DN1."PriceBefDi", 0) - IFNULL(DN1."Price", 0)) * IFNULL(DN1."Quantity", 0)) AS "ItmDiscAmt", 
((CASE WHEN OCRN."CurrCode" = 'INR' THEN IFNULL(DN1."LineTotal", 0) ELSE IFNULL(DN1."TotalFrgn", 0) END) * (IFNULL(DLN."DiscPrcnt", 0) / 100)) AS "DocDiscAmt", 
CASE WHEN DLN."DiscPrcnt" = 0 THEN ((IFNULL(DN1."PriceBefDi", 0) - IFNULL(DN1."Price", 0)) * IFNULL(DN1."Quantity", 0)) ELSE 
((CASE WHEN OCRN."CurrCode" = 'INR' THEN IFNULL(DN1."LineTotal", 0) ELSE IFNULL(DN1."TotalFrgn", 0) END) * (IFNULL(DLN."DiscPrcnt", 0) / 100)) END AS "DiscAmt", 
DN1."Price", CASE WHEN OCRN."CurrCode" = 'INR' THEN IFNULL(DN1."LineTotal", 0) ELSE IFNULL(DN1."TotalFrgn", 0) END AS "LineTotal", 
CASE WHEN OCRN."CurrCode" = 'INR' THEN (CASE WHEN DLN."DiscPrcnt" = 0 THEN IFNULL(DN1."LineTotal", 0) ELSE (IFNULL(DN1."LineTotal", 0) - (IFNULL(DN1."LineTotal", 0) * 
IFNULL(DLN."DiscPrcnt", 0) / 100)) END) ELSE (CASE WHEN DLN."DiscPrcnt" = 0 THEN IFNULL(DN1."TotalFrgn", 0) ELSE (IFNULL(DN1."TotalFrgn", 0) - (IFNULL(DN1."TotalFrgn", 0) * 
IFNULL(DLN."DiscPrcnt", 0) / 100)) END) END AS "Total", CASE WHEN DN1."AssblValue" = 0 THEN (CASE WHEN DLN."DiscPrcnt" = 0 THEN 
(CASE WHEN OCRN."CurrCode" = 'INR' THEN IFNULL(DN1."LineTotal", 0) ELSE IFNULL(DN1."TotalFrgn", 0) END) ELSE 
((CASE WHEN OCRN."CurrCode" = 'INR' THEN IFNULL(DN1."LineTotal", 0) ELSE IFNULL(DN1."TotalFrgn", 0) END) - ((CASE WHEN OCRN."CurrCode" = 'INR' 
THEN IFNULL(DN1."LineTotal", 0) ELSE IFNULL(DN1."TotalFrgn", 0) END) * IFNULL(DLN."DiscPrcnt", 0) / 100)) END) ELSE (IFNULL(DN1."AssblValue", 0) * 
IFNULL(DN1."Quantity", 0)) END AS "TotalAsseble"
, CGST."TaxRate" AS "CGSTRate"
, CASE WHEN OCRN."CurrCode" = 'INR' THEN CGST."TaxSum" ELSE CGST."TaxSumFrgn" END AS "CGST", 
SGST."TaxRate" AS "SGSTRate", 
CASE WHEN OCRN."CurrCode" = 'INR' THEN SGST."TaxSum" ELSE SGST."TaxSumFrgn" END AS "SGST", 
IGST."TaxRate" AS "IGSTRate", 
CASE WHEN OCRN."CurrCode" = 'INR' THEN IGST."TaxSum" ELSE IGST."TaxSumFrgn" END AS "IGST" 

,CASE WHEN OCRN."CurrCode" = 'INR' THEN DLN."DocTotal" ELSE DLN."DocTotalFC" END AS "DocTotal", 
CASE WHEN OCRN."CurrCode" = 'INR' THEN DLN."RoundDif" ELSE DLN."RoundDifFC" END AS "RoundDif", 
OCRN."CurrName" AS "Currencyname", OCRN."F100Name" AS "Hundredthname", OCT."PymntGroup" AS "Payment Terms", 
DLN."Comments" AS "Remark", DLN."Header" AS "Opening Remark", DLN."Footer" AS "Closing Remark", dln."U_VehNo" AS "Vehicleno", 
shp."TrnspName", DN1."U_ItemDesc2", DN1."U_ItemDesc3", DLN."CardCode", DLN.U_SHIP
FROM ODLN DLN INNER JOIN DLN1 DN1 ON DN1."DocEntry" = DLN."DocEntry" 
LEFT OUTER JOIN DLN12 DC12 ON DC12."DocEntry" = DLN."DocEntry" 
LEFT OUTER JOIN NNM1 NM1 ON DLN."Series" = NM1."Series" 
LEFT OUTER JOIN OSLP SLP ON DLN."SlpCode" = SLP."SlpCode" 
LEFT OUTER JOIN OWHS WHS ON DN1."WhsCode" = WHS."WhsCode" 
LEFT OUTER JOIN OLCT LCT ON DN1."LocCode" = LCT."Code" 
LEFT OUTER JOIN OGTY GTY ON LCT."GSTType" = GTY."AbsEntry" 
LEFT OUTER JOIN OCST CST ON LCT."State" = CST."Code" AND LCT."Country" = CST."Country" 
LEFT OUTER JOIN RDR1 RR1 ON DN1."BaseEntry" = RR1."DocEntry" AND DN1."BaseLine" = RR1."LineNum" 
LEFT OUTER JOIN ORDR RDR ON RR1."DocEntry" = RDR."DocEntry" 
LEFT OUTER JOIN OCRN ON DLN."DocCur" = OCRN."CurrCode" 
LEFT OUTER JOIN OCTG OCT ON DLN."GroupNum" = OCT."GroupNum" 
LEFT OUTER JOIN CRD1 CD1 ON CD1."CardCode" = DLN."CardCode" AND CD1."AdresType" = 'S' AND DLN."ShipToCode" = CD1."Address" 
LEFT OUTER JOIN DLN12 DN12 ON DN12."DocEntry" = DLN."DocEntry" 
LEFT OUTER JOIN OCST CST1 ON CST1."Code" = DN12."BpStateCod" AND CST1."Country" = DN12."CountryS" 
LEFT OUTER JOIN OGTY GTY1 ON CD1."GSTType" = GTY1."AbsEntry" 
LEFT OUTER JOIN OCPR CPR ON DLN."CardCode" = CPR."CardCode" AND DLN."CntctCode" = CPR."CntctCode" 
LEFT OUTER JOIN OITM ITM ON ITM."ItemCode" = DN1."ItemCode" 
LEFT OUTER JOIN NNM1 NM11 ON RDR."Series" = NM11."Series" 
LEFT OUTER JOIN DLN4 CGST ON DN1."DocEntry" = CGST."DocEntry" AND DN1."LineNum" = CGST."LineNum" AND CGST."staType" IN (-100) AND CGST."RelateType" = 1 
LEFT OUTER JOIN DLN4 SGST ON DN1."DocEntry" = SGST."DocEntry" AND DN1."LineNum" = SGST."LineNum" AND SGST."staType" IN (-110) AND SGST."RelateType" = 1 
LEFT OUTER JOIN DLN4 IGST ON DN1."DocEntry" = IGST."DocEntry" AND DN1."LineNum" = IGST."LineNum" AND IGST."staType" IN (-120) AND IGST."RelateType" = 1 
LEFT OUTER JOIN OSHP shp ON shp."TrnspCode" = dln."TrnspCode"