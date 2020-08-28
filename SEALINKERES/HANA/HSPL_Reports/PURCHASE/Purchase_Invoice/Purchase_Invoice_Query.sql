--CREATE VIEW GST_PURCHASE_INVOICE
--AS
Select 
PCH."DocEntry" AS "Docentry", PCH."DocNum" AS "Docnum", PCH."DocCur", NM1."SeriesName" AS "Docseries", PCH."DocDate" AS "Docdate", 
(CASE WHEN nm1."BeginStr" IS NULL THEN IFNULL(NM1."BeginStr", n'') ELSE IFNULL(NM1."BeginStr", n'') END || RTRIM(LTRIM(CAST(PCH."DocNum" AS char(20)))) || 
(CASE WHEN nm1."EndStr" IS NULL THEN IFNULL(NM1."EndStr", n'') ELSE (IFNULL(NM1."EndStr", n'')) END)) AS "Purchase No", PCH."CardName" AS "VName", PCH."Address" AS "VendorAdd", 
CPR."Name" AS "V_CNCTP_N", cpr."Cellolar" AS "V_mobileNo", CPR."E_MailL" AS "V_CnctP_E", VShipFrom."Block", VShipFrom."Building", VShipFrom."Street", VShipFrom."City", 
VShipFrom."ZipCode", (SELECT DISTINCT "Name" FROM OCRY WHERE "Code" = VShipFrom."Country") AS "country", VShipFrom."StreetNo" AS "Street No_Vendor", 
(SELECT DISTINCT "Name" FROM OCST WHERE "Code" = VShipFrom."State" AND VShipFrom1."Country" = OCST."Country") AS "STATE_Vendor", VShipFrom1."GSTRegnNo" AS "VShipGSTNo", 
GTY2."GSTType" AS "VShipGSTType", PCH."NumAtCard" AS "SupRefNo"
,'' "SupDate"
, ( select
	 STRING_AGG("B"."A",
	 ',') 
	from ( SELECT
	 Distinct(Cast(OPRQ."DocNum" AS CHAR(7))) "A",
	 POR1."DocEntry" 
		FROM OPRQ 
		inner join PCH1 POR1 on OPRQ."DocEntry"=POR1."BaseEntry" 
		and POR1."DocEntry"=pch."DocEntry" ) "B" 
	group by "B"."DocEntry" )  "PR No"
, ( select
	 STRING_AGG("B"."A",
	 ',') 
	from ( SELECT
	 Distinct TO_VARCHAR(OPRQ."DocDate",
	 'DD-MM-YYYY') "A",
	 POR1."DocEntry" 
		FROM OPRQ 
		inner join pch1 POR1 on OPRQ."DocEntry"=POR1."BaseEntry" 
		and POR1."DocEntry"=pch."DocEntry" ) "B" 
	group by "B"."DocEntry") "PR Date"
,PCH."DocDueDate" AS "DeliDate", SHP."TrnspName" AS "Deli_Mode", PCH."Address2" AS "Deli_Addr", LCT."GSTRegnNo" AS "Deli_GST", GTY."GSTType" AS "Deli_GSTType", 
PCH."PayToCode" AS "BuyerName", PCH."ShipToCode" AS "DeilName", CASE WHEN SLP."SlpName" = '-No Sales Employee-' THEN '' ELSE SLP."SlpName" END AS "SalesPrsn", 

SLP."Mobil" AS "salesmob", SLP."Email" AS "SalesEmail"
-------------------------------------------------------------------------
,CPR."E_MailL" AS "CnctPrsnEmail", PH1."LineNum", PH1."ItemCode", PH1."Dscription",
 (CASE WHEN ITM."ItemClass" = 1 THEN (SELECT "ServCode" FROM OSAC WHERE "AbsEntry" = (CASE WHEN PH1."HsnEntry" IS NULL THEN ITM."SACEntry" ELSE PH1."HsnEntry" END))
 WHEN ITM."ItemClass" = 2 THEN (SELECT "ChapterID" FROM OCHP WHERE "AbsEntry" = (CASE WHEN PH1."HsnEntry" IS NULL THEN ITM."ChapterID" ELSE PH1."HsnEntry" END)) ELSE '' END) AS "HSN Code", 
 (SELECT "ServCode" FROM OSAC WHERE "AbsEntry" = PH1."SacEntry") AS "Service_SAC_Code", PH1."Quantity", PH1."unitMsr", PH1."PriceBefDi", PH1."DiscPrcnt", 
 (PH1."Quantity" * IFNULL(PH1."PriceBefDi", 0)) AS "TotalAmt", ((IFNULL(PH1."PriceBefDi", 0) - PH1."Price") * PH1."Quantity") AS "ItmDiscAmt", 
 ((CASE WHEN OCRN."CurrCode" = 'INR' THEN IFNULL(PH1."LineTotal", 0) ELSE IFNULL(PH1."TotalFrgn", 0) END) * (IFNULL(PCH."DiscPrcnt", 0) / 100)) AS "DocDiscAmt", 
 CASE WHEN PCH."DiscPrcnt" = 0 THEN ((IFNULL(PH1."PriceBefDi", 0) - PH1."Price") * PH1."Quantity") ELSE ((CASE WHEN OCRN."CurrCode" = 'INR' THEN IFNULL(PH1."LineTotal", 0) ELSE 
 IFNULL(PH1."TotalFrgn", 0) END) * (IFNULL(PCH."DiscPrcnt", 0) / 100)) END AS "DiscAmt", PH1."Price", CASE WHEN OCRN."CurrCode" = 'INR' THEN IFNULL(PH1."LineTotal", 0) ELSE 
 IFNULL(PH1."TotalFrgn", 0) END AS "LineTotal", CASE WHEN OCRN."CurrCode" = 'INR' THEN (CASE WHEN PCH."DiscPrcnt" = 0 THEN IFNULL(PH1."LineTotal", 0) ELSE (IFNULL(PH1."LineTotal", 0) - 
 (IFNULL(PH1."LineTotal", 0) * IFNULL(PCH."DiscPrcnt", 0) / 100)) END) ELSE (CASE WHEN PCH."DiscPrcnt" = 0 THEN IFNULL(PH1."TotalFrgn", 0) ELSE (IFNULL(PH1."TotalFrgn", 0) - 
 (IFNULL(PH1."TotalFrgn", 0) * IFNULL(PCH."DiscPrcnt", 0) / 100)) END) END AS "Total", CASE WHEN PH1."AssblValue" = 0 THEN (CASE WHEN PCH."DiscPrcnt" = 0 THEN 
 (CASE WHEN OCRN."CurrCode" = 'INR' THEN IFNULL(PH1."LineTotal", 0) ELSE IFNULL(PH1."TotalFrgn", 0) END) ELSE ((CASE WHEN OCRN."CurrCode" = 'INR' THEN IFNULL(PH1."LineTotal", 0) 
 ELSE IFNULL(PH1."TotalFrgn", 0) END) - ((CASE WHEN OCRN."CurrCode" = 'INR' THEN IFNULL(PH1."LineTotal", 0) ELSE IFNULL(PH1."TotalFrgn", 0) END) * IFNULL(PCH."DiscPrcnt", 0) / 100)) END) ELSE 
 (PH1."AssblValue" * PH1."Quantity") END AS "TotalAsseble", 
 CGST."TaxRate" AS "CGSTRate", CASE WHEN OCRN."CurrCode" = 'INR' THEN CGST."TaxSum" ELSE CGST."TaxSumFrgn" END AS "CGST", 
 SGST."TaxRate" AS "SGSTRate", CASE WHEN OCRN."CurrCode" = 'INR' THEN SGST."TaxSum" ELSE SGST."TaxSumFrgn" END AS "SGST", 
 IGST."TaxRate" AS "IGSTRate", CASE WHEN OCRN."CurrCode" = 'INR' THEN IGST."TaxSum" ELSE IGST."TaxSumFrgn" END AS "IGST",
  CASE WHEN OCRN."CurrCode" = 'INR' THEN PCH."DocTotal" ELSE PCH."DocTotalFC" END AS "DocTotal", 
  CASE WHEN OCRN."CurrCode" = 'INR' THEN PCH."RoundDif" ELSE PCH."RoundDifFC" END AS "RoundDif", OCRN."CurrName" AS "Currencyname", OCRN."F100Name" AS "Hundredthname", 
  OCT."PymntGroup" AS "Payment Terms", PCH."Comments" AS "Remark", PCH."Header" AS "Opening Remark", PCH."Footer" AS "Closing Remark", PRJ."PrjName" AS "PrjName", PH1."ShipDate" AS "ShipDate", 
  PCH."U_OCNo" AS "U_OC_No", CPR."Cellolar"
,case when PCH."U_Terms_Del"  is null or PCH."U_Terms_Del" = '' then '' else   PCH."U_Terms_Del" end "Delivery",
case when PCH."U_Terms_Pay"   is null or PCH."U_Terms_Pay"  = '' then '' else   PCH."U_Terms_Pay"  end "Payment",
case when PCH."U_Terms_Insp"  is null or PCH."U_Terms_Insp" = '' then '' else  PCH."U_Terms_Insp"  end "Ispection",
case when PCH."U_Terms_Price"  is null or PCH."U_Terms_Price" = '' then '' else  PCH."U_Terms_Price"  end "Terms_Price",
case when PCH."U_Terms_PackInst"  is null or PCH."U_Terms_PackInst"  = '' then '' else  PCH."U_Terms_PackInst"  end "Packing Instruction",
case when PCH."U_Terms_Insu"  is null or PCH."U_Terms_Insu" = '' then '' else  PCH."U_Terms_Insu"   end "Insurance",
case when PCH."U_Terms_Frt" is null or PCH."U_Terms_Frt" = '' then '' else  PCH."U_Terms_Frt"  end "Freight",
case when PCH."U_Terms_PNF"  is null or PCH."U_Terms_PNF"  = '' then '' else  PCH."U_Terms_PNF"  end "P & N",
 PCH."U_BPRefDt", PH1."ShipDate" AS "DueOn", PCH."U_Terms_Del" 
 
 FROM OPCH PCH 
 INNER JOIN PCH1 PH1 ON PH1."DocEntry" = PCH."DocEntry" 
 LEFT OUTER JOIN NNM1 NM1 ON PCH."Series" = NM1."Series" 
 LEFT OUTER JOIN OCRD CRD ON PCH."CardCode" = crd."CardCode" 
 LEFT OUTER JOIN (SELECT * FROM CRD1) AS VShipFrom ON VShipFrom."Address" = PCH."ShipToCode" AND VShipFrom."CardCode" = PCH."CardCode" AND VShipFrom."AdresType" = 'S' 
 LEFT OUTER JOIN (SELECT * FROM CRD1) AS VShipFrom1 ON VShipFrom1."Address" = CRD."ShipToDef" AND VShipFrom1."CardCode" = PCH."CardCode" AND VShipFrom1."AdresType" = 'S' 
 LEFT OUTER JOIN OGTY GTY2 ON VShipFrom1."GSTType" = GTY2."AbsEntry" 
 LEFT OUTER JOIN OSLP SLP ON PCH."SlpCode" = SLP."SlpCode" 
 LEFT OUTER JOIN OSHP SHP ON SHP."TrnspCode" = PCH."TrnspCode" 
 LEFT OUTER JOIN OLCT LCT ON PH1."LocCode" = LCT."Code" 
 LEFT OUTER JOIN OGTY GTY ON LCT."GSTType" = GTY."AbsEntry" 
 LEFT OUTER JOIN OCRN ON PCH."DocCur" = OCRN."CurrCode" 
 LEFT OUTER JOIN OCTG OCT ON PCH."GroupNum" = OCT."GroupNum" 
 LEFT OUTER JOIN PCH12 PH12 ON PH12."DocEntry" = PCH."DocEntry" 
 LEFT OUTER JOIN OCST CST1 ON CST1."Code" = PH12."StateS" AND CST1."Country" = PH12."CountryS" 
 LEFT OUTER JOIN OCPR CPR ON PCH."CardCode" = CPR."CardCode" AND PCH."CntctCode" = CPR."CntctCode" 
 LEFT OUTER JOIN OITM ITM ON ITM."ItemCode" = PH1."ItemCode" 
 LEFT OUTER JOIN PCH4 CGST ON PH1."DocEntry" = CGST."DocEntry" AND PH1."LineNum" = CGST."LineNum" AND CGST."staType" IN (-100) AND CGST."RelateType" = 1 
 LEFT OUTER JOIN PCH4 SGST ON PH1."DocEntry" = SGST."DocEntry" AND PH1."LineNum" = SGST."LineNum" AND SGST."staType" IN (-110) AND SGST."RelateType" = 1 
 LEFT OUTER JOIN PCH4 IGST ON PH1."DocEntry" = IGST."DocEntry" AND PH1."LineNum" = IGST."LineNum" AND IGST."staType" IN (-120) AND IGST."RelateType" = 1 
 LEFT OUTER JOIN OPRJ PRJ ON PRJ."PrjCode" = PCH."Project"




