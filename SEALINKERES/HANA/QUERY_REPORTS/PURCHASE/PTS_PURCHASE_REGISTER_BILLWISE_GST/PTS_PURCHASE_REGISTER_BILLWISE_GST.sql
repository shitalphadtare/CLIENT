CREATE VIEW PTS_PURCHASE_REGISTER_BILLWISE_GST   AS SELECT
	 "SR"."DocEntry" ,
	 "SR"."Invoice No" ,
	 "SR"."Invoice Date" ,
	 "SR"."GRN No" ,
	 "SR"."GRN Date" ,
	 "SR"."Document Type" ,
	 "SR"."Vendor Ref No" ,
	 "SR"."Vendor Code" ,
	 "SR"."Vendor Name" ,
	 "SR"."Invoice Value" ,
	 "SR"."Discount Amount" ,
	 "SR"."Net Amount" ,
	 "SR"."CGST" ,
	 "SR"."SGST" ,
	 "SR"."IGST" ,
	 "SR"."Total Fright DocL" ,
	 "SR"."Round Off" ,
	 "SR"."Doc Total" ,
	 "SR"."GSTIN No" ,
	 "SR"."Remarks" ,
	 "SR"."Currency" ,
	 "SR"."DocTotal FC" 
from ( SELECT
	 OI."DocEntry" AS "DocEntry",
	 (CASE WHEN N2."BeginStr" IS NULL 
		AND N2."EndStr" IS NULL 
		THEN (IFNULL(N2."SeriesName",
	 n'') || '/' || CAST(OI."DocNum" AS char(20))) 
		ELSE IFNULL(N2."BeginStr",
	 n'') || CAST(OI."DocNum" AS char(4)) || IFNULL(N2."EndStr",
	 n'') 
		END) AS "Invoice No",
	 CAST(CAST(OI."DocDate" AS varchar) AS char(40)) AS "Invoice Date",
	 (SELECT
	 STRING_AGG(t0."DocNum",
	 ',') AS "SO" 
		FROM (SELECT
	 DISTINCT OPDN."DocNum" 
			FROM OPDN 
			INNER JOIN PCH1 ON PCH1."BaseEntry" = OPDN."DocEntry" 
			AND PCH1."DocEntry" = oi."DocEntry") AS "T0") AS "GRN No",
	 (SELECT
	 STRING_AGG(t0."DocDate",
	 ',') AS "SO" 
		FROM (SELECT
	 DISTINCT TO_NVARCHAR(TO_DATE(OPDN."DocDate"),
	 'YYYY-MM-DD') AS "DocDate" 
			FROM OPDN 
			INNER JOIN PCH1 ON PCH1."BaseEntry" = OPDN."DocEntry" 
			AND PCH1."DocEntry" = oi."DocEntry") AS "T0") AS "GRN Date",
	 (CASE WHEN OI."DocType" = 'I' 
		THEN 'ITEM' 
		ELSE 'SERVCE' 
		END) AS "Document Type",
	 OI."NumAtCard" AS "Vendor Ref No",
	 OI."CardCode" AS "Vendor Code",
	 OI."CardName" AS "Vendor Name",
	 (SELECT
	 SUM(PCH1."LineTotal") 
		FROM PCH1 
		INNER JOIN OPCH ON PCH1."DocEntry" = OPCH."DocEntry" 
		WHERE PCH1."DocEntry" = oi."DocEntry" 
		GROUP BY PCH1."DocEntry",
	 OPCH."DocCur") AS "Invoice Value",
	 IFNULL(OI."DiscSum",
	 0) AS "Discount Amount",
	 (SELECT
	 SUM(PCH1."LineTotal") 
		FROM PCH1 
		INNER JOIN OPCH ON PCH1."DocEntry" = OPCH."DocEntry" 
		WHERE PCH1."DocEntry" = oi."DocEntry" 
		GROUP BY PCH1."DocEntry",
	 OPCH."DocCur") - OI."DiscSum" AS "Net Amount",
	 IFNULL(CGST."TaxSum",
	 0) AS "CGST",
	 IFNULL(SGST."TaxSum",
	 0) AS "SGST",
	 IFNULL(IGST."TaxSum",
	 0) AS "IGST",
	 IFNULL(Oi."TotalExpns",
	 0) AS "Total Fright DocL",
	 oi."RoundDif" AS "Round Off",
	 IFNULL(Oi."DocTotal",
	 0) AS "Doc Total",
	 (SELECT
	 CRD1."GSTRegnNo" 
		FROM CRD1 
		INNER JOIN OCRD ON OCRD."CardCode" = CRD1."CardCode" 
		WHERE OCRD."CardCode" = oi."CardCode" 
		AND CRD1."AdresType" = 'B' 
		AND oi."PayToCode" = CRD1."Address") AS "GSTIN No",
	 Oi."Comments" AS "Remarks",
	 OI."DocCur" AS "Currency",
	 OI."DocTotalFC" AS "DocTotal FC" 
	FROM OPCH oi 
	INNER JOIN PCH1 i1 ON OI."DocEntry" = I1."DocEntry" 
	LEFT OUTER JOIN OSTC O ON O."Code" = I1."TaxCode" 
	LEFT OUTER JOIN OITM M1 ON I1."ItemCode" = M1."ItemCode" 
	LEFT OUTER JOIN OPDN OD ON I1."BaseEntry" = OD."DocEntry" 
	LEFT OUTER JOIN NNM1 N1 ON N1."Series" = OD."Series" 
	LEFT OUTER JOIN NNM1 N2 ON N2."Series" = OI."Series" 
	LEFT OUTER JOIN (SELECT
	 SUM(IFNULL("TaxSum",
	 0)) AS "TaxSum",
	 "DocEntry" 
		FROM PCH4 CGST 
		WHERE CGST."staType" = -100 
		GROUP BY "DocEntry") AS CGST ON CGST."DocEntry" = i1."DocEntry" 
	LEFT OUTER JOIN (SELECT
	 SUM(IFNULL("TaxSum",
	 0)) AS "TaxSum",
	 "DocEntry" 
		FROM PCH4 SGST 
		WHERE SGST."staType" = -110 
		GROUP BY "DocEntry") AS SGST ON SGST."DocEntry" = i1."DocEntry" 
	LEFT OUTER JOIN (SELECT
	 SUM(IFNULL("TaxSum",
	 0)) AS "TaxSum",
	 "DocEntry" 
		FROM PCH4 IGST 
		WHERE IGST."staType" = -120 
		GROUP BY "DocEntry") AS IGST ON IGST."DocEntry" = i1."DocEntry" 
	LEFT OUTER JOIN (SELECT
	 PCH3."DocEntry",
	 SUM(CASE WHEN PCH3."FixCurr" = 'INR' 
			THEN IFNULL((PCH3."LineTotal"),
	 0) 
			ELSE IFNULL((PCH3."TotalSumSy"),
	 0) 
			END) AS "DocLevFreight" 
		FROM PCH3 
		WHERE PCH3."ExpnsCode" <> '' 
		GROUP BY PCH3."DocEntry") AS DocLevFreight ON I1."DocEntry" = DocLevFreight."DocEntry" 
	LEFT OUTER JOIN (SELECT
	 "CardCode",
	 "Address",
	 "TaxId0",
	 "TaxId1",
	 "TaxId2",
	 "TaxId3" 
		FROM CRD7 crd7 
		WHERE "Address" <> '' 
		AND ("AddrType" = 'S')) AS crd7 ON OI."CardCode" = crd7."CardCode" 
	AND OI."ShipToCode" = crd7."Address" 
	WHERE OI.CANCELED = 'N' 
	AND OI."DocType" IN ('I',
	'S') --------------------------------------------------------------------------------------------------------------------------

	union all select
	 OI."DocEntry" AS "DocEntry",
	 (CASE WHEN N2."BeginStr" IS NULL 
		AND N2."EndStr" IS NULL 
		THEN (IFNULL(N2."SeriesName",
	 n'') || '/' || CAST(OI."DocNum" AS char(20))) 
		ELSE IFNULL(N2."BeginStr",
	 n'') || CAST(OI."DocNum" AS char(4)) || IFNULL(N2."EndStr",
	 n'') 
		END) AS "Invoice No",
	 OI."DocDate" AS "Invoice Date",
	 (SELECT
	 STRING_AGG(t0."DocNum",
	 ',') AS "SO" 
		FROM (SELECT
	 DISTINCT OPDN."DocNum" 
			FROM OPDN 
			INNER JOIN RPC1 ON RPC1."BaseEntry" = OPDN."DocEntry" 
			AND RPC1."DocEntry" = OI."DocEntry") "T0") "GRN No",
	 (SELECT
	 STRING_AGG(t0."DocDate",
	 ',')"SO" 
		from (SELECT
	 distinct TO_NVARCHAR(TO_DATE(opdn."DocDate"),
	 'YYYY-MM-DD') "DocDate" 
			FROM opdn 
			inner join rpc1 on rpc1."BaseEntry"=opdn."DocEntry" 
			and rpc1."DocEntry"=oi."DocEntry" ) "T0") "GRN Date",
	 (CASE WHEN OI."DocType" = 'I' 
		THEN 'ITEM' 
		ELSE 'SERVCE' 
		END) AS "Document Type",
	 OI."NumAtCard" AS "Vendor Ref No",
	 OI."CardCode" AS "Vendor Code",
	 OI."CardName" AS "Vendor Name",
	 (SELECT
	 SUM(RPC1."LineTotal") 
		FROM RPC1 
		INNER JOIN ORPC ON RPC1."DocEntry" = ORPC."DocEntry" 
		WHERE RPC1."DocEntry" = oi."DocEntry" 
		GROUP BY RPC1."DocEntry",
	 ORPC."DocCur") * (-1) AS "Invoice Value",
	 IFNULL(OI."DiscSum",
	 0) * (-1) AS "Discount Amount",
	 ((SELECT
	 SUM(RPC1."LineTotal") 
			FROM RPC1 
			INNER JOIN ORPC ON RPC1."DocEntry" = ORPC."DocEntry" 
			WHERE RPC1."DocEntry" = oi."DocEntry" 
			GROUP BY RPC1."DocEntry",
	 ORPC."DocCur") - OI."DiscSum") * (-1) AS "Net Amount",
	 IFNULL(CGST."TaxSum",
	 0) * (-1) AS "CGST",
	 IFNULL(SGST."TaxSum",
	 0) * (-1) AS "SGST",
	 IFNULL(IGST."TaxSum",
	 0) * (-1) AS "IGST",
	 IFNULL(Oi."TotalExpns",
	 0) * (-1) AS "Total Fright DocL",
	 oi."RoundDif" AS "Round Off",
	 IFNULL(Oi."DocTotal",
	 0) * (-1) AS "Doc Total",
	 (SELECT
	 CRD1."GSTRegnNo" 
		FROM CRD1 
		INNER JOIN OCRD ON OCRD."CardCode" = CRD1."CardCode" 
		WHERE OCRD."CardCode" = oi."CardCode" 
		AND CRD1."AdresType" = 'B' 
		AND oi."PayToCode" = CRD1."Address") AS "GSTIN No",
	 Oi."Comments" AS "Remarks",
	 OI."DocCur" AS "Currency",
	 OI."DocTotalFC" * (-1) AS "DocTotal FC" 
	FROM ORPC OI 
	INNER JOIN RPC1 i1 ON OI."DocEntry" = I1."DocEntry" 
	LEFT OUTER JOIN OSTC O ON O."Code" = I1."TaxCode" 
	LEFT OUTER JOIN OITM M1 ON I1."ItemCode" = M1."ItemCode" 
	LEFT OUTER JOIN OPDN OD ON I1."BaseEntry" = OD."DocEntry" 
	LEFT OUTER JOIN NNM1 N1 ON N1."Series" = OD."Series" 
	LEFT OUTER JOIN NNM1 N2 ON N2."Series" = OI."Series" 
	LEFT OUTER JOIN (SELECT
	 SUM(IFNULL("TaxSum",
	 0)) AS "TaxSum",
	 "DocEntry" 
		FROM RPC4 CGST 
		WHERE CGST."staType" = -100 
		GROUP BY "DocEntry") AS CGST ON CGST."DocEntry" = i1."DocEntry" 
	LEFT OUTER JOIN (SELECT
	 SUM(IFNULL("TaxSum",
	 0)) AS "TaxSum",
	 "DocEntry" 
		FROM RPC4 SGST 
		WHERE SGST."staType" = -110 
		GROUP BY "DocEntry") AS SGST ON SGST."DocEntry" = i1."DocEntry" 
	LEFT OUTER JOIN (SELECT
	 SUM(IFNULL("TaxSum",
	 0)) AS "TaxSum",
	 "DocEntry" 
		FROM RPC4 IGST 
		WHERE IGST."staType" = -120 
		GROUP BY "DocEntry") AS IGST ON IGST."DocEntry" = i1."DocEntry" 
	LEFT OUTER JOIN (SELECT
	 RPC2."DocEntry",
	 SUM(CASE WHEN RPC2."FixCurr" = 'INR' 
			THEN IFNULL((RPC2."LineTotal"),
	 0) 
			ELSE IFNULL((RPC2."TotalSumSy"),
	 0) 
			END) AS "LLFreTot" 
		FROM RPC2 
		WHERE RPC2."ExpnsCode" <> '' 
		GROUP BY RPC2."DocEntry") AS LLFreTot ON I1."DocEntry" = LLFreTot."DocEntry" 
	LEFT OUTER JOIN (SELECT
	 RPC3."DocEntry",
	 SUM(CASE WHEN RPC3."FixCurr" = 'INR' 
			THEN IFNULL((RPC3."LineTotal"),
	 0) 
			ELSE IFNULL((RPC3."TotalSumSy"),
	 0) 
			END) AS "DocLevFreight" 
		FROM RPC3 
		WHERE RPC3."ExpnsCode" <> '' 
		GROUP BY RPC3."DocEntry") AS DocLevFreight ON I1."DocEntry" = DocLevFreight."DocEntry" 
	LEFT OUTER JOIN (SELECT
	 "CardCode",
	 "Address",
	 "TaxId0",
	 "TaxId1",
	 "TaxId2",
	 "TaxId3" 
		FROM CRD7 crd7 
		WHERE "Address" <> '' 
		AND ("AddrType" = 'S')) AS crd7 ON OI."CardCode" = crd7."CardCode" 
	AND OI."ShipToCode" = crd7."Address" 
	WHERE OI.CANCELED = 'N' 
	AND OI."DocType" IN ('I',
	'S') ) as sr 
group by sr."GRN No",
	 sr."Invoice No",
	 sr."GRN Date",
	 sr."Invoice Date",
	 sr."Currency",
	 sr."Document Type",
	 sr."Vendor Code",
	 sr."Vendor Name",
	 sr."Vendor Ref No",
	 sr."Invoice Value",
	 sr."DocEntry",
	 sr."Net Amount",
	 sr."Discount Amount",
	 sr."CGST",
	sr."SGST",
	sr."IGST",
	 sr."Total Fright DocL",
	 sr."Round Off",
	 sr."Doc Total",
	 sr."GSTIN No",
	 sr."Remarks",
	 sr."DocTotal FC" 
order by sr."Invoice Date" 