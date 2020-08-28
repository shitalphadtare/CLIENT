Create view SALES_REGISTER_WITH_RETURN_GST_NEW as
Select * from (
SELECT T0."DocEntry", (CASE T0."GSTTranTyp" WHEN 'GA' THEN 'Gst Tax Invoice' WHEN 'GD' THEN 'Gst Debit Memo' WHEN '--' THEN 'Bill Of Supply' END) AS "GST Transaction Type", 
 T0."DocDate"  AS "Invoice Date", T0."DocNum" AS "Invoice No", N1."SeriesName" AS "DocSeries", 
N1."BeginStr" AS "DocSeriesPrefix", N1."EndStr" AS "DocSeriesSuffix", SLP."SlpName" AS "SALES PERSON NAME", T0."CardName" AS "Customer Billing Name", 
T7."BpGSTN" AS "Billing GSTIN", T7."LocStaGSTN" AS "State POS", (CASE WHEN T0."DocType" = 'I' AND ITM."ItemClass" = 2 THEN 'G' ELSE 'S' END) AS "ItemType", 
t1."ItemCode" AS "Item Code", T1."Dscription" AS "Item Description", t1."unitMsr", (CASE WHEN T0."DocType" = 'I' THEN (CASE WHEN ITM."ItemClass" = 1 THEN 
(SELECT "ServCode" FROM OSAC WHERE "AbsEntry" = (CASE WHEN t1."SacEntry" IS NULL THEN ITM."SACEntry" ELSE t1."SacEntry" END)) WHEN ITM."ItemClass" = 2
 THEN (SELECT "ChapterID" FROM OCHP WHERE "AbsEntry" = (CASE WHEN t1."HsnEntry" IS NULL THEN ITM."ChapterID" ELSE t1."HsnEntry" END)) END) ELSE 
 (CASE WHEN T0."DocType" = 'S' THEN (SELECT "ServCode" FROM OSAC WHERE "AbsEntry" = T1."SacEntry") END) END) AS "HSN/SAC Code", 
 (CASE WHEN T0."DocType" = 'S' THEN 1 ELSE T1."Quantity" END) AS "Quantity", (CASE WHEN "DocType" = 'S' THEN T1."LineTotal" ELSE (T1."PriceBefDi" * 
 (CASE WHEN T1."Rate" = 0 THEN 1 ELSE T1."Rate" END)) END) AS "Unit Price", (CASE WHEN T0."DocType" = 'S' THEN (T1."LineTotal") ELSE (t1."Quantity" *
  (T1."PriceBefDi" * (CASE WHEN T1."Rate" = 0 THEN 1 ELSE T1."Rate" END))) END) AS "ItemTotalBefDi", (CASE WHEN T0."DocType" = 'S' THEN 
  ((t1."Quantity" * T1."LineTotal") * T1."DiscPrcnt" / 100) + (T1."LineTotal" * T0."DiscPrcnt" / 100) ELSE ((t1."Quantity" * (T1."PriceBefDi" * 
  (CASE WHEN T1."Rate" = 0 THEN 1 ELSE T1."Rate" END))) * T1."DiscPrcnt" / 100) + (T1."LineTotal" * T0."DiscPrcnt" / 100) END) AS "Item Discount", 
  (CASE WHEN T0."DocType" = 'S' THEN (T1."LineTotal") - (T1."LineTotal" * T0."DiscPrcnt" / 100) ELSE ((t1."Quantity" * (T1."PriceBefDi" * 
  (CASE WHEN T1."Rate" = 0 THEN 1 ELSE T1."Rate" END))) - (((t1."Quantity" * (T1."PriceBefDi" * 
  (CASE WHEN T1."Rate" = 0 THEN 1 ELSE T1."Rate" END))) * T1."DiscPrcnt" / 100) + (T1."LineTotal" * T0."DiscPrcnt" / 100))) END) AS " Item Total After Discount", 
  T1."LineTotal" AS "Basic Line Total", (CASE WHEN (T1."AssblValue" > 0) THEN (T1."Quantity" * T1."AssblValue") ELSE T1."LineTotal" END) AS "Taxable Value", 
  T1."TaxCode", IFNULL(CGST."TaxRate", 0) AS "CGST Rate", IFNULL(CGST."TaxSum", 0) AS "CGST", IFNULL(SGST."TaxRate", 0) AS "SGST Rate", 
  IFNULL(SGST."TaxSum", 0) AS "SGST", IFNULL(IGST."TaxRate", 0) AS "IGST Rate", IFNULL(IGST."TaxSum", 0) AS "IGST", (CASE WHEN IFNULL(CGST."RvsChrgTax", 0) + 
  IFNULL(SGST."RvsChrgTax", 0) + IFNULL(IGST."RvsChrgTax", 0) <> 0 THEN 'Y' ELSE 'N' END) AS "Reverse Charge Flag", IFNULL(CGST."RvsChrgTax", 0) AS "CGST Rev Tax", 
  IFNULL(SGST."RvsChrgTax", 0) AS "SGST Rev Tax", IFNULL(IGST."RvsChrgTax", 0) AS "IGST Rev Tax", ((CASE WHEN T0."DocType" = 'S' THEN (T1."LineTotal") - 
  (T1."LineTotal" * T0."DiscPrcnt" / 100) ELSE ((t1."Quantity" * (T1."PriceBefDi" * (CASE WHEN T1."Rate" = 0 THEN 1 ELSE T1."Rate" END))) - 
  (((t1."Quantity" * (T1."PriceBefDi" * (CASE WHEN T1."Rate" = 0 THEN 1 ELSE T1."Rate" END))) * T1."DiscPrcnt" / 100) + (T1."LineTotal" * T0."DiscPrcnt" / 100))) END) 
  + IFNULL(CGST."TaxSum", 0) + IFNULL(SGST."TaxSum", 0) + IFNULL(IGST."TaxSum", 0)) AS "Total Incl GST", T0."RevRefNo" AS "Original Invoice No", 
  T0."RevRefDate" AS "Original Invoice Date", T7."BpGSTN" AS "Original Customer GSTIN", T0."EComerGSTN" AS "ECommGSTN", 
  CAST(iv9."BsDocDate" AS varchar(10)) AS "AdvancePaymentDocDate", iv9."BaseDocNum" AS "AdvancePaymentDocNum", T7."ImpORExp" AS "Flag Export Invoice", 
  NULL AS "Export Type", T7."ImpExpNo" AS "Export No", T7."ImpExpDate" AS "Export Date", T7."BpCountry" AS "Customer Country", T7."BpGSTN" AS "Customer GSTNo", 
  T0."Address" AS "Billing Address", T7."CityB" AS "Billing City", T7."ZipCodeB" AS "Billing Pin Code", T7."StateB" AS "Billing State", 
  T0."ShipToCode" AS "Shipping Name", T0."Address2" AS "Shipping Address", T7."CityS" AS "Shipping City", T7."ZipCodeS" AS "Shipping Pin Code", 
  T7."BpStateCod" AS "Shipping State", T7."BPStatGSTN" AS "Shipping State Code", MONTH(T0."RevRefDate") AS "Revision_Month", 
  (CASE WHEN T0."DutyStatus" = 'Y' THEN 'WPAY' ELSE 'WOPAY' END) AS "Duty_Status", NULL AS "Port Code", 
  (SELECT "GSTType" FROM OGTY WHERE "AbsEntry" = T7."BpGSTType") AS "Customer GST Type", T7."LocGSTN" AS "Location GSTNo", T7."LocStatCod" AS "Location State", 
  'AR Invoice' AS "Doc Type", T0."DocDueDate" AS "Invoice Due Date", T0."Comments", itb."ItmsGrpNam" AS "item group", t1."AcctCode" AS "G/L Account" 
  FROM OINV T0 
  LEFT OUTER JOIN OCRD ON OCRD."CardCode" = T0."CardCode" 
  LEFT OUTER JOIN OCRG ON OCRG."GroupCode" = OCRD."GroupCode" 
  LEFT OUTER JOIN CRD7 C7 ON T0."CardCode" = C7."CardCode" AND T0."ShipToCode" = C7."Address" AND C7."AddrType" = 'S' 
  INNER JOIN INV1 T1 ON T0."DocEntry" = T1."DocEntry" 
  LEFT OUTER JOIN OITM ITM ON (ITM."ItemCode" = T1."ItemCode") 
  INNER JOIN OITB ITB ON ITM."ItmsGrpCod" = ITB."ItmsGrpCod" 
  LEFT OUTER JOIN OSLP SLP ON SLP."SlpCode" = T0."SlpCode" 
  LEFT OUTER JOIN NNM1 N1 ON N1."Series" = T0."Series" 
  LEFT OUTER JOIN INV9 iv9 ON t0."DocEntry" = iv9."DocEntry" AND iv9."ObjType" = '203' 
  INNER JOIN INV12 T7 ON T0."DocEntry" = T7."DocEntry" 
  LEFT OUTER JOIN INV4 CGST ON T1."DocEntry" = CGST."DocEntry" AND T1."LineNum" = CGST."LineNum" AND CGST."staType" = -100 AND 
  CGST."RelateType" = 1 AND CGST."ExpnsCode" = -1 
  LEFT OUTER JOIN INV4 SGST ON T1."DocEntry" = SGST."DocEntry" AND T1."LineNum" = SGST."LineNum" AND SGST."staType" = -110 AND 
  SGST."RelateType" = 1 AND SGST."ExpnsCode" = -1 
  LEFT OUTER JOIN INV4 IGST ON T1."DocEntry" = IGST."DocEntry" AND T1."LineNum" = IGST."LineNum" AND IGST."staType" = -120 AND 
  IGST."RelateType" = 1 AND IGST."ExpnsCode" = -1 
  WHERE T0.CANCELED = 'N'



-----------------------------------------------------------
Union all
SELECT T0."DocEntry", (CASE T0."GSTTranTyp" WHEN 'GA' THEN 'Gst Tax Invoice' WHEN 'GD' THEN 'Gst Debit Memo' 
WHEN '--' THEN 'Bill Of Supply' END) AS "GST Transaction Type", T0."DocDate"  AS "Invoice Date", T0."DocNum" AS "Invoice No", 
N1."SeriesName" AS "DocSeries", N1."BeginStr" AS "DocSeriesPrefix", N1."EndStr" AS "DocSeriesSuffix", SLP."SlpName" AS "SALES PERSON NAME", 
T0."CardName" AS "Customer Billing Name", T7."BpGSTN" AS "Billing GSTIN", T7."LocStaGSTN" AS "State POS", 'S' AS "ItemType", '' AS "Item Code", 
T4."ExpnsName" AS "Item Description", NULL AS "unitMsr", (SELECT "SacCode" FROM OEXD WHERE T4."ExpnsName" = OEXD."ExpnsName") AS "HSN/SAC Code", 
1 AS "Quantity", T3."LineTotal" AS "Unit Price", T3."LineTotal" AS "ItemTotalBefDi", NULL AS "Item Discount", T3."LineTotal" AS "Item Total After Discount", 
T3."LineTotal" AS "Basic Line Total", T3."LineTotal" AS "Taxable Value", T3."TaxCode", IFNULL(CGST."TaxRate", 0) AS "CGST Rate", 
IFNULL(CGST."TaxSum", 0) AS "CGST", IFNULL(SGST."TaxRate", 0) AS "SGST Rate", IFNULL(SGST."TaxSum", 0) AS "SGST", IFNULL(IGST."TaxRate", 0) AS "IGST Rate", 
IFNULL(IGST."TaxSum", 0) AS "IGST", (CASE WHEN IFNULL(CGST."RvsChrgTax", 0) + IFNULL(SGST."RvsChrgTax", 0) + 
IFNULL(IGST."RvsChrgTax", 0) <> 0 THEN 'Y' ELSE 'N' END) AS "Reverse Charge Flag", IFNULL(CGST."RvsChrgTax", 0) AS "CGST Rev Tax", 
IFNULL(SGST."RvsChrgTax", 0) AS "SGST Rev Tax", IFNULL(IGST."RvsChrgTax", 0) AS "IGST Rev Tax", IFNULL(T3."LineTotal", 0) + IFNULL(CGST."TaxSum", 0) + 
IFNULL(SGST."TaxSum", 0) + IFNULL(IGST."TaxSum", 0) AS "Total Incl GST", T0."RevRefNo" AS "Original Invoice No", T0."RevRefDate" AS "Original Invoice Date", 
T7."BpGSTN" AS "Original Customer GSTIN", NULL AS "ECommGSTN", NULL AS "AdvancePaymentDocDate", NULL AS "AdvancePaymentDocNum", T7."ImpORExp" AS "Flag Export Invoice", 
NULL AS "Export Type", T7."ImpExpNo" AS "Export No", T7."ImpExpDate" AS "Export Date", T7."BpCountry" AS "Customer Country", T7."BpGSTN" AS "Customer GSTNo", 
T0."Address" AS "Billing Address", T7."CityB" AS "Billing City", T7."ZipCodeB" AS "Billing Pin Code", T7."StateB" AS "Billing State", 
T0."ShipToCode" AS "Shipping Name", T0."Address2" AS "Shipping Address", T7."CityS" AS "Shipping City", T7."ZipCodeS" AS "Shipping Pin Code", 
T7."BpStateCod" AS "Shipping State", T7."BPStatGSTN" AS "Shipping State Code", MONTH(T0."RevRefDate") AS "Revision_Month", 
(CASE WHEN T0."DutyStatus" = 'Y' THEN 'WPAY' ELSE 'WOPAY' END) AS "Duty_Status", NULL AS "Port Code", 
(SELECT "GSTType" FROM OGTY WHERE "AbsEntry" = T7."BpGSTType") AS "Customer GST Type", T7."LocGSTN" AS "Location GSTNo", T7."LocStatCod" AS "Location State", 
'AR Invoice' AS "Doc Type", T0."DocDueDate" AS "Invoice Due Date", T0."Comments", '' AS "item group", '' AS "G/L Account" 

FROM OINV T0 
LEFT OUTER JOIN OCRD ON OCRD."CardCode" = T0."CardCode" 
LEFT OUTER JOIN OCRG ON OCRG."GroupCode" = OCRD."GroupCode" 
LEFT OUTER JOIN CRD7 C7 ON T0."CardCode" = C7."CardCode" AND T0."ShipToCode" = C7."Address" AND C7."AddrType" = 'S' 
LEFT OUTER JOIN OSLP SLP ON SLP."SlpCode" = T0."SlpCode" 
INNER JOIN NNM1 N1 ON N1."Series" = T0."Series" 
INNER JOIN INV3 T3 ON T0."DocEntry" = T3."DocEntry" 
INNER JOIN INV12 T7 ON T0."DocEntry" = T7."DocEntry" 
INNER JOIN OEXD T4 ON T3."ExpnsCode" = T4."ExpnsCode" 
LEFT OUTER JOIN INV4 CGST ON T3."DocEntry" = CGST."DocEntry" AND T3."ExpnsCode" = CGST."ExpnsCode" AND CGST."staType" = -100 AND CGST."ExpnsCode" <> -1 
LEFT OUTER JOIN INV4 SGST ON T3."DocEntry" = SGST."DocEntry" AND T3."ExpnsCode" = SGST."ExpnsCode" AND SGST."staType" = -110 AND SGST."ExpnsCode" <> -1 
LEFT OUTER JOIN INV4 IGST ON T3."DocEntry" = IGST."DocEntry" AND T3."ExpnsCode" = IGST."ExpnsCode" AND IGST."staType" = -120 AND IGST."ExpnsCode" <> -1 
WHERE T0."CANCELED" = 'N'

--------------------------------------------------------------------------------
union all
SELECT T0."DocEntry", (CASE T0."GSTTranTyp" WHEN 'GA' THEN 'Gst Tax Invoice' WHEN 'GD' THEN 'Gst Debit Memo' 
WHEN '--' THEN 'Bill Of Supply' END) AS "GST Transaction Type", T0."DocDate"  AS "Invoice Date", T0."DocNum" AS "Invoice No", 
N1."SeriesName" AS "DocSeries", N1."BeginStr" AS "DocSeriesPrefix", N1."EndStr" AS "DocSeriesSuffix", SLP."SlpName" AS "SALES PERSON NAME", 
T0."CardName" AS "Customer Billing Name", T7."BpGSTN" AS "Billing GSTIN", T7."LocStaGSTN" AS "State POS", 
(CASE WHEN T0."DocType" = 'I' AND ITM."ItemClass" = 2 THEN 'G' ELSE 'S' END) AS "ItemType", t1."ItemCode" AS "Item Code", T1."Dscription" AS "Item Description", 
t1."unitMsr", (CASE WHEN T0."DocType" = 'I' THEN (CASE WHEN ITM."ItemClass" = 1 THEN (SELECT "ServCode" FROM OSAC WHERE "AbsEntry" = 
(CASE WHEN t1."SacEntry" IS NULL THEN ITM."SACEntry" ELSE t1."SacEntry" END)) WHEN ITM."ItemClass" = 2 THEN 
(SELECT "ChapterID" FROM OCHP WHERE "AbsEntry" = (CASE WHEN t1."HsnEntry" IS NULL THEN ITM."ChapterID" ELSE t1."HsnEntry" END)) END) ELSE 
(CASE WHEN T0."DocType" = 'S' THEN (SELECT "ServCode" FROM OSAC WHERE "AbsEntry" = T1."SacEntry") END) END) AS "HSN/SAC Code", 
(CASE WHEN T0."DocType" = 'S' THEN 1 * (-1) ELSE T1."Quantity" * (-1) END) AS "Quantity", (CASE WHEN "DocType" = 'S' THEN T1."LineTotal" ELSE 
(T1."PriceBefDi" * (CASE WHEN T1."Rate" = 0 THEN 1 ELSE T1."Rate" END)) END) AS "Unit Price", (CASE WHEN T0."DocType" = 'S' THEN T1."LineTotal" * (-1) 
ELSE (t1."Quantity" * (T1."PriceBefDi" * (CASE WHEN T1."Rate" = 0 THEN 1 ELSE T1."Rate" END))) * (-1) END) AS "ItemTotalBefDi", 
(CASE WHEN T0."DocType" = 'S' THEN ((t1."Quantity" * T1."LineTotal") * T1."DiscPrcnt" / 100) + (T1."LineTotal" * T0."DiscPrcnt" / 100) ELSE ((t1."Quantity" * 
(T1."PriceBefDi" * (CASE WHEN T1."Rate" = 0 THEN 1 ELSE T1."Rate" END))) * T1."DiscPrcnt" / 100) + (T1."LineTotal" * T0."DiscPrcnt" / 100) END) * 
(-1) AS "Item Discount", (CASE WHEN T0."DocType" = 'S' THEN (T1."LineTotal") - (T1."LineTotal" * T0."DiscPrcnt" / 100) ELSE ((t1."Quantity" * (T1."PriceBefDi" * 
(CASE WHEN T1."Rate" = 0 THEN 1 ELSE T1."Rate" END))) - (((t1."Quantity" * (T1."PriceBefDi" * (CASE WHEN T1."Rate" = 0 THEN 1 ELSE T1."Rate" END))) * 
T1."DiscPrcnt" / 100) + (T1."LineTotal" * T0."DiscPrcnt" / 100))) END) * (-1) AS " Item Total After Discount", T1."LineTotal" * -1 AS "Basic Line Total", 
(CASE WHEN (T1."AssblValue" > 0) THEN (T1."Quantity" * T1."AssblValue" * -1) ELSE (T1."LineTotal" * -1) END) AS "Taxable Value", T1."TaxCode", 
IFNULL(CGST."TaxRate", 0) AS "CGST Rate", IFNULL(CGST."TaxSum", 0) * (-1) AS "CGST", IFNULL(SGST."TaxRate", 0) AS "SGST Rate", 
IFNULL(SGST."TaxSum", 0) * (-1) AS "SGST", IFNULL(IGST."TaxRate", 0) AS "IGST Rate", IFNULL(IGST."TaxSum", 0) * (-1) AS "IGST", 
(CASE WHEN IFNULL(CGST."RvsChrgTax", 0) + IFNULL(SGST."RvsChrgTax", 0) + IFNULL(IGST."RvsChrgTax", 0) <> 0 THEN 'Y' ELSE 'N' END) AS "Reverse Charge Flag", 
IFNULL(CGST."RvsChrgTax", 0) * (-1) AS "CGST Rev Tax", IFNULL(SGST."RvsChrgTax", 0) * (-1) AS "SGST Rev Tax", IFNULL(IGST."RvsChrgTax", 0) * (-1) AS "IGST Rev Tax", 
((CASE WHEN T0."DocType" = 'S' THEN (T1."LineTotal") - (T1."LineTotal" * T0."DiscPrcnt" / 100) ELSE ((t1."Quantity" * (T1."PriceBefDi" * 
(CASE WHEN T1."Rate" = 0 THEN 1 ELSE T1."Rate" END))) - (((t1."Quantity" * (T1."PriceBefDi" * (CASE WHEN T1."Rate" = 0 THEN 1 ELSE T1."Rate" END))) * 
T1."DiscPrcnt" / 100) + (T1."LineTotal" * T0."DiscPrcnt" / 100))) END) + IFNULL(CGST."TaxSum", 0) + IFNULL(SGST."TaxSum", 0) + 
IFNULL(IGST."TaxSum", 0)) * (-1) AS "Total Incl GST", T0."RevRefNo" AS "Original Invoice No", T0."RevRefDate" AS "Original Invoice Date", 
T7."BpGSTN" AS "Original Customer GSTIN", NULL AS "ECommGSTN", NULL AS "AdvancePaymentDocDate", NULL AS "AdvancePaymentDocNum", T7."ImpORExp" AS "Flag Export Invoice", 
NULL AS "Export Type", T7."ImpExpNo" AS "Export No", T7."ImpExpDate" AS "Export Date", T7."BpCountry" AS "Customer Country", T7."BpGSTN" AS "Customer GSTNo", 
T0."Address" AS "Billing Address", T7."CityB" AS "Billing City", T7."ZipCodeB" AS "Billing Pin Code", T7."StateB" AS "Billing State", T0."ShipToCode" AS "Shipping Name", 
T0."Address2" AS "Shipping Address", T7."CityS" AS "Shipping City", T7."ZipCodeS" AS "Shipping Pin Code", T7."BpStateCod" AS "Shipping State", 
T7."BPStatGSTN" AS "Shipping State Code", MONTH(T0."RevRefDate") AS "Revision_Month", (CASE WHEN T0."DutyStatus" = 'Y' THEN 'WPAY' ELSE 'WOPAY' END) AS "Duty_Status", 
NULL AS "Port Code", (SELECT "GSTType" FROM OGTY WHERE "AbsEntry" = T7."BpGSTType") AS "Customer GST Type", T7."LocGSTN" AS "Location GSTNo", 
T7."LocStatCod" AS "Location State", 'AR Credit Memo' AS "Doc Type", T0."DocDueDate" AS "Invoice Due Date", T0."Comments", itb."ItmsGrpNam" AS "item group", 
t1."AcctCode" AS "G/L Account" 
FROM ORIN T0 
LEFT OUTER JOIN OCRD ON OCRD."CardCode" = T0."CardCode" 
LEFT OUTER JOIN OCRG ON OCRG."GroupCode" = OCRD."GroupCode" 
LEFT OUTER JOIN CRD7 C7 ON T0."CardCode" = C7."CardCode" AND T0."ShipToCode" = C7."Address" AND C7."AddrType" = 'S' 
INNER JOIN RIN1 T1 ON T0."DocEntry" = T1."DocEntry" 
LEFT OUTER JOIN OSLP SLP ON SLP."SlpCode" = T0."SlpCode" 
LEFT OUTER JOIN OITM ITM ON (ITM."ItemCode" = T1."ItemCode") 
INNER JOIN OITB ITB ON ITM."ItmsGrpCod" = ITB."ItmsGrpCod" 
INNER JOIN NNM1 N1 ON N1."Series" = T0."Series" 
INNER JOIN RIN12 T7 ON T0."DocEntry" = T7."DocEntry" 
LEFT OUTER JOIN RIN4 CGST ON T1."DocEntry" = CGST."DocEntry" AND T1."LineNum" = CGST."LineNum" AND CGST."staType" = -100 AND CGST."RelateType" = 1 
AND CGST."ExpnsCode" = -1 
LEFT OUTER JOIN RIN4 SGST ON T1."DocEntry" = SGST."DocEntry" AND T1."LineNum" = SGST."LineNum" AND SGST."staType" = -110 AND SGST."RelateType" = 1 
AND SGST."ExpnsCode" = -1 
LEFT OUTER JOIN RIN4 IGST ON T1."DocEntry" = IGST."DocEntry" AND T1."LineNum" = IGST."LineNum" AND IGST."staType" = -120 AND IGST."RelateType" = 1 
AND IGST."ExpnsCode" = -1 
WHERE T0.CANCELED = 'N'
--------------------------------------------------------------------------
Union all

SELECT T0."DocEntry", (CASE T0."GSTTranTyp" WHEN 'GA' THEN 'Gst Tax Invoice' WHEN 'GD' THEN 'Gst Debit Memo' 
WHEN '--' THEN 'Bill Of Supply' END) AS "GST Transaction Type",  T0."DocDate"  "Invoice Date", T0."DocNum" AS "Invoice No", 
N1."SeriesName" AS "DocSeries", N1."BeginStr" AS "DocSeriesPrefix", N1."EndStr" AS "DocSeriesSuffix", SLP."SlpName" AS "SALES PERSON NAME", 
T0."CardName" AS "Customer Billing Name", T7."BpGSTN" AS "Billing GSTIN", T7."LocStaGSTN" AS "State POS", 'S' AS "ItemType", '' AS "Item Code", 
T4."ExpnsName" AS "Item Description", NULL AS "unitMsr", (SELECT "SacCode" FROM OEXD WHERE T4."ExpnsName" = OEXD."ExpnsName") AS "HSN/SAC Code", 
-1 AS "Quantity", T3."LineTotal" AS "Unit Price", T3."LineTotal" * -1 AS "ItemTotalBefDi", NULL AS "Item Discount", T3."LineTotal" * -1 AS "Item Total After Discount", 
T3."LineTotal" * -1 AS "Basic Line Total", (T3."LineTotal" * -1) AS "Taxable Value", T3."TaxCode", IFNULL(CGST."TaxRate", 0) AS "CGST Rate", 
IFNULL(CGST."TaxSum", 0) * (-1) AS "CGST", IFNULL(SGST."TaxRate", 0) AS "SGST Rate", IFNULL(SGST."TaxSum", 0) * (-1) AS "SGST", 
IFNULL(IGST."TaxRate", 0) AS "IGST Rate", IFNULL(IGST."TaxSum", 0) * (-1) AS "IGST", (CASE WHEN IFNULL(CGST."RvsChrgTax", 0) + IFNULL(SGST."RvsChrgTax", 0) + 
IFNULL(IGST."RvsChrgTax", 0) <> 0 THEN 'Y' ELSE 'N' END) AS "Reverse Charge Flag", IFNULL(CGST."RvsChrgTax", 0) * (-1) AS "CGST Rev Tax", 
IFNULL(SGST."RvsChrgTax", 0) * (-1) AS "SGST Rev Tax", IFNULL(IGST."RvsChrgTax", 0) * (-1) AS "IGST Rev Tax", 
(IFNULL(T3."LineTotal", 0) + IFNULL(CGST."TaxSum", 0) + IFNULL(SGST."TaxSum", 0) + IFNULL(IGST."TaxSum", 0)) * (-1) AS "Total Incl GST", 
T0."RevRefNo" AS "Original Invoice No", T0."RevRefDate" AS "Original Invoice Date", T7."BpGSTN" AS "Original Customer GSTIN", NULL AS "ECommGSTN", 
NULL AS "AdvancePaymentDocDate", NULL AS "AdvancePaymentDocNum", T7."ImpORExp" AS "Flag Export Invoice", NULL AS "Export Type", T7."ImpExpNo" AS "Export No", 
T7."ImpExpDate" AS "Export Date", T7."BpCountry" AS "Customer Country", T7."BpGSTN" AS "Customer GSTNo", T0."Address" AS "Billing Address", T7."CityB" AS "Billing City", 
T7."ZipCodeB" AS "Billing Pin Code", T7."StateB" AS "Billing State", T0."ShipToCode" AS "Shipping Name", T0."Address2" AS "Shipping Address", 
T7."CityS" AS "Shipping City", T7."ZipCodeS" AS "Shipping Pin Code", T7."BpStateCod" AS "Shipping State", T7."BPStatGSTN" AS "Shipping State Code", 
MONTH(T0."RevRefDate") AS "Revision_Month", (CASE WHEN T0."DutyStatus" = 'Y' THEN 'WPAY' ELSE 'WOPAY' END) AS "Duty_Status", NULL AS "Port Code", 
(SELECT "GSTType" FROM OGTY WHERE "AbsEntry" = T7."BpGSTType") AS "Customer GST Type", T7."LocGSTN" AS "Location GSTNo", T7."LocStatCod" AS "Location State", 
'AR Credit Memo' AS "Doc Type", T0."DocDueDate" AS "Invoice Due Date", T0."Comments", '' AS "item group", '' AS "G/L Account" 
FROM ORIN T0 
LEFT OUTER JOIN OCRD ON OCRD."CardCode" = T0."CardCode" 
LEFT OUTER JOIN OCRG ON OCRG."GroupCode" = OCRD."GroupCode" 
LEFT OUTER JOIN CRD7 C7 ON T0."CardCode" = C7."CardCode" AND T0."ShipToCode" = C7."Address" AND C7."AddrType" = 'S' 
LEFT OUTER JOIN OSLP SLP ON SLP."SlpCode" = T0."SlpCode" 
INNER JOIN NNM1 N1 ON N1."Series" = T0."Series" 
INNER JOIN RIN3 T3 ON T0."DocEntry" = T3."DocEntry" 
INNER JOIN RIN12 T7 ON T0."DocEntry" = T7."DocEntry" 
INNER JOIN OEXD T4 ON T3."ExpnsCode" = T4."ExpnsCode" 
LEFT OUTER JOIN RIN4 CGST ON T3."DocEntry" = CGST."DocEntry" AND T3."ExpnsCode" = CGST."ExpnsCode" AND CGST."staType" = -100 AND CGST."ExpnsCode" <> -1 
LEFT OUTER JOIN RIN4 SGST ON T3."DocEntry" = SGST."DocEntry" AND T3."ExpnsCode" = SGST."ExpnsCode" AND SGST."staType" = -110 AND SGST."ExpnsCode" <> -1 
LEFT OUTER JOIN RIN4 IGST ON T3."DocEntry" = IGST."DocEntry" AND T3."ExpnsCode" = IGST."ExpnsCode" AND IGST."staType" = -120 AND IGST."ExpnsCode" <> -1 
WHERE T0.CANCELED = 'N'
 
) a order by a."DocEntry"