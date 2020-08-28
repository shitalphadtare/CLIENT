--Alter VIEW GST_TAX_INVOICE
--AS
SELECT INV."DocEntry" AS "Docentry", INV."DocNum" AS "Docnum", INV."DocCur", INV."DocDate" AS "Docdate", 
	INV."NumAtCard" AS "RefNo", inv."Project", NM1."SeriesName" AS "Docseries", 
(CASE WHEN nm1."BeginStr" IS NULL THEN IFNULL(NM1."BeginStr", n'') ELSE IFNULL(NM1."BeginStr", n'') END || ' ' || RTRIM(LTRIM(CAST(INV."DocNum" AS char(20)))) ||
 ' ' || (CASE WHEN nm1."EndStr" IS NULL THEN IFNULL(NM1."EndStr", n'') ELSE (IFNULL(NM1."EndStr", n'')) END)) AS "Invoice No", NM11."SeriesName" AS "ordseries", 
 nm11."SeriesName" || '/' || CAST(rdr."DocNum" AS varchar) AS "OrdNo", rdr."DocDate" AS "OrdDate", inv."NumAtCard" AS "suplier ref", INV."U_BPRefDt" AS "supDate", 
 nm2."SeriesName" || '/' || CAST(DLN."DocNum" AS varchar) AS "Challan No", DLN."DocDate" AS "Challan Date", INV."PayToCode" AS "BuyerName", 
 INV."Address" AS "BuyerAdd", INV."ShipToCode" AS "DeilName", INV."Address2" AS "DelAdd", LCT."Block", LCT."Street", WHS."StreetNo", LCT."Building", 
 LCT."City", LCT."Location", LCT."Country", LCT."ZipCode", LCT."GSTRegnNo" AS "LocationGSTNO", GTY."GSTType" AS "LocationGSTType", 
 (SELECT "GSTCode" FROM OCST WHERE "Code" = lct."State") AS "state", 
 (CASE WHEN INV."ExcRefDate" IS NULL THEN CAST(INV."DocTime" AS Time) ELSE INV."ExcRefDate" END) AS "Supply Time", 
 CST."Name" AS "Supply place", CASE WHEN SLP."SlpName" = '-No Sales Employee-' THEN '' ELSE SLP."SlpName" END AS "SalesPrsn", SLP."Mobil" AS "salesmob", SLP."Email" AS "SalesEmail", 
 (SELECT "Name" FROM OCST WHERE "Code" = IV12."StateS" AND "Country" = iv12."CountryS") AS "Delplaceofsupply", CPR."E_MailL" AS "CnctPrsnEmail", 
 (SELECT CRD1."GSTRegnNo" FROM CRD1 INNER JOIN OCRD ON OCRD."CardCode" = CRD1."CardCode" 
 WHERE OCRD."CardCode" = INV."CardCode" AND CRD1."AdresType" = 'S' AND INV."ShipToCode" = CRD1."Address") AS "ShipToGSTCode", GTY1."GSTType" AS "ShipToGSTType", 
 (SELECT "GSTCode" FROM OCST WHERE "Code" = IV12."StateS" AND "Country" = iv12."CountryS") AS "ShipToStateCode", 
 (SELECT "Name" FROM OCST WHERE "Code" = IV12."StateB" AND "Country" = iv12."CountryB") AS "BillToState", 
 (SELECT "GSTCode" FROM OCST WHERE "Code" = IV12."StateB" AND "Country" = iv12."CountryB") AS "BillToStateCode", 
 (SELECT GTY1."GSTType" FROM CRD1 CD1 LEFT OUTER JOIN OGTY GTY1 ON CD1."GSTType" = GTY1."AbsEntry" 
 WHERE CD1."CardCode" = INV."CardCode" AND cd1."Address" = inv."PayToCode" AND CD1."AdresType" = 'B') AS "BillToGSTType", 
 (SELECT DISTINCT CRD1."GSTRegnNo" FROM CRD1 INNER JOIN OCRD ON OCRD."CardCode" = CRD1."CardCode" WHERE OCRD."CardCode" = INV."CardCode" AND CRD1."AdresType" = 'B' 
 AND INV."PayToCode" = CRD1."Address") AS "BillToGSTCode", 
 (SELECT DISTINCT "TaxId0" FROM CRD7 WHERE INV."CardCode" = "CardCode" AND inv."ShipToCode" = CRD7."Address" AND "AddrType" = 's') AS "shipPANNo", 
 (SELECT DISTINCT CD7."TaxId0" FROM CRD7 cd7 WHERE INV."CardCode" = CD7."CardCode" AND inv."ShipToCode" = cd7."Address" AND CD7."AddrType" = 's') AS "bILLPANNo", 
 CPR."Name" AS "ContactPerson", CPR."Cellolar" AS "ContactMob", CPR."E_MailL" AS "ContactMail", cpr."Title", cst."GSTCode", IV1."LineNum", IV1."ItemCode", 
 CASE WHEN iv1."U_ItemDesc2" IS NULL OR iv1."U_ItemDesc2" = '' THEN iv1."Dscription" ELSE iv1."U_ItemDesc2" END AS "Dscription", 
 (CASE WHEN ITM."ItemClass" = 1 THEN (SELECT "ServCode" FROM OSAC WHERE "AbsEntry" = (CASE WHEN IV1."HsnEntry" IS NULL THEN ITM."SACEntry" ELSE IV1."HsnEntry" END)) 
 WHEN ITM."ItemClass" = 2 THEN (SELECT "ChapterID" FROM OCHP WHERE "AbsEntry" = (CASE WHEN IV1."HsnEntry" IS NULL THEN ITM."ChapterID" ELSE IV1."HsnEntry" END)) ELSE '' END) AS "HSN Code", 
 (SELECT "ServCode" FROM OSAC WHERE "AbsEntry" = IV1."SacEntry") AS "Service_SAC_Code", IV1."Quantity", IV1."unitMsr", IV1."PriceBefDi", IV1."DiscPrcnt", 
 (IV1."Quantity" * IV1."PriceBefDi") AS "TotalAmt", ((IFNULL(IV1."PriceBefDi", 0) - IFNULL(IV1."Price", 0)) * IFNULL(IV1."Quantity", 0)) AS "ItmDiscAmt", 
 CASE WHEN OCRN."CurrCode" = 'INR' THEN (IFNULL(IV1."LineTotal", 0) * (IFNULL(INV."DiscPrcnt", 0) / 100)) ELSE (IFNULL(IV1."TotalFrgn", 0) * 
 (IFNULL(INV."DiscPrcnt", 0) / 100)) END AS "DocDiscAmt", CASE WHEN INV."DiscPrcnt" = 0 THEN ((IFNULL(IV1."PriceBefDi", 0) - IFNULL(IV1."Price", 0)) * IFNULL(IV1."Quantity", 0)) ELSE 
 ((CASE WHEN OCRN."CurrCode" = 'INR' THEN IFNULL(IV1."LineTotal", 0) ELSE IFNULL(IV1."TotalFrgn", 0) END) * (IFNULL(INV."DiscPrcnt", 0) / 100)) END AS "DiscAmt", IV1."Price", 
 CASE WHEN OCRN."CurrCode" = 'INR' THEN IFNULL(IV1."LineTotal", 0) ELSE IFNULL(IV1."TotalFrgn", 0) END AS "LineTotal", CASE WHEN OCRN."CurrCode" = 'INR' THEN 
 (CASE WHEN INV."DiscPrcnt" = 0 THEN IFNULL(IV1."LineTotal", 0) ELSE (IFNULL(IV1."LineTotal", 0) - (IFNULL(IV1."LineTotal", 0) * IFNULL(INV."DiscPrcnt", 0) / 100)) END) 
 ELSE (CASE WHEN INV."DiscPrcnt" = 0 THEN IFNULL(IV1."TotalFrgn", 0) ELSE (IFNULL(IV1."TotalFrgn", 0) - (IFNULL(IV1."TotalFrgn", 0) * IFNULL(INV."DiscPrcnt", 0) / 100)) END) END AS "Total", 
 CASE WHEN IV1."AssblValue" = 0 THEN (CASE WHEN INV."DiscPrcnt" = 0 THEN (CASE WHEN OCRN."CurrCode" = 'INR' THEN IFNULL(IV1."LineTotal", 0) ELSE IFNULL(IV1."TotalFrgn", 0) END) ELSE 
 ((CASE WHEN OCRN."CurrCode" = 'INR' THEN IFNULL(IV1."LineTotal", 0) ELSE IFNULL(IV1."TotalFrgn", 0) END) - ((CASE WHEN OCRN."CurrCode" = 'INR' THEN IFNULL(IV1."LineTotal", 0) 
 ELSE IFNULL(IV1."TotalFrgn", 0) END) * IFNULL(INV."DiscPrcnt", 0) / 100)) END) ELSE (IV1."AssblValue" * IV1."Quantity") END AS "TotalAsseble", CGST."TaxRate" AS "CGSTRate", 
 CASE WHEN OCRN."CurrCode" = 'INR' THEN CGST."TaxSum" ELSE CGST."TaxSumFrgn" END AS "CGST", SGST."TaxRate" AS "SGSTRate", CASE WHEN OCRN."CurrCode" = 'INR' THEN SGST."TaxSum" ELSE SGST."TaxSumFrgn" 
 END AS "SGST", IGST."TaxRate" AS "IGSTRate", CASE WHEN OCRN."CurrCode" = 'INR' THEN IGST."TaxSum" ELSE IGST."TaxSumFrgn" END AS "IGST", 
 CASE WHEN OCRN."CurrCode" = 'INR' THEN INV."DocTotal" ELSE INV."DocTotalFC" END AS "DocTotal", CASE WHEN OCRN."CurrCode" = 'INR' THEN INV."RoundDif" ELSE INV."RoundDifFC" END AS "RoundDif", 
 OCRN."CurrName" AS "Currencyname", OCRN."F100Name" AS "Hundredthname", OCT."PymntGroup" AS "Payment Terms", INV."Comments" AS "Remark", INV."Header" AS "Opening Remark", 
 INV."Footer" AS "Closing Remark", iv1."U_ItemDesc2" AS "desc", shp."TrnspName", inv."U_Terms_Del", inv."ShipToCode", inv."U_Port_Dish" AS "despatch thr", inv.U_OTHEREF AS "Despatchdocnum", 
 inv."U_Place_Receipt" AS "Segment", iv1."U_ItemDesc2", iv1."U_ItemDesc3", inv."U_LRDate", inv."U_LRNo", inv."U_Transporter", inv."U_VehNo", INV.U_SHIPNAME, inv."CardCode" 
 
 FROM OINV INV 
 INNER JOIN INV1 IV1 ON IV1."DocEntry" = INV."DocEntry" 
 LEFT OUTER JOIN NNM1 NM1 ON INV."Series" = NM1."Series" 
 LEFT OUTER JOIN OSLP SLP ON INV."SlpCode" = SLP."SlpCode" 
 LEFT OUTER JOIN OWHS WHS ON IV1."WhsCode" = WHS."WhsCode" 
 LEFT OUTER JOIN OLCT LCT ON IV1."LocCode" = LCT."Code" 
 LEFT OUTER JOIN OGTY GTY ON LCT."GSTType" = GTY."AbsEntry" 
 LEFT OUTER JOIN OCST CST ON LCT."State" = CST."Code" AND LCT."Country" = CST."Country" 
 LEFT OUTER JOIN DLN1 DN1 ON IV1."BaseEntry" = DN1."DocEntry" AND IV1."BaseLine" = DN1."LineNum" AND IV1."BaseType" = DN1."ObjType" 
 LEFT OUTER JOIN ODLN DLN ON DLN."DocEntry" = DN1."DocEntry" 
 LEFT OUTER JOIN NNM1 NM2 ON DLN."Series" = NM2."Series" 
 LEFT OUTER JOIN RDR1 RR1 ON DN1."BaseEntry" = RR1."DocEntry" AND DN1."BaseLine" = RR1."LineNum" 
 LEFT OUTER JOIN ORDR RDR ON RR1."DocEntry" = RDR."DocEntry" 
 LEFT OUTER JOIN OCRN ON INV."DocCur" = OCRN."CurrCode" 
 LEFT OUTER JOIN OCTG OCT ON INV."GroupNum" = OCT."GroupNum" 
 LEFT OUTER JOIN CRD1 CD1 ON CD1."CardCode" = INV."CardCode" AND CD1."AdresType" = 'S' AND INV."ShipToCode" = CD1."Address" 
 LEFT OUTER JOIN INV12 IV12 ON IV12."DocEntry" = INV."DocEntry" 
 LEFT OUTER JOIN OCST CST1 ON CST1."Code" = IV12."BpStateCod" AND CST1."Country" = IV12."CountryS" 
 LEFT OUTER JOIN OGTY GTY1 ON CD1."GSTType" = GTY1."AbsEntry" 
 LEFT OUTER JOIN OCPR CPR ON INV."CardCode" = CPR."CardCode" AND INV."CntctCode" = CPR."CntctCode" 
 LEFT OUTER JOIN OITM ITM ON ITM."ItemCode" = IV1."ItemCode" 
 LEFT OUTER JOIN NNM1 NM11 ON RDR."Series" = NM11."Series" 
 LEFT OUTER JOIN INV4 CGST ON IV1."DocEntry" = CGST."DocEntry" AND IV1."LineNum" = CGST."LineNum" AND CGST."staType" IN (-100) AND CGST."RelateType" = 1 
 LEFT OUTER JOIN INV4 SGST ON IV1."DocEntry" = SGST."DocEntry" AND IV1."LineNum" = SGST."LineNum" AND SGST."staType" IN (-110) AND SGST."RelateType" = 1 
 LEFT OUTER JOIN INV4 IGST ON IV1."DocEntry" = IGST."DocEntry" AND IV1."LineNum" = IGST."LineNum" AND IGST."staType" IN (-120) AND IGST."RelateType" = 1 
 LEFT OUTER JOIN OSHP shp ON inv."TrnspCode" = shp."TrnspCode"









