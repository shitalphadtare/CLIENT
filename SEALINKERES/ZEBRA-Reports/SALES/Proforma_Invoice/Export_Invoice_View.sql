

create VIEW EXPORT_INVOICE
AS

 Select
 Oi."DocEntry", Oi."DocNum", Oi."DocDate", nm."SeriesName", nm."BeginStr", nm."EndStr", 
(CASE WHEN Oi."U_InvoiceNo" IS NULL THEN (nm."SeriesName" || '/' || CAST(Oi."DocNum" AS char(20))) ELSE Oi."U_InvoiceNo" END) AS "Invoice No", 
Oi."NumAtCard" AS "BuyerRefNo", oi."U_BPRefDt" AS "BuyerRefDate", 
iv1."BaseAtCard" AS "BaseCard", Oi.U_OTHEREF AS "OtherRef", Oi."ShipToCode" AS "Consignee", 
Oi."Address2" AS "ConSigneeAdd", iv1."U_Marks_Nos" AS "MARK_ROW_LEVEL", Oi."PayToCode" AS "Buyer",
 Oi."Address" AS "BuyerAdd", Oi."U_Final_Dest" AS "FinalDestination", Oi."U_Place_Receipt" AS "Place Of receipt", 
 Oi."U_Pre_Carriage" AS "PreCarriage", Oi."U_Vessel_No" AS "VessalNo", Oi."U_Cnt_Final_Dest" AS "FDestCountry", Oi."U_Port_Load" AS "LoadPort",
Oi."U_Port_Dish" AS "DischargePort", Oi."U_Terms_Del" AS "DelTerms", Oi."U_Exp_Terms_Del" AS "Exp Del Terms", Oi."U_Terms_Pay" AS "PayTerms", 
oi."U_Marks_Nos" AS "MarkNumber Doclevel", oi."U_Cont_Nos" AS "Container Doclevel", oi."U_No_Of_Pkgs" AS "Total No OF Pckgs Doclevel", 
Oc."Currency" AS "BP Currency", oi."U_Exp_Scheme" AS "Exp Scheme", oi."U_HS_Code" AS "HS Code", oi."U_Comd_Desc" AS "Comd Desc", 
ot."ItemCode" AS "ItemCode", Iv1."Dscription" AS "Description", ot."SWeight1" AS "WeightValue", t2."UnitDisply" AS "WeightUOM", 
(CASE WHEN t2."UnitDisply" = 'g' THEN ot."SWeight1" ELSE (CASE WHEN t2."UnitDisply" = 'kg' THEN ot."SWeight1" * 1000 ELSE ot."SWeight1" / 1000 END) END) AS "Item Weight", 
Iv1."Quantity", iv1."PriceBefDi" AS "Price", (CASE WHEN oi."DocCur" = 'INR' THEN Oi."DocTotal" ELSE Oi."DocTotalFC" END) AS "LineAmount", ot."InvntryUom" AS "Item UOM",
OCRN."DocCurrCod", OCRN."CurrName" AS "Currencyname", OCRN."F100Name" AS "Hundredthname", oi."U_Net_Wt" AS "Total Net Weight", oi."U_Tare_Wt" AS "Total Tare Wt", 
oi."U_Gross_Wt" AS "Total Gross Wt", oi."U_LC_No" AS "LC No", oi."U_LC_Bank" AS "LC Babk", oi."U_SB_No" AS "Shipping Bill  No", oi."U_BL_No" AS "Bill Of Lading No", 
CASE WHEN oi."U_BL_Date" IS NULL OR oi."U_BL_Date" = '' THEN NULL ELSE oi."U_BL_Date" END AS "Bill Of Lading Date", 
CASE WHEN oi."U_SB_Date" IS NULL OR oi."U_SB_Date" = '' THEN NULL ELSE oi."U_SB_Date" END AS "Shipping Bill Date", 
OW."Street" AS "Street", OW."StreetNo" AS "Street No", OW."Block" AS "Block", OW."Building" AS "Building", 
OLC."Location" AS "Location", OLC."City" AS "City", OW."ZipCode" AS "Zipcode", 
CASE WHEN INV12."TaxId0" = '' OR INV12."TaxId0" IS NULL THEN Crd7."TaxId0" ELSE INV12."TaxId0" END AS "Cust PAN NO", 
CASE WHEN INV12."TaxId2" = '' OR INV12."TaxId2" IS NULL THEN Crd7."TaxId2" ELSE INV12."TaxId2" END AS "Cust VAT NO", 
CASE WHEN INV12."TaxId1" = '' OR INV12."TaxId1" IS NULL THEN Crd7."TaxId1" ELSE INV12."TaxId1" END AS "Cust CST NO", 
CASE WHEN INV12."TaxId11" = '' OR INV12."TaxId11" IS NULL THEN Crd7."TaxId11" ELSE INV12."TaxId11" END AS "Cust TIN NO", 
CASE WHEN INV12."TaxId6" = '' OR INV12."TaxId6" IS NULL THEN Crd7."TaxId6" ELSE INV12."TaxId6" END AS "Cust TAN NO",
Ocb."Building" AS "CustBank", ot."U_DRG_NO" AS "Item DRG NO", oi."U_Pkg_Type" AS "PAckage Type", (CASE WHEN oi."Address2" = Oi."Address" THEN '0' ELSE '1' END) AS "chkAddress", 
oi."DocCur" AS "DocCur", oi."U_Notify" AS "Notify", iv1."LineNum", (CASE WHEN oi."DocCur" = 'INR' THEN oi."TotalExpns" ELSE oi."TotalExpFC" END) AS "Freight", 
iv1."U_ItemDesc2", iv1."U_ItemDesc3", iv1."Text" AS "LineText" 

FROM OINV Oi 
INNER JOIN INV1 iv1 ON Oi."DocEntry" = iv1."DocEntry" 
LEFT OUTER JOIN INV10 IV10 ON iv10."AftLineNum" + 1 = iv1."VisOrder" AND iv10."DocEntry" = iv1."DocEntry" 
LEFT OUTER JOIN NNM1 nm ON oi."Series" = nm."Series" 
LEFT OUTER JOIN OCRN ON oi."DocCur" = OCRN."CurrCode" 
LEFT OUTER JOIN (SELECT "CardCode", "Address", "TaxId0", "TaxId1", "TaxId2", "TaxId3", "TaxId4", "TaxId5", "TaxId6", "TaxId7", "TaxId8", "TaxId9", "CNAEId", "TaxId10", "TaxId11", 
				"AddrType", "ECCNo", "CERegNo", "CERange", "CEDivis", "CEComRate", "LogInstanc", "SefazDate", "TaxId12", "TaxId13" 
				FROM CRD7 CRD7_1 WHERE ("AddrType" = 'S')) AS Crd7 ON oi."CardCode" = Crd7."CardCode" AND 
				Crd7."Address" = CASE WHEN oi."ShipToCode" IS NULL OR oi."ShipToCode" = '' THEN '' ELSE oi."ShipToCode" END 
				LEFT OUTER JOIN INV12 ON Oi."DocEntry" = INV12."DocEntry" 
				LEFT OUTER JOIN OITM ot ON iv1."ItemCode" = ot."ItemCode" 
				LEFT OUTER JOIN OWGT t2 ON ot."SWght1Unit" = t2."UnitCode" 
				LEFT OUTER JOIN OWHS OW ON iv1."WhsCode" = OW."WhsCode" 
				LEFT OUTER JOIN OLCT OLC ON OLC."Code" = iv1."LocCode" 
				LEFT OUTER JOIN OCRD Oc ON Oi."CardCode" = Oc."CardCode" 
				LEFT OUTER JOIN OCRB Ocb ON Oc."CardCode" = Ocb."CardCode" AND Oc."BankCode" = Ocb."BankCode" 
				LEFT OUTER JOIN (SELECT "DocEntry", SUM("TaxSum") AS "Taxsum" FROM INV4 WHERE "staType" IN (1,4) AND "ExpnsCode" = -1 GROUP BY "DocEntry") AS Stax ON Oi."DocEntry" = Stax."DocEntry" 
LEFT OUTER JOIN (SELECT "DocEntry", SUM("TaxSum") AS "FTaxsum" FROM INV4 WHERE "staType" IN (1,4) AND "ExpnsCode" <> -1 GROUP BY "DocEntry") 
			AS FStax ON Oi."DocEntry" = FStax."DocEntry"
                      


