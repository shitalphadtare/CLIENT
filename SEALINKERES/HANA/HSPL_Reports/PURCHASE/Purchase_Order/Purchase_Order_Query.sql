CREATE VIEW "SPL_TESTH"."GST_PURCHASE_ORDER" ( "Docentry",
	 "Docnum",
	 "DocCur",
	 "Docseries",
	 "Docdate",
	 "Purchase No",
	 "Cardcode",
	 "VName",
	 "VendorAdd",
	 "V_CNCTP_N",
	 "V_mobileNo",
	 "V_CnctP_E",
	 "Block",
	 "Building",
	 "Street",
	 "City",
	 "ZipCode",
	 "country",
	 "Street No_Vendor",
	 "STATE_Vendor",
	 "VShipGSTNo",
	 "VShipGSTType",
	 "SupRefNo",
	 "SupDate",
	 "PR No",
	 "PR Date",
	 "DeliDate",
	 "Deli_Mode",
	 "Deli_Addr",
	 "Deli_GST",
	 "Deli_GSTType",
	 "BuyerName",
	 "DeilName",
	 "SalesPrsn",
	 "salesmob",
	 "SalesEmail",
	 "CnctPrsnEmail",
	 "LineNum",
	 "ItemCode",
	 "Dscription",
	 "HSN Code",
	 "Service_SAC_Code",
	 "Quantity",
	 "unitMsr",
	 "PriceBefDi",
	 "DiscPrcnt",
	 "TotalAmt",
	 "ItmDiscAmt",
	 "DocDiscAmt",
	 "DiscAmt",
	 "Price",
	 "LineTotal",
	 "Total",
	 "TotalAsseble",
	 "CGSTRate",
	 "CGST",
	 "SGSTRate",
	 "SGST",
	 "IGSTRate",
	 "IGST",
	 "DocTotal",
	 "RoundDif",
	 "Currencyname",
	 "Hundredthname",
	 "Payment Terms",
	 "Remark",
	 "Opening Remark",
	 "Closing Remark",
	 "PrjName",
	 "ShipDate",
	 "U_OC_No",
	 "Cellolar",
	 "Delivery",
	 "Payment",
	 "Ispection",
	 "Terms_Price",
	 "Packing Instruction",
	 "Insurance",
	 "Freight",
	 "P & N",
	 "U_BPRefDt",
	 "DueOn",
	 "U_Terms_Del",
	 "U_ItemDesc2",
	 "U_ItemDesc3" ) AS SELECT
	 POR."DocEntry" AS "Docentry",
	 POR."DocNum" AS "Docnum",
	 POR."DocCur",
	 NM1."SeriesName" AS "Docseries",
	 POR."DocDate" AS "Docdate",
	 (CASE WHEN nm1."BeginStr" IS NULL 
	THEN IFNULL(NM1."BeginStr",
	 n'') 
	ELSE IFNULL(NM1."BeginStr",
	 n'') 
	END || RTRIM(LTRIM(CAST(POR."DocNum" AS char(20)))) || (CASE WHEN nm1."EndStr" IS NULL 
		THEN IFNULL(NM1."EndStr",
	 n'') 
		ELSE (IFNULL(NM1."EndStr",
	 n'')) 
		END)) AS "Purchase No",
	 CASE WHEN (crd."CardFName" IS NULL 
	OR crd."CardFName" = '') 
THEN por."CardCode" 
ELSE crd."CardFName" 
END AS "Cardcode",
	 POR."CardName" AS "VName",
	 POR."Address" AS "VendorAdd",
	 CPR."Name" AS "V_CNCTP_N",
	 cpr."Cellolar" AS "V_mobileNo",
	 CPR."E_MailL" AS "V_CnctP_E",
	 VShipFrom."Block",
	 VShipFrom."Building",
	 VShipFrom."Street",
	 VShipFrom."City",
	 VShipFrom."ZipCode",
	 (SELECT
	 DISTINCT "Name" 
	FROM OCRY 
	WHERE "Code" = VShipFrom."Country") AS "country",
	 VShipFrom."StreetNo" AS "Street No_Vendor",
	 (SELECT
	 DISTINCT "Name" 
	FROM OCST 
	WHERE "Code" = VShipFrom."State" 
	AND VShipFrom1."Country" = OCST."Country") AS "STATE_Vendor",
	 VShipFrom."GSTRegnNo" AS "VShipGSTNo",
	 GTY2."GSTType" AS "VShipGSTType",
	 POR."NumAtCard" AS "SupRefNo",
	 '' AS "SupDate",
	 (SELECT
	 STRING_AGG("B"."A",
	 ',') 
	FROM (SELECT
	 DISTINCT (CAST(OPRQ."DocNum" AS char(7))) AS "A",
	 POR1."DocEntry" 
		FROM OPRQ 
		INNER JOIN POR1 ON OPRQ."DocEntry" = POR1."BaseEntry" 
		AND POR1."DocEntry" = POR."DocEntry") AS "B" 
	GROUP BY "B"."DocEntry") AS "PR No",
	 (SELECT
	 STRING_AGG("B"."A",
	 ',') 
	FROM (SELECT
	 DISTINCT TO_VARCHAR(OPRQ."DocDate",
	 'DD-MM-YYYY') AS "A",
	 POR1."DocEntry" 
		FROM OPRQ 
		INNER JOIN POR1 ON OPRQ."DocEntry" = POR1."BaseEntry" 
		AND POR1."DocEntry" = POR."DocEntry") AS "B" 
	GROUP BY "B"."DocEntry") AS "PR Date",
	 POR."DocDueDate" AS "DeliDate",
	 SHP."TrnspName" AS "Deli_Mode",
	 POR."Address2" AS "Deli_Addr",
	 LCT."GSTRegnNo" AS "Deli_GST",
	 GTY."GSTType" AS "Deli_GSTType",
	 POR."PayToCode" AS "BuyerName",
	 POR."ShipToCode" AS "DeilName",
	 CASE WHEN SLP."SlpName" = '-No Sales Employee-' 
THEN '' 
ELSE SLP."SlpName" 
END AS "SalesPrsn",
	 SLP."Mobil" AS "salesmob",
	 SLP."Email" AS "SalesEmail",
	 CPR."E_MailL" AS "CnctPrsnEmail",
	 PR1."LineNum",
	 PR1."ItemCode",
	 PR1."Dscription",
	 (CASE WHEN ITM."ItemClass" = 1 
	THEN (SELECT
	 "ServCode" 
		FROM OSAC 
		WHERE "AbsEntry" = (CASE WHEN PR1."HsnEntry" IS NULL 
			THEN ITM."SACEntry" 
			ELSE PR1."HsnEntry" 
			END)) WHEN ITM."ItemClass" = 2 
	THEN (SELECT
	 "ChapterID" 
		FROM OCHP 
		WHERE "AbsEntry" = (CASE WHEN PR1."HsnEntry" IS NULL 
			THEN ITM."ChapterID" 
			ELSE PR1."HsnEntry" 
			END)) 
	ELSE '' 
	END) AS "HSN Code",
	 (SELECT
	 "ServCode" 
	FROM OSAC 
	WHERE "AbsEntry" = PR1."SacEntry") AS "Service_SAC_Code",
	 PR1."Quantity",
	 PR1."unitMsr",
	 PR1."PriceBefDi",
	 PR1."DiscPrcnt",
	 (IFNULL(PR1."Quantity",
	 0) * IFNULL(PR1."PriceBefDi",
	 0)) AS "TotalAmt",
	 ((IFNULL(PR1."PriceBefDi",
	 0) - IFNULL(PR1."Price",
	 0)) * IFNULL(PR1."Quantity",
	 0)) AS "ItmDiscAmt",
	 ((CASE WHEN OCRN."CurrCode" = 'INR' 
		THEN IFNULL(PR1."LineTotal",
	 0) 
		ELSE IFNULL(PR1."TotalFrgn",
	 0) 
		END) * (IFNULL(POR."DiscPrcnt",
	 0) / 100)) AS "DocDiscAmt",
	 CASE WHEN POR."DiscPrcnt" = 0 
THEN ((IFNULL(PR1."PriceBefDi",
	 0) - IFNULL(PR1."Price",
	 0)) * IFNULL(PR1."Quantity",
	 0)) 
ELSE ((CASE WHEN OCRN."CurrCode" = 'INR' 
		THEN IFNULL(PR1."LineTotal",
	 0) 
		ELSE IFNULL(PR1."TotalFrgn",
	 0) 
		END) * (IFNULL(POR."DiscPrcnt",
	 0) / 100)) 
END AS "DiscAmt",
	 PR1."Price",
	 CASE WHEN OCRN."CurrCode" = 'INR' 
THEN IFNULL(PR1."LineTotal",
	 0) 
ELSE IFNULL(PR1."TotalFrgn",
	 0) 
END AS "LineTotal",
	 CASE WHEN OCRN."CurrCode" = 'INR' 
THEN (CASE WHEN POR."DiscPrcnt" = 0 
	THEN IFNULL(PR1."LineTotal",
	 0) 
	ELSE (IFNULL(PR1."LineTotal",
	 0) - (IFNULL(PR1."LineTotal",
	 0) * IFNULL(POR."DiscPrcnt",
	 0) / 100)) 
	END) 
ELSE (CASE WHEN POR."DiscPrcnt" = 0 
	THEN IFNULL(PR1."TotalFrgn",
	 0) 
	ELSE (IFNULL(PR1."TotalFrgn",
	 0) - (IFNULL(PR1."TotalFrgn",
	 0) * IFNULL(POR."DiscPrcnt",
	 0) / 100)) 
	END) 
END AS "Total",
	 CASE WHEN PR1."AssblValue" = 0 
THEN (CASE WHEN POR."DiscPrcnt" = 0 
	THEN (CASE WHEN OCRN."CurrCode" = 'INR' 
		THEN IFNULL(PR1."LineTotal",
	 0) 
		ELSE IFNULL(PR1."TotalFrgn",
	 0) 
		END) 
	ELSE ((CASE WHEN OCRN."CurrCode" = 'INR' 
			THEN IFNULL(PR1."LineTotal",
	 0) 
			ELSE IFNULL(PR1."TotalFrgn",
	 0) 
			END) - ((CASE WHEN OCRN."CurrCode" = 'INR' 
				THEN IFNULL(PR1."LineTotal",
	 0) 
				ELSE IFNULL(PR1."TotalFrgn",
	 0) 
				END) * IFNULL(POR."DiscPrcnt",
	 0) / 100)) 
	END) 
ELSE (IFNULL(PR1."AssblValue",
	 0) * IFNULL(PR1."Quantity",
	 0)) 
END AS "TotalAsseble",
	 CGST."TaxRate" AS "CGSTRate",
	 CASE WHEN OCRN."CurrCode" = 'INR' 
THEN CGST."TaxSum" 
ELSE CGST."TaxSumFrgn" 
END AS "CGST",
	 SGST."TaxRate" AS "SGSTRate",
	 CASE WHEN OCRN."CurrCode" = 'INR' 
THEN SGST."TaxSum" 
ELSE SGST."TaxSumFrgn" 
END AS "SGST",
	 IGST."TaxRate" AS "IGSTRate",
	 CASE WHEN OCRN."CurrCode" = 'INR' 
THEN IGST."TaxSum" 
ELSE IGST."TaxSumFrgn" 
END AS "IGST",
	 POR."DocTotal",
	 CASE WHEN OCRN."CurrCode" = 'INR' 
THEN POR."RoundDif" 
ELSE POR."RoundDifFC" 
END AS "RoundDif",
	 OCRN."CurrName" AS "Currencyname",
	 OCRN."F100Name" AS "Hundredthname",
	 OCT."PymntGroup" AS "Payment Terms",
	 POR."Comments" AS "Remark",
	 POR."Header" AS "Opening Remark",
	 POR."Footer" AS "Closing Remark",
	 PRJ."PrjName" AS "PrjName",
	 PR1."ShipDate" AS "ShipDate",
	 POR."U_OCNo" AS "U_OC_No",
	 CPR."Cellolar",
	 POR."U_Terms_Del" AS "Delivery",
	 POR."U_Terms_Pay" AS "Payment",
	 POR."U_Terms_Insp" AS "Ispection",
	 POR."U_Terms_Price" AS "Terms_Price",
	 POR."U_Terms_PackInst" AS "Packing Instruction",
	 POR."U_Terms_Insu" AS "Insurance",
	 POR."U_Terms_Frt" AS "Freight",
	 POR."U_Terms_PNF" AS "P & N",
	 POR."U_BPRefDt",
	 PR1."ShipDate" AS "DueOn",
	 Por."U_Terms_Del",
	 PR1."U_ItemDesc2",
	 PR1."U_ItemDesc3" 
FROM OPOR POR 
INNER JOIN POR1 PR1 ON PR1."DocEntry" = POR."DocEntry" 
LEFT OUTER JOIN NNM1 NM1 ON POR."Series" = NM1."Series" 
LEFT OUTER JOIN OCRD CRD ON por."CardCode" = crd."CardCode" 
LEFT OUTER JOIN (SELECT
	 * 
	FROM CRD1) AS VShipFrom ON VShipFrom."Address" = por."ShipToCode" 
AND VShipFrom."CardCode" = POR."CardCode" 
AND VShipFrom."AdresType" = 'S' 
LEFT OUTER JOIN (SELECT
	 * 
	FROM CRD1) AS VShipFrom1 ON VShipFrom1."Address" = CRD."ShipToDef" 
AND VShipFrom1."CardCode" = POR."CardCode" 
AND VShipFrom1."AdresType" = 'S' 
LEFT OUTER JOIN OGTY GTY2 ON VShipFrom."GSTType" = GTY2."AbsEntry" 
LEFT OUTER JOIN OSLP SLP ON POR."SlpCode" = SLP."SlpCode" 
LEFT OUTER JOIN OSHP SHP ON SHP."TrnspCode" = POR."TrnspCode" 
LEFT OUTER JOIN OLCT LCT ON PR1."LocCode" = LCT."Code" 
LEFT OUTER JOIN OGTY GTY ON LCT."GSTType" = GTY."AbsEntry" 
LEFT OUTER JOIN OCRN ON POR."DocCur" = OCRN."CurrCode" 
LEFT OUTER JOIN OCTG OCT ON POR."GroupNum" = OCT."GroupNum" 
LEFT OUTER JOIN POR12 PR12 ON PR12."DocEntry" = POR."DocEntry" 
LEFT OUTER JOIN OCST CST1 ON CST1."Code" = PR12."StateS" 
AND CST1."Country" = PR12."CountryS" 
LEFT OUTER JOIN OCPR CPR ON POR."CardCode" = CPR."CardCode" 
AND POR."CntctCode" = CPR."CntctCode" 
LEFT OUTER JOIN OITM ITM ON ITM."ItemCode" = PR1."ItemCode" 
LEFT OUTER JOIN POR4 CGST ON PR1."DocEntry" = CGST."DocEntry" 
AND PR1."LineNum" = CGST."LineNum" 
AND CGST."staType" IN (-100) 
AND CGST."RelateType" = 1 
LEFT OUTER JOIN POR4 SGST ON PR1."DocEntry" = SGST."DocEntry" 
AND PR1."LineNum" = SGST."LineNum" 
AND SGST."staType" IN (-110) 
AND SGST."RelateType" = 1 
LEFT OUTER JOIN POR4 IGST ON PR1."DocEntry" = IGST."DocEntry" 
AND PR1."LineNum" = IGST."LineNum" 
AND IGST."staType" IN (-120) 
AND IGST."RelateType" = 1 
LEFT OUTER JOIN OPRJ PRJ ON PRJ."PrjCode" = POR."Project" WITH READ ONLY