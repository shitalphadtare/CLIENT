create view SALS_REGISTER_ITEM_GST as
		select * from (
SELECT OI."DocEntry" AS "DocEntry", 
(CASE WHEN OI."GSTTranTyp" = 'GA' THEN 'GST Tax Invoice' 
      WHEN OI."GSTTranTyp" = 'GD' THEN 'GST Debit Memo' 
      WHEN OI."GSTTranTyp" = '--' THEN 'Bill Of Supply' END) AS "Transaction Type", 
(CASE WHEN N2."BeginStr" IS NULL AND N2."EndStr" IS NULL THEN (
		IFNULL(N2."SeriesName", '') || '/' || CAST(OI."DocNum" AS char(20))) ELSE 
		IFNULL(N2."BeginStr", '') || CAST(OI."DocNum" AS char(20)) || IFNULL(N2."EndStr", '') END) AS "Invoice No", 
OI."DocDate" AS "Invoice Date", 
(SELECT STRING_AGG(t0."DocNum", ',') AS "SO" FROM (SELECT DISTINCT ODLN."DocNum" FROM ODLN INNER JOIN INV1 
 ON INV1."BaseEntry" = ODLN."DocEntry" AND INV1."DocEntry" = oi."DocEntry") AS "T0") AS "DEL No", 
 (SELECT STRING_AGG(t0."DocDate", ',') AS "SO" FROM (SELECT DISTINCT TO_NVARCHAR(TO_DATE(ODLN."DocDate"), 'YYYY-MM-DD') AS "DocDate" 
 FROM ODLN ODLN INNER JOIN INV1 INV1 ON INV1."BaseEntry" = ODLN."DocEntry" AND INV1."DocEntry" = oi."DocEntry") AS "T0")
  AS "DEL Date", (CASE WHEN OI."DocType" = 'I' THEN 'ITEM' ELSE 'SERVICE' END) AS "Document Type", 
  OI."NumAtCard" AS "Customer Ref No", OI."CardCode" AS "Customer Code", OI."CardName" AS "Customer Name", 
  (SELECT "GSTRegnNo" FROM CRD1 WHERE "Address" = (SELECT "ShipToDef" FROM OCRD WHERE "CardCode" = OI."CardCode") AND 
  "AdresType" = 'S' AND CRD1."CardCode" = OI."CardCode") AS "Customer GSTIN No", L."GSTRegnNo" AS "WhsGSTIN_No", 
  (SELECT SUM(INV1."LineTotal") FROM INV1 INNER JOIN OINV ON inv1."DocEntry" = OINV."DocEntry" WHERE inv1."DocEntry" = oi."DocEntry" 
  GROUP BY inv1."DocEntry", oinv."DocCur") AS "Invoice Value", IFNULL(OI."DiscSum", 0) AS "Discount Amount", 
  (SELECT SUM(INV1."LineTotal") FROM INV1 INNER JOIN OINV ON inv1."DocEntry" = OINV."DocEntry" WHERE inv1."DocEntry" = oi."DocEntry" 
  GROUP BY inv1."DocEntry", oinv."DocCur") - OI."DiscSum" AS "Net Amount", IFNULL(CGST."TaxSum", 0) AS "CGST", 
  IFNULL(SGST."TaxSum", 0) AS "SGST", IFNULL(IGST."TaxSum", 0) AS "IGST", IFNULL(Oi."TotalExpns", 0) AS "Total Fright DocL", 
  oi."RoundDif" AS "Round Off", IFNULL(Oi."DocTotal", 0) AS "Doc Total", WHS."WhsName" AS "Warehouse Name", 
  Oi."Comments" AS "Remarks", OI."DocCur" AS "Currency", OI."DocTotalFC" AS "DocTotal FC" 
  
  FROM OINV oi 
  INNER JOIN INV1 i1 ON OI."DocEntry" = I1."DocEntry" 
  LEFT OUTER JOIN OSTC O ON O."Code" = I1."TaxCode" 
  LEFT OUTER JOIN OITM M1 ON I1."ItemCode" = M1."ItemCode" 
  LEFT OUTER JOIN OWHS WHS ON i1."WhsCode" = WHS."WhsCode" 
  LEFT OUTER JOIN ODLN OD ON I1."BaseEntry" = OD."DocEntry" 
  LEFT OUTER JOIN NNM1 N1 ON N1."Series" = OD."Series" 
  LEFT OUTER JOIN NNM1 N2 ON N2."Series" = OI."Series" 
  LEFT OUTER JOIN OLCT L ON L."Code" = whs."Location" 
  LEFT OUTER JOIN (SELECT SUM(IFNULL("TaxSum", 0)) AS "TaxSum", "DocEntry" FROM inv4 CGST WHERE CGST."staType" = -100 
				GROUP BY "DocEntry") AS CGST ON CGST."DocEntry" = i1."DocEntry" 
LEFT OUTER JOIN (SELECT SUM(IFNULL("TaxSum", 0)) AS "TaxSum", "DocEntry" FROM inv4 SGST WHERE SGST."staType" = -110 
				GROUP BY "DocEntry") AS SGST ON SGST."DocEntry" = i1."DocEntry" 
LEFT OUTER JOIN (SELECT SUM(IFNULL("TaxSum", 0)) AS "TaxSum", "DocEntry" FROM inv4 IGST WHERE IGST."staType" = -120 
				GROUP BY "DocEntry") IGST ON IGST."DocEntry" = i1."DocEntry" 
LEFT OUTER JOIN (SELECT INV3."DocEntry", SUM(CASE WHEN INV3."FixCurr" = 'INR' THEN IFNULL((INV3."LineTotal"), 0) ELSE 
				IFNULL((INV3."TotalSumSy"), 0) END) AS "DocLevFreight" FROM INV3 WHERE INV3."ExpnsCode" <> '' 
				GROUP BY INV3."DocEntry") AS DocLevFreight ON I1."DocEntry" = DocLevFreight."DocEntry" 
LEFT OUTER JOIN (SELECT "CardCode", "Address", "TaxId0", "TaxId1", "TaxId2", "TaxId3" FROM CRD7 crd7 WHERE "Address" <> '' 
				AND ("AddrType" = 'S')) AS crd7 ON OI."CardCode" = crd7."CardCode" AND OI."ShipToCode" = crd7."Address" 
WHERE OI."CANCELED" = 'N' AND OI."DocType" IN ('I','S')
--------------------------------------------------------------------------------------------------------------------------
union all

SELECT OI."DocEntry" AS "DocEntry", (CASE WHEN OI."GSTTranTyp" = 'GA' THEN 'GST Tax Invoice' WHEN OI."GSTTranTyp" = 'GD' THEN 'GST Debit Memo' WHEN 
OI."GSTTranTyp" = '--' THEN 'Bill Of Supply' END) AS "Transaction Type", (CASE WHEN N2."BeginStr" IS NULL AND N2."EndStr" IS NULL THEN 
(IFNULL(N2."SeriesName", n'') || '/' || CAST(OI."DocNum" AS char(20))) ELSE IFNULL(N2."BeginStr", n'') || CAST(OI."DocNum" AS char(4)) || 
IFNULL(N2."EndStr", n'') END) AS "Invoice No", OI."DocDate" AS "Invoice Date", 
(SELECT STRING_AGG(t0."DocNum", ',') AS "SO" FROM 
(SELECT DISTINCT ODLN."DocNum" FROM ODLN  ODLN INNER JOIN RIN1 RIN1 ON RIN1."BaseEntry" = ODLN."DocEntry"
 AND RIN1."DocEntry" = oi."DocEntry") AS "T0") AS "DEL No", (SELECT STRING_AGG(t0."DocDate", ',') AS "SO" FROM 
 (SELECT DISTINCT TO_NVARCHAR(TO_DATE(ODLN."DocDate"), 'YYYY-MM-DD') AS "DocDate" FROM ODLN ODLN
 INNER JOIN RIN1  ON RIN1."BaseEntry" = ODLN."DocEntry" AND RIN1."DocEntry" = oi."DocEntry") AS "T0") AS "DEL Date", 
 (CASE WHEN OI."DocType" = 'I' THEN 'ITEM' ELSE 'SERVICE' END) AS "Document Type", OI."NumAtCard" AS "Customer Ref No", 
 OI."CardCode" AS "Customer Code", OI."CardName" AS "Customer Name", (SELECT "GSTRegnNo" FROM CRD1 WHERE "Address" = 
 (SELECT "ShipToDef" FROM OCRD WHERE "CardCode" = OI."CardCode") AND "AdresType" = 'S' AND CRD1."CardCode" = OI."CardCode") AS "Customer GSTIN No",
  L."GSTRegnNo" AS "WhsGSTIN_No", (SELECT SUM(RIN1."LineTotal") 
  FROM RIN1 
  INNER JOIN ORIN ON RIN1."DocEntry" = ORIN."DocEntry" 
  WHERE RIN1."DocEntry" = oi."DocEntry" GROUP BY RIN1."DocEntry", oRIN."DocCur") * (-1) AS "Invoice Value", 
  IFNULL(OI."DiscSum", 0) * (-1) AS "Discount Amount", 
  ((SELECT SUM(RIN1."LineTotal") FROM RIN1 INNER JOIN ORIN ON RIN1."DocEntry" = ORIN."DocEntry" WHERE RIN1."DocEntry" = oi."DocEntry" 
  GROUP BY RIN1."DocEntry", oRIN."DocCur") - OI."DiscSum") * (-1) AS "Net Amount", IFNULL(CGST."TaxSum", 0) * (-1) AS "CGST", 
  IFNULL(SGST."TaxSum", 0) * (-1) AS "SGST", IFNULL(IGST."TaxSum", 0) * (-1) AS "IGST", IFNULL(Oi."TotalExpns", 0) * (-1) AS "Total Fright DocL", 
  oi."RoundDif" AS "Round Off", IFNULL(Oi."DocTotal", 0) * (-1) AS "Doc Total", WHS."WhsName" AS "Warehouse Name", 
  Oi."Comments" AS "Remarks", OI."DocCur" AS "Currency", OI."DocTotalFC" * (-1) AS "DocTotal FC" 
  FROM ORIN oi 
  INNER JOIN RIN1 i1 ON OI."DocEntry" = I1."DocEntry" 
  LEFT OUTER JOIN OSTC O ON O."Code" = I1."TaxCode"
   LEFT OUTER JOIN OWHS WHS ON i1."WhsCode" = WHS."WhsCode" 
   LEFT OUTER JOIN OITM M1 ON I1."ItemCode" = M1."ItemCode" 
   LEFT OUTER JOIN ODLN OD ON I1."BaseEntry" = OD."DocEntry" 
   LEFT OUTER JOIN NNM1 N1 ON N1."Series" = OD."Series" 
   LEFT OUTER JOIN NNM1 N2 ON N2."Series" = OI."Series" 
   LEFT OUTER JOIN OLCT L ON L."Code" = WHS."Location" 
   LEFT OUTER JOIN (SELECT SUM(IFNULL("TaxSum", 0)) AS "TaxSum", "DocEntry" 
   				FROM RIN4 CGST WHERE CGST."staType" = -100 GROUP BY "DocEntry") AS CGST ON CGST."DocEntry" = i1."DocEntry" 
   LEFT OUTER JOIN (SELECT SUM(IFNULL("TaxSum", 0)) AS "TaxSum", "DocEntry" 
  				FROM RIN4 SGST WHERE SGST."staType" = -110 GROUP BY "DocEntry") AS SGST ON SGST."DocEntry" = i1."DocEntry" 
   LEFT OUTER JOIN (SELECT SUM(IFNULL("TaxSum", 0)) AS "TaxSum", "DocEntry" 
   				FROM RIN4 IGST WHERE IGST."staType" = -120 GROUP BY "DocEntry") AS IGST ON IGST."DocEntry" = i1."DocEntry" 
   LEFT OUTER JOIN (SELECT RIN2."DocEntry", SUM(CASE WHEN RIN2."FixCurr" = 'INR' THEN IFNULL((RIN2."LineTotal"), 0) 
   					ELSE IFNULL((RIN2."TotalSumSy"), 0) END) AS "LLFreTot" 
   					FROM RIN2 WHERE RIN2."ExpnsCode" <> '' GROUP BY RIN2."DocEntry") AS LLFreTot ON I1."DocEntry" = LLFreTot."DocEntry" 
  LEFT OUTER JOIN (SELECT RIN3."DocEntry", SUM(CASE WHEN RIN3."FixCurr" = 'INR' THEN IFNULL((RIN3."LineTotal"), 0) ELSE 
  					IFNULL((RIN3."TotalSumSy"), 0) END) AS "DocLevFreight" 
  					FROM RIN3 WHERE RIN3."ExpnsCode" <> '' GROUP BY RIN3."DocEntry") AS DocLevFreight ON I1."DocEntry" = DocLevFreight."DocEntry" 
  LEFT OUTER JOIN (SELECT "CardCode", "Address", "TaxId0", "TaxId1", "TaxId2", "TaxId3" FROM CRD7 crd7 WHERE "Address" <> '' AND ("AddrType" = 'S')) AS crd7 
  			ON OI."CardCode" = crd7."CardCode" AND OI."ShipToCode" = crd7."Address" 
  			WHERE OI."CANCELED" = 'N' AND OI."DocType" IN ('I','S')
  			-- and OI.DocDate>=@FromDate and Oi.DocDate<=@ToDate and L.gstRegnNo=@GSTINNo --and (select GroupName from OCRG where GroupCode=(select GroupCode from OCRD where Cardcode=oi.CardCode))>=@FromCust and (select GroupName from OCRG where GroupCode=(select GroupCode from OCRD where Cardcode=oi.CardCode))<=@ToCust
) as sr
group by sr."DEL No",
sr."Invoice No",
sr."Document Type",
sr."DEL Date",
sr."Invoice Date",
sr."Currency",
sr."Customer GSTIN No",
sr."WhsGSTIN_No",
sr."Customer Code",
sr."Customer Name",
sr."Customer Ref No",
sr."Invoice Value",
sr."DocEntry",
sr."Net Amount",
sr."Discount Amount",
sr."CGST",sr."SGST",sr."IGST",
sr."Total Fright DocL",
sr."Round Off",
sr."Doc Total",
sr."Remarks",
sr."DocTotal FC",
sr."Transaction Type",sr."Warehouse Name"

order by sr."Invoice Date"







