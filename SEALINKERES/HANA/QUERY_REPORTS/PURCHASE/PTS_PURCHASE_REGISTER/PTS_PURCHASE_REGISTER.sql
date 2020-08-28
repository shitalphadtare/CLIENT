CREATE view PTS_PURCHASE_REGISTER as
select * from (
SELECT OI."DocEntry" AS "DocEntry", IFNULL(N1."SeriesName", n'') || '/' || CAST(OI."DocNum" AS char(20)) AS "Invoice No", 
OI."DocDate" AS "Invoice Date", 
(SELECT STRING_AGG(t0."DocNum", ',') AS "SO" 
FROM (SELECT DISTINCT OPDN."DocNum" FROM OPDN INNER JOIN PCH1 ON PCH1."BaseEntry" = OPDN."DocEntry" AND PCH1."DocEntry" = oi."DocEntry") 
AS "T0") AS "GRN No", 
(SELECT STRING_AGG(t0."DocDate", ',') AS "SO" FROM (SELECT DISTINCT TO_NVARCHAR(TO_DATE(OPDN."DocDate"), 'YYYY-MM-DD') AS "DocDate" 
FROM OPDN INNER JOIN PCH1 ON PCH1."BaseEntry" = OPDN."DocEntry" AND PCH1."DocEntry" = oi."DocEntry") AS "T0") AS "GRN Date", 
'' AS "Vendor Ref Date", OI."CardCode" AS "Vendor Code", OI."CardName" AS "Vendor Name", 
(SELECT SUM(PCH1."Quantity" * (CASE WHEN PCH1."Currency" = 'INR' AND OPCH."DocCur" = 'INR' THEN (PCH1."PriceBefDi") WHEN PCH1."Currency" <> 'INR' 
AND OPCH."DocCur" <> 'INR' THEN (PCH1."Rate" * PCH1."PriceBefDi") WHEN PCH1."Currency" <> 'INR' 
AND OPCH."DocCur" = 'INR' THEN (PCH1."Rate" * PCH1."PriceBefDi") WHEN PCH1."Currency" = 'INR' AND OPCH."DocCur" <> 'INR' 
THEN (OPCH."DocRate" * PCH1."PriceBefDi") END)) FROM PCH1 
INNER JOIN OPCH ON PCH1."DocEntry" = OPCH."DocEntry" WHERE PCH1."DocEntry" = oi."DocEntry" 
GROUP BY PCH1."DocEntry", OPCH."DocCur") AS "Value Before Disc", 

(SELECT SUM(PCH1."Quantity" * (CASE WHEN PCH1."Currency" = 'INR' AND OPCH."DocCur" = 'INR' THEN (PCH1."Price") 
WHEN PCH1."Currency" <> 'INR' AND OPCH."DocCur" <> 'INR' THEN (PCH1."Rate" * PCH1."Price") WHEN PCH1."Currency" <> 'INR' AND OPCH."DocCur" = 'INR' 
THEN (PCH1."Rate" * PCH1."Price") WHEN PCH1."Currency" = 'INR' AND OPCH."DocCur" <> 'INR' THEN (OPCH."DocRate" * PCH1."Price") END)) 
FROM PCH1 INNER JOIN OPCH ON PCH1."DocEntry" = OPCH."DocEntry" WHERE PCH1."DocEntry" = oi."DocEntry" GROUP BY PCH1."DocEntry", OPCH."DocCur") AS "Value After Disc", 
(SELECT (CASE WHEN OPCH."DocCur" = 'INR' THEN SUM(IFNULL(PCH1."LineTotal", 0)) ELSE SUM(IFNULL(PCH1."TotalSumSy", 0)) END) 
FROM PCH1 INNER JOIN OPCH ON PCH1."DocEntry" = OPCH."DocEntry" WHERE PCH1."DocEntry" = oi."DocEntry" 
GROUP BY PCH1."DocEntry", OPCH."DocCur") AS "Taxable Amt before Ex Ser Tax", 

(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ISTax."ISTax", 0) ELSE IFNULL(ISTax."ISTaxFC", 0) END) AS "Service Tax ItemL", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(IExDuty."IExDuty", 0) ELSE IFNULL(IExDuty."IExDutyFC", 0) END) AS "Excise Duty ItemL", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ItmAED."ItmAED", 0) ELSE IFNULL(ItmAED."ItmAEDFC", 0) END) AS "AED ItemL", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ICeH."ICeH", 0) ELSE IFNULL(ICeH."ICeHFC", 0) END) + 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ICeH1."ICeH1", 0) ELSE IFNULL(ICeH1."ICeH1FC", 0) END) AS "Cess HeCess ItemL", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(IEXD.IEXD, 0) ELSE IFNULL(IEXD.IEXDFC, 0) END) AS "EXD ItemL", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(IKKCess."IKKCess", 0) ELSE IFNULL(IKKCess."IKKCessFC", 0) END) AS "KKCess ItemL", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ISBCess."ISBCess", 0) ELSE IFNULL(ISBCess."ISBCessFC", 0) END) AS "SBCess ItemL", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(IHSCess_ST."IHSCess_ST", 0) ELSE IFNULL(IHSCess_ST."IHSCess_STFC", 0) END) AS "HSCess ST ItemL", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ISED.ISED, 0) ELSE IFNULL(ISED.ISEDFC, 0) END) AS "SED ItemL", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ICess_ST."ICess_ST", 0) ELSE IFNULL(ICess_ST."ICess_STFC", 0) END) AS "ICess ST ItemL", 
IFNULL(ItmVAT."ItmVAT", 0) AS "VAT ItemL", IFNULL(ItmCST."ItmCST", 0) AS "CST ItemL", IFNULL(LLFreTot."LLFreTot", 0) AS "Total Fright ItemL", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ISTaxD."ISTax", 0) ELSE IFNULL(ISTaxD."ISTaxFC", 0) END) AS "Service Tax ItemL Fre", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(IExDutyD."IExDuty", 0) ELSE IFNULL(IExDutyD."IExDutyFC", 0) END) AS "Excise Duty ItemL Fre", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ItmAEDD."ItmAED", 0) ELSE IFNULL(ItmAEDD."ItmAEDFC", 0) END) AS "AED ItemL Fre", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ICeHD."ICeH", 0) ELSE IFNULL(ICeHD."ICeHFC", 0) END) + 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ICeH1D."ICeH1", 0) ELSE IFNULL(ICeH1D."ICeH1FC", 0) END) AS "Cess HeCess ItemL Fre", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(IEXDD.IEXD, 0) ELSE IFNULL(IEXDD.IEXDFC, 0) END) AS "EXD ItemL Fre", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(IKKCessD."IKKCess", 0) ELSE IFNULL(IKKCessD."IKKCessFC", 0) END) AS "KKCess ItemL Fre", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ISBCessD."ISBCess", 0) ELSE IFNULL(ISBCessD."ISBCessFC", 0) END) AS "SBCess ItemL Fre", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(IHSCess_STD."IHSCess_ST", 0) ELSE IFNULL(IHSCess_STD."IHSCess_STFC", 0) END) AS "HSCess ST ItemL Fre", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ISEDD.ISED, 0) ELSE IFNULL(ISEDD.ISEDFC, 0) END) AS "SED ItemL Fre", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ICess_STDD."ICess_ST", 0) ELSE IFNULL(ICess_STDD."ICess_STFC", 0) END) AS "ICess ST ItemL Fre", 
IFNULL(ItmVATD."ItmVAT", 0) AS "VAT ItemL Fre", IFNULL(ItmCSTDD."ItmCST", 0) AS "CST ItemL Fre", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ISTaxDoc."ISTax", 0) ELSE IFNULL(ISTaxDoc."ISTaxFC", 0) END) AS "Service Tax DocL", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(IExDutyDoc."IExDuty", 0) ELSE IFNULL(IExDutyDoc."IExDutyFC", 0) END) AS "Excise Duty DocL", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ItmAEDDoc."ItmAED", 0) ELSE IFNULL(ItmAEDDoc."ItmAEDFC", 0) END) AS "AED DocL", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ICeHDoc."ICeH", 0) ELSE IFNULL(ICeHDoc."ICeHFC", 0) END) + 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ICeH1Doc."ICeH1", 0) ELSE IFNULL(ICeH1Doc."ICeH1FC", 0) END) AS "Cess HeCess DocL", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(IEXDDoc.IEXD, 0) ELSE IFNULL(IEXDDoc.IEXDFC, 0) END) AS "EXD DocL", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(IKKCessDoc."IKKCess", 0) ELSE IFNULL(IKKCessDoc."IKKCessFC", 0) END) AS "KKCess DocL", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ISBCessDoc."ISBCess", 0) ELSE IFNULL(ISBCessDoc."ISBCessFC", 0) END) AS "SBCess DocL", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(IHSCess_STDoc."IHSCess_ST", 0) ELSE IFNULL(IHSCess_STDoc."IHSCess_STFC", 0) END) AS "HSCess ST DocL", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ISEDDoc.ISED, 0) ELSE IFNULL(ISEDDoc.ISEDFC, 0) END) AS "SED DocL", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ICess_STDoc."ICess_ST", 0) ELSE IFNULL(ICess_STDoc."ICess_STFC", 0) END) AS "ICess ST DocL", 
IFNULL(ItmVATDoc."ItmVAT", 0) AS "VAT DocL", IFNULL(ItmCSTDoc."ItmCST", 0) AS "CST DocL", IFNULL(DocLevFreight."DocLevFreight", 0) AS "Total Fright DocL", 
Oi."DiscPrcnt" AS "Discount Percentage", 
(CASE WHEN OI."DocCur" = 'INR' THEN IFNULL(OI."DiscSum", 0) ELSE IFNULL(OI."DiscSumSy", 0) END) AS "Discount Amount", 
oi."RoundDif" AS "Round Off", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(Oi."DocTotal", 0) ELSE IFNULL(Oi."DocTotalSy", 0) END) AS "Doc Total", 
Oi."Comments" AS "Remarks", OI."DocCur" AS "Currency", oi."DocTotalFC" AS "DocTotal FC" 

FROM OPCH oi 
INNER JOIN PCH1 i1 ON OI."DocEntry" = I1."DocEntry" 
LEFT OUTER JOIN OSTC O ON O."Code" = I1."TaxCode" 
LEFT OUTER JOIN NNM1 N1 ON N1."Series" = OI."Series" LEFT OUTER JOIN OPDN OD ON I1."BaseEntry" = OD."DocEntry" 
LEFT OUTER JOIN NNM1 N2 ON N2."Series" = OD."Series" 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ISTax", 
				SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ISTaxFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				WHERE OSTT."AbsId" = 5 AND PCH4."GroupNum" = -1 AND PCH4."RelateType" = 1 AND PCH4."ExpnsCode" = -1 
				GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ISTax ON I1."DocEntry" = ISTax."DocEntry" AND 
				ISTax."TaxType" IN (5) AND ISTax."RelateType" = 1 
				
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "IExDuty",
					 SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "IExDutyFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
					 WHERE OSTT."AbsId" = -90 AND PCH4."GroupNum" = -1 AND PCH4."RelateType" = 1 AND PCH4."ExpnsCode" = -1 
					 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType") AS IExDuty ON I1."DocEntry" = IExDuty."DocEntry" 
					 AND IExDuty."TaxType" IN (-90) AND IExDuty."RelateType" = 1 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "IEXD", 
						SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "IEXDFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
						WHERE OSTT."AbsId" = 10 AND PCH4."GroupNum" = -1 AND PCH4."RelateType" = 1 AND PCH4."ExpnsCode" = -1 
						GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS IEXD ON I1."DocEntry" = IEXD."DocEntry" AND 
						IEXD."TaxType" IN (10) AND IEXD."RelateType" = 1 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", MAX(PCH4."TaxRate") AS "TaxRate", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "IKKCess", 
					SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "IKKCessFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
					WHERE OSTT."AbsId" = 8 AND PCH4."GroupNum" = -1 AND PCH4."RelateType" = 1 AND PCH4."ExpnsCode" = -1 
					GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS IKKCess ON I1."DocEntry" = IKKCess."DocEntry" 
					AND IKKCess."TaxType" IN (8) AND IkkCess."RelateType" = 1 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ISBCess", 
				SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ISBCessFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				WHERE OSTT."AbsId" = 9 AND PCH4."GroupNum" = -1 AND PCH4."RelateType" = 1 AND PCH4."ExpnsCode" = -1 
				GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ISBCess ON I1."DocEntry" = ISBCess."DocEntry" 
				AND ISBCess."TaxType" IN (9) AND IsbCess."RelateType" = 1 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "IHSCess_ST", 
					SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "IHSCess_STFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
					WHERE OSTT."AbsId" = -10 AND PCH4."GroupNum" = -1 AND PCH4."RelateType" = 1 AND PCH4."ExpnsCode" = -1 
					GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS IHSCess_ST ON I1."DocEntry" = IHSCess_ST."DocEntry" 
					AND IHSCess_ST."TaxType" IN (-10) AND IHSCess_ST."RelateType" = 1 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ISED", 
				 SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ISEDFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				 WHERE OSTT."AbsId" = -70 AND PCH4."GroupNum" = -1 AND PCH4."RelateType" = 1 AND PCH4."ExpnsCode" = -1 
				 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ISED ON I1."DocEntry" = ISED."DocEntry" AND ISED."TaxType" IN (-70)
				  AND ISED."RelateType" = 1 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ICess_ST", 
				SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ICess_STFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				WHERE OSTT."AbsId" = 6 AND PCH4."GroupNum" = -1 AND PCH4."RelateType" = 1 AND PCH4."ExpnsCode" = -1 
				GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ICess_ST ON I1."DocEntry" = ICess_ST."DocEntry" 
				AND ICess_ST."TaxType" IN (6) AND Icess_ST."RelateType" = 1 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ItmAED", 
				 SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ItmAEDFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				 WHERE OSTT."AbsId" = -80 AND PCH4."GroupNum" = -1 AND PCH4."RelateType" = 1 AND PCH4."GroupNum" = -1 AND PCH4."RelateType" = 1 AND PCH4."ExpnsCode" = -1 
				 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ItmAED ON I1."DocEntry" = ItmAED."DocEntry" 
				 AND ItmAED."TaxType" IN (-80) AND ItmAED."RelateType" = 1 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ICeH", 
				 SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ICeHFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				 WHERE (OSTT."AbsId" = -60) AND PCH4."GroupNum" = -1 AND PCH4."RelateType" = 1 AND PCH4."ExpnsCode" = -1 
				 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ICeH ON I1."DocEntry" = ICeH."DocEntry" AND ICeH."TaxType" IN (-60) 
				 AND ICeH."RelateType" = 1 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ICeH1", 
				SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ICeH1FC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				WHERE (OSTT."AbsId" = -55) AND PCH4."GroupNum" = -1 AND PCH4."RelateType" = 1 AND PCH4."ExpnsCode" = -1 
				GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ICeH1 ON I1."DocEntry" = ICeH1."DocEntry" AND ICeH1."TaxType" IN (-55) 
				AND ICeH1."RelateType" = 1 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."RelateType", SUM(PCH4."TaxSum") AS "ITaxTot" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				WHERE PCH4."RelateType" = 1 AND PCH4."ExpnsCode" = -1 
				GROUP BY PCH4."DocEntry", PCH4."RelateType") AS ITaxTot ON I1."DocEntry" = ITaxTot."DocEntry" AND ITaxTot."RelateType" = 1 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ItmVAT", 
				SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ItmVATFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				WHERE OSTT."AbsId" = 1 AND PCH4."GroupNum" = -1 AND PCH4."RelateType" = 1 AND PCH4."ExpnsCode" = -1 
				GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ItmVAT ON I1."DocEntry" = ItmVAT."DocEntry" AND ItmVAT."TaxType" IN (1) 
				AND ItmVAT."RelateType" = 1 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ItmCST", SUM(IFNULL((PCH4."TaxSumSys"), 0)) 
				AS "ItmCSTFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				WHERE OSTT."AbsId" = 4 AND PCH4."GroupNum" = -1 AND PCH4."RelateType" = 1 AND PCH4."ExpnsCode" = -1 
				GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ItmCST ON I1."DocEntry" = ItmCST."DocEntry" AND ItmCST."TaxType" IN (4) 
				AND ItmCST."RelateType" = 1 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ItmVATCST", 
				 SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ItmVATCSTFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				 WHERE OSTT."AbsId" IN (4,1) AND PCH4."GroupNum" = -1 AND PCH4."RelateType" = 1 AND PCH4."ExpnsCode" = -1 
				 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ItmVATCST ON I1."DocEntry" = ItmVATCST."DocEntry" 
				 AND ItmVATCST."TaxType" IN (4,1) AND ItmVATCST."RelateType" = 1 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ISTax", 
				 SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ISTaxFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				 WHERE OSTT."AbsId" = 5 AND PCH4."RelateType" = 3 
				 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ISTaxDoc ON I1."DocEntry" = ISTaxDoc."DocEntry" 
				 AND ISTaxDoc."TaxType" IN (5) AND ISTaxDoc."RelateType" = 3 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "IExDuty", 
				  SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "IExDutyFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				  WHERE OSTT."AbsId" = -90 AND PCH4."RelateType" = 3 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType") AS IExDutyDoc 
				  ON I1."DocEntry" = IExDutyDoc."DocEntry" AND IExDutyDoc."TaxType" IN (-90) AND IExDutyDoc."RelateType" = 3 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "IEXD", 
				SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "IEXDFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				WHERE OSTT."AbsId" = 10 AND PCH4."RelateType" = 3 
				GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS IEXDDoc ON I1."DocEntry" = IEXDDoc."DocEntry" 
				AND IEXDDoc."TaxType" IN (10) AND IEXDDoc."RelateType" = 3 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", MAX(PCH4."TaxRate") AS "TaxRate", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "IKKCess", 
				SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "IKKCessFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				WHERE OSTT."AbsId" = 8 AND PCH4."RelateType" = 3 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") 
				AS IKKCessDoc ON I1."DocEntry" = IKKCessDoc."DocEntry" AND IKKCessDoc."TaxType" IN (8) AND IkkCessDoc."RelateType" = 3 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ISBCess", 
				SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ISBCessFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				WHERE OSTT."AbsId" = 9 AND PCH4."RelateType" = 3 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum")
				 AS ISBCessDoc ON I1."DocEntry" = ISBCessDoc."DocEntry" AND ISBCessDoc."TaxType" IN (9) AND IsbCessDoc."RelateType" = 3 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "IHSCess_ST", 
			    SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "IHSCess_STFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
			    WHERE OSTT."AbsId" = -10 AND PCH4."RelateType" = 3 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") 
			    AS IHSCess_STDoc ON I1."DocEntry" = IHSCess_STDoc."DocEntry" AND IHSCess_STDoc."TaxType" IN (-10) AND IHSCess_STDoc."RelateType" = 3 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ISED", 
				SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ISEDFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				WHERE OSTT."AbsId" = -70 AND PCH4."RelateType" = 3 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ISEDDoc
				 ON I1."DocEntry" = ISEDDoc."DocEntry" AND ISEDDoc."TaxType" IN (-70) AND ISEDDoc."RelateType" = 3 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ICess_ST", 
				SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ICess_STFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				WHERE OSTT."AbsId" = 6 AND PCH4."RelateType" = 3 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ICess_STDoc 
				ON I1."DocEntry" = ICess_STDoc."DocEntry" AND ICess_STDoc."TaxType" IN (6) AND ICess_STDoc."RelateType" = 3 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ItmAED", 
				 SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ItmAEDFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				 WHERE OSTT."AbsId" = -80 AND PCH4."RelateType" = 3 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ItmAEDDoc 
				 ON I1."DocEntry" = ItmAEDDoc."DocEntry" AND ItmAEDDoc."TaxType" IN (-80) AND ItmAEDDoc."RelateType" = 3 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ICeH", 
				 SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ICeHFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				 WHERE (OSTT."AbsId" = -60) AND PCH4."RelateType" = 3 
				 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ICeHDoc ON I1."DocEntry" = ICeHDoc."DocEntry" AND 
				 ICeHDoc."TaxType" IN (-60) AND ICeHDoc."RelateType" = 3 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ICeH1", 
				 SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ICeH1FC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				 WHERE (OSTT."AbsId" = -55) AND PCH4."RelateType" = 3 
				 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ICeH1Doc ON 
				 I1."DocEntry" = ICeH1Doc."DocEntry" AND ICeH1Doc."TaxType" IN (-55) AND ICeH1Doc."RelateType" = 3 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."RelateType", SUM(PCH4."TaxSum") AS "ITaxTot" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				 WHERE PCH4."RelateType" = 3 GROUP BY PCH4."DocEntry", PCH4."RelateType") AS ITaxTotDoc ON I1."DocEntry" = ITaxTotDoc."DocEntry" 
				 AND ITaxTotDoc."RelateType" = 3 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ItmVAT", 
				 SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ItmVATFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				 WHERE OSTT."AbsId" = 1 AND PCH4."RelateType" = 3 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ItmVATDoc 
				 ON I1."DocEntry" = ItmVATDoc."DocEntry" AND ItmVATDoc."TaxType" IN (1) AND ItmVATDoc."RelateType" = 3 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ItmCST", 
		SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ItmCSTFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
		WHERE OSTT."AbsId" = 4 AND PCH4."RelateType" = 3 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") 
		AS ItmCSTDoc ON I1."DocEntry" = ItmCSTDoc."DocEntry" AND ItmCSTDoc."TaxType" IN (4) AND ItmCSTDoc."RelateType" = 3 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ItmVATCST", 
				SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ItmVATCSTFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				WHERE OSTT."AbsId" IN (4,1) AND PCH4."RelateType" = 3 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") 
				AS ItmVATCSTDoc ON I1."DocEntry" = ItmVATCSTDoc."DocEntry" AND ItmVATCSTDoc."TaxType" IN (4,1) AND ItmVATCSTDoc."RelateType" = 3 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ISTax", 
				 SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ISTaxFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				 WHERE OSTT."AbsId" = 5 AND PCH4."GroupNum" <> -1 AND PCH4."RelateType" <> 1 AND PCH4."ExpnsCode" <> -1 
				 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ISTaxD ON I1."DocEntry" = ISTaxD."DocEntry" 
				 AND ISTaxD."TaxType" IN (5) AND ISTaxD."RelateType" <> 1 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "IExDuty", 
				 SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "IExDutyFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				 WHERE OSTT."AbsId" = -90 AND PCH4."GroupNum" = -1 AND PCH4."RelateType" = 1 AND PCH4."ExpnsCode" <> -1 
				 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType") AS IExDutyD ON I1."DocEntry" = IExDutyD."DocEntry" AND IExDutyD."TaxType" IN (-90) 
				 AND IExDutyD."RelateType" <> 1 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "IEXD", 
				 SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "IEXDFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				 WHERE OSTT."AbsId" = 10 AND PCH4."GroupNum" <> -1 AND PCH4."RelateType" <> 1 AND PCH4."ExpnsCode" <> -1 
				 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType") AS IEXDD ON I1."DocEntry" = IEXDD."DocEntry" AND IEXDD."TaxType" IN (10) AND 
				 IEXDD."RelateType" <> 1 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", MAX(PCH4."TaxRate") AS "TaxRate", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "IKKCess", 
				SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "IKKCessFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				WHERE OSTT."AbsId" = 8 AND PCH4."GroupNum" <> -1 AND PCH4."RelateType" <> 1 AND PCH4."GroupNum" <> -1 AND PCH4."RelateType" <> 1 AND 
				PCH4."ExpnsCode" <> -1 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS IKKCessD ON I1."DocEntry" = IKKCessD."DocEntry" 
				AND IKKCessD."TaxType" IN (8) AND IKKCessD."RelateType" <> 1 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ISBCess", 
				SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ISBCessFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				WHERE OSTT."AbsId" = 9 AND PCH4."GroupNum" <> -1 AND PCH4."RelateType" <> 1 AND PCH4."ExpnsCode" <> -1 
				GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ISBCessD ON I1."DocEntry" = ISBCessD."DocEntry" 
				AND ISBCessD."TaxType" IN (9) AND ISBCessD."RelateType" <> 1 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "IHSCess_ST", 
				 SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "IHSCess_STFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				 WHERE OSTT."AbsId" = -10 AND PCH4."GroupNum" <> -1 AND PCH4."RelateType" <> 1 AND PCH4."ExpnsCode" <> -1 
				 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS IHSCess_STD ON I1."DocEntry" = IHSCess_STD."DocEntry" 
				 AND IHSCess_STD."TaxType" IN (-10) 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ISED", 
			     SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ISEDFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
			     WHERE OSTT."AbsId" = -70 AND PCH4."GroupNum" <> -1 AND PCH4."RelateType" <> 1 AND PCH4."ExpnsCode" <> -1 
			     GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ISEDD ON I1."DocEntry" = ISEDD."DocEntry" 
			     AND ISEDD."TaxType" IN (-70) 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ICess_ST", 
				SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ICess_STFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				WHERE OSTT."AbsId" = 6 AND PCH4."GroupNum" <> -1 AND PCH4."RelateType" <> 1 AND PCH4."ExpnsCode" <> -1 
				GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ICess_STDD ON I1."DocEntry" = ICess_STDD."DocEntry" 
				AND ICess_STDD."TaxType" IN (6) 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ItmAED", 
				 SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ItmAEDFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				 WHERE OSTT."AbsId" = -80 AND PCH4."GroupNum" <> -1 AND PCH4."RelateType" <> 1 AND PCH4."ExpnsCode" <> -1 
				 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ItmAEDD ON I1."DocEntry" = ItmAEDD."DocEntry" 
				 AND ItmAEDD."TaxType" IN (-80) 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ICeH", 
				 SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ICeHFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				 WHERE (OSTT."AbsId" = -60) AND PCH4."GroupNum" <> -1 AND PCH4."RelateType" <> 1 AND PCH4."ExpnsCode" <> -1 
				 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ICeHD ON I1."DocEntry" = ICeHD."DocEntry" AND 
				 ICeHD."TaxType" IN (-60) 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ICeH1", 	
			     SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ICeH1FC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
			     WHERE (OSTT."AbsId" = -55) AND PCH4."GroupNum" <> -1 AND PCH4."RelateType" <> 1 AND PCH4."ExpnsCode" <> -1 
			     GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ICeH1D ON I1."DocEntry" = ICeH1D."DocEntry" 
			     AND ICeH1D."TaxType" IN (-55) 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."RelateType", SUM(PCH4."TaxSum") AS "ITaxTot" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				 WHERE PCH4."ExpnsCode" <> -1 GROUP BY PCH4."DocEntry", PCH4."RelateType") AS ITaxTotD ON I1."DocEntry" = ITaxTotD."DocEntry" 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ItmVAT", 
				 SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ItmVATFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				 WHERE OSTT."AbsId" = 1 AND PCH4."GroupNum" <> -1 AND PCH4."RelateType" <> 1 AND PCH4."ExpnsCode" <> -1 
				 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ItmVATD ON I1."DocEntry" = ItmVATD."DocEntry" AND 
				 ItmVATD."TaxType" IN (1) 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ItmCST", 
				 SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ItmCSTFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				 WHERE OSTT."AbsId" = 4 AND PCH4."GroupNum" <> -1 AND PCH4."RelateType" <> 1 AND PCH4."ExpnsCode" <> -1 
				 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ItmCSTDD ON I1."DocEntry" = ItmCSTDD."DocEntry" AND 
				 ItmCSTDD."TaxType" IN (4) 
LEFT OUTER JOIN (SELECT PCH4."DocEntry", PCH4."staType" AS "TaxType", PCH4."RelateType", SUM(IFNULL((PCH4."TaxSum"), 0)) AS "ItmVATCST", 
				 SUM(IFNULL((PCH4."TaxSumSys"), 0)) AS "ItmVATCSTFC" FROM PCH4 INNER JOIN OSTT ON PCH4."staType" = OSTT."AbsId" 
				 WHERE OSTT."AbsId" IN (4,1) AND PCH4."GroupNum" <> -1 AND PCH4."RelateType" <> 1 AND PCH4."ExpnsCode" <> -1 
				 GROUP BY PCH4."DocEntry", PCH4."staType", PCH4."RelateType", PCH4."GroupNum") AS ItmVATCSTDD ON I1."DocEntry" = ItmVATCSTDD."DocEntry" AND 
				 ItmVATCSTDD."TaxType" IN (4,1) 
LEFT OUTER JOIN (SELECT PCH2."DocEntry", SUM(CASE WHEN PCH2."FixCurr" = 'INR' THEN IFNULL((PCH2."LineTotal"), 0) ELSE IFNULL((PCH2."TotalSumSy"), 0) END) AS "LLFreTot" 
				FROM PCH2 WHERE ifnull(cast(PCH2."ExpnsCode" as varchar),'')<> '' 
GROUP BY PCH2."DocEntry") AS LLFreTot ON I1."DocEntry" = LLFreTot."DocEntry" 
LEFT OUTER JOIN (SELECT PCH3."DocEntry", SUM(CASE WHEN PCH3."FixCurr" = 'INR' THEN IFNULL((PCH3."LineTotal"), 0) ELSE IFNULL((PCH3."TotalSumSy"), 0) END) AS 
					"DocLevFreight" FROM PCH3 WHERE ifnull(cast(PCH3."ExpnsCode" as varchar),'') <> '' GROUP BY PCH3."DocEntry") AS DocLevFreight ON I1."DocEntry" = DocLevFreight."DocEntry" 
LEFT OUTER JOIN (SELECT "CardCode", "Address", "TaxId0", "TaxId1", "TaxId2", "TaxId3" FROM CRD7 crd7 WHERE "Address" <> '' AND ("AddrType" = 'S')) AS crd7 
				ON OI."CardCode" = crd7."CardCode" AND OI."ShipToCode" = crd7."Address" WHERE OI.CANCELED = 'N'

--------------------------------------------------------------------------------------------------------------------------
union all

SELECT OI."DocEntry" AS "DocEntry", IFNULL(N1."SeriesName", n'') || '/' || CAST(OI."DocNum" AS char(20)) AS "Invoice No", 
OI."DocDate"  AS "Invoice Date",  
(SELECT STRING_AGG(t0."DocNum", ',') AS "SO" FROM (SELECT DISTINCT OPDN."DocNum" FROM OPDN INNER JOIN RPC1 ON RPC1."BaseEntry" = OPDN."DocEntry" 
AND RPC1."DocEntry" = oi."DocEntry") AS "T0") AS "GRN No", (SELECT STRING_AGG(t0."DocDate", ',') AS "SO" FROM 
(SELECT DISTINCT TO_NVARCHAR(TO_DATE(OPDN."DocDate"), 'YYYY-MM-DD') AS "DocDate" FROM OPDN INNER JOIN RPC1 ON RPC1."BaseEntry" = OPDN."DocEntry" 
AND RPC1."DocEntry" = oi."DocEntry") AS "T0") AS "GRN Date", '' AS "Vendor Ref Date", OI."CardCode" AS "Vendor Code", OI."CardName" AS "Vendor Name", 
(SELECT SUM(RPC1."Quantity" * (CASE WHEN RPC1."Currency" = 'INR' AND ORPC."DocCur" = 'INR' THEN (RPC1."PriceBefDi") WHEN RPC1."Currency" <> 'INR' 
AND ORPC."DocCur" <> 'INR' THEN (RPC1."Rate" * RPC1."PriceBefDi") WHEN RPC1."Currency" <> 'INR' AND ORPC."DocCur" = 'INR' THEN (RPC1."Rate" * RPC1."PriceBefDi") 
WHEN RPC1."Currency" = 'INR' AND ORPC."DocCur" <> 'INR' THEN (ORPC."DocRate" * RPC1."PriceBefDi") END)) FROM RPC1 INNER JOIN ORPC ON RPC1."DocEntry" = ORPC."DocEntry" 
WHERE RPC1."DocEntry" = oi."DocEntry" GROUP BY RPC1."DocEntry", ORPC."DocCur") * (-1) AS "Value Before Disc", (SELECT SUM(RPC1."Quantity" * 
(CASE WHEN RPC1."Currency" = 'INR' AND ORPC."DocCur" = 'INR' THEN (RPC1."Price") WHEN RPC1."Currency" <> 'INR' AND ORPC."DocCur" <> 'INR' THEN 
(RPC1."Rate" * RPC1."Price") WHEN RPC1."Currency" <> 'INR' AND ORPC."DocCur" = 'INR' THEN (RPC1."Rate" * RPC1."Price") WHEN RPC1."Currency" = 'INR' 
AND ORPC."DocCur" <> 'INR' THEN (ORPC."DocRate" * RPC1."Price") END)) FROM RPC1 INNER JOIN ORPC ON RPC1."DocEntry" = ORPC."DocEntry" 
WHERE RPC1."DocEntry" = oi."DocEntry" GROUP BY RPC1."DocEntry", ORPC."DocCur") * (-1) AS "Value After Disc", 
(SELECT (CASE WHEN ORPC."DocCur" = 'INR' THEN SUM(IFNULL(RPC1."LineTotal", 0)) ELSE SUM(IFNULL(RPC1."TotalSumSy", 0)) END) FROM RPC1 
INNER JOIN ORPC ON RPC1."DocEntry" = ORPC."DocEntry" WHERE RPC1."DocEntry" = oi."DocEntry" GROUP BY RPC1."DocEntry", ORPC."DocCur") AS "Taxable Amt before Ex Ser Tax", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ISTax."ISTax", 0) ELSE IFNULL(ISTax."ISTaxFC", 0) END) * (-1) AS "Service Tax ItemL", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(IExDuty."IExDuty", 0) ELSE IFNULL(IExDuty."IExDutyFC", 0) END) * (-1) AS "Excise Duty ItemL", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ItmAED."ItmAED", 0) ELSE IFNULL(ItmAED."ItmAEDFC", 0) END) * (-1) AS "AED ItemL", 
(CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ICeH."ICeH", 0) ELSE IFNULL(ICeH."ICeHFC", 0) END) + (CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ICeH1."ICeH1", 0) 
ELSE IFNULL(ICeH1."ICeH1FC", 0) END) * (-1) AS "Cess HeCess ItemL", (CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(IEXD.IEXD, 0) ELSE IFNULL(IEXD.IEXDFC, 0) END)
 * (-1) AS "EXD ItemL", (CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(IKKCess."IKKCess", 0) ELSE IFNULL(IKKCess."IKKCessFC", 0) END) * (-1) AS "KKCess ItemL", 
 (CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ISBCess."ISBCess", 0) ELSE IFNULL(ISBCess."ISBCessFC", 0) END) * (-1) AS "SBCess ItemL", 
 (CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(IHSCess_ST."IHSCess_ST", 0) ELSE IFNULL(IHSCess_ST."IHSCess_STFC", 0) END) * (-1) AS "HSCess ST ItemL", 
 (CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ISED.ISED, 0) ELSE IFNULL(ISED.ISEDFC, 0) END) * (-1) AS "SED ItemL", 
 (CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ICess_ST."ICess_ST", 0) ELSE IFNULL(ICess_ST."ICess_STFC", 0) END) * (-1) AS "ICess ST ItemL", 
 IFNULL(ItmVAT."ItmVAT", 0) * (-1) AS "VAT ItemL", IFNULL(ItmCST."ItmCST", 0) * (-1) AS "CST ItemL", IFNULL(LLFreTot."LLFreTot", 0) * (-1) AS "Total Fright ItemL", 
 (CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ISTaxD."ISTax", 0) ELSE IFNULL(ISTaxD."ISTaxFC", 0) END) * (-1) AS "Service Tax ItemL Fre", 
 (CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(IExDutyD."IExDuty", 0) ELSE IFNULL(IExDutyD."IExDutyFC", 0) END) * (-1) AS "Excise Duty ItemL Fre", 
 (CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ItmAEDD."ItmAED", 0) ELSE IFNULL(ItmAEDD."ItmAEDFC", 0) END) * (-1) AS "AED ItemL Fre", 
 (CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ICeHD."ICeH", 0) ELSE IFNULL(ICeHD."ICeHFC", 0) END) + 
 (CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ICeH1D."ICeH1", 0) ELSE IFNULL(ICeH1D."ICeH1FC", 0) END) * (-1) AS "Cess HeCess ItemL Fre", 
 (CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(IEXDD.IEXD, 0) ELSE IFNULL(IEXDD.IEXDFC, 0) END) * (-1) AS "EXD ItemL Fre", (CASE WHEN oi."DocCur" = 'INR' 
 THEN IFNULL(IKKCessD."IKKCess", 0) ELSE IFNULL(IKKCessD."IKKCessFC", 0) END) * (-1) AS "KKCess ItemL Fre", (CASE WHEN oi."DocCur" = 'INR' 
 THEN IFNULL(ISBCessD."ISBCess", 0) ELSE IFNULL(ISBCessD."ISBCessFC", 0) END) * (-1) AS "SBCess ItemL Fre", (CASE WHEN oi."DocCur" = 'INR' THEN 
 IFNULL(IHSCess_STD."IHSCess_ST", 0) ELSE IFNULL(IHSCess_STD."IHSCess_STFC", 0) END) * (-1) AS "HSCess ST ItemL Fre", (CASE WHEN oi."DocCur" = 'INR' 
 THEN IFNULL(ISEDD.ISED, 0) ELSE IFNULL(ISEDD.ISEDFC, 0) END) * (-1) AS "SED ItemL Fre", (CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ICess_STDD."ICess_ST", 0) 
 ELSE IFNULL(ICess_STDD."ICess_STFC", 0) END) * (-1) AS "ICess ST ItemL Fre", IFNULL(ItmVATD."ItmVAT", 0) * (-1) AS "VAT ItemL Fre", 
 IFNULL(ItmCSTDD."ItmCST", 0) * (-1) AS "CST ItemL Fre", (CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ISTaxDoc."ISTax", 0) ELSE 
 IFNULL(ISTaxDoc."ISTaxFC", 0) END) * (-1) AS "Service Tax DocL", (CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(IExDutyDoc."IExDuty", 0) ELSE 
 IFNULL(IExDutyDoc."IExDutyFC", 0) END) * (-1) AS "Excise Duty DocL", (CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ItmAEDDoc."ItmAED", 0) ELSE 
 IFNULL(ItmAEDDoc."ItmAEDFC", 0) END) * (-1) AS "AED DocL", (CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ICeHDoc."ICeH", 0) ELSE IFNULL(ICeHDoc."ICeHFC", 0) END) + 
 (CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ICeH1Doc."ICeH1", 0) ELSE IFNULL(ICeH1Doc."ICeH1FC", 0) END) * (-1) AS "Cess HeCess DocL", 
 (CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(IEXDDoc.IEXD, 0) ELSE IFNULL(IEXDDoc.IEXDFC, 0) END) AS "EXD DocL", (CASE WHEN oi."DocCur" = 'INR' THEN 
 IFNULL(IKKCessDoc."IKKCess", 0) ELSE IFNULL(IKKCessDoc."IKKCessFC", 0) END) * (-1) AS "KKCess DocL", (CASE WHEN oi."DocCur" = 'INR' THEN 
 IFNULL(ISBCessDoc."ISBCess", 0) ELSE IFNULL(ISBCessDoc."ISBCessFC", 0) END) * (-1) AS "SBCess DocL", (CASE WHEN oi."DocCur" = 'INR' THEN 
 IFNULL(IHSCess_STDoc."IHSCess_ST", 0) ELSE IFNULL(IHSCess_STDoc."IHSCess_STFC", 0) END) * (-1) AS "HSCess ST DocL", 
 (CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ISEDDoc.ISED, 0) ELSE IFNULL(ISEDDoc.ISEDFC, 0) END) * (-1) AS "SED DocL", 
 (CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(ICess_STDoc."ICess_ST", 0) ELSE IFNULL(ICess_STDoc."ICess_STFC", 0) END) * (-1) AS "ICess ST DocL", 
 IFNULL(ItmVATDoc."ItmVAT", 0) * (-1) AS "VAT DocL", IFNULL(ItmCSTDoc."ItmCST", 0) * (-1) AS "CST DocL", 
 IFNULL(DocLevFreight."DocLevFreight", 0) * (-1) AS "Total Fright DocL", Oi."DiscPrcnt" AS "Discount Percentage", 
 (CASE WHEN OI."DocCur" = 'INR' THEN IFNULL(OI."DiscSum", 0) ELSE IFNULL(OI."DiscSumSy", 0) END) * (-1) AS "Discount Amount", 
 oi."RoundDif" AS "Round Off", (CASE WHEN oi."DocCur" = 'INR' THEN IFNULL(Oi."DocTotal", 0) ELSE IFNULL(Oi."DocTotalSy", 0) END) * (-1) AS "Doc Total", 
 Oi."Comments" AS "Remarks", OI."DocCur" AS "Currency", oi."DocTotalFC" AS "DocTotal FC" FROM "ORPC" oi INNER JOIN "RPC1" i1 ON OI."DocEntry" = I1."DocEntry" 
 LEFT OUTER JOIN OSTC O ON O."Code" = I1."TaxCode" LEFT OUTER JOIN NNM1 N1 ON N1."Series" = Oi."Series" LEFT OUTER JOIN OPDN OD ON I1."BaseEntry" = OD."DocEntry" LEFT OUTER JOIN NNM1 N2 ON N2."Series" = od."Series" LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ISTax", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ISTaxFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = 5 AND RPC4."GroupNum" = -1 AND RPC4."RelateType" = 1 AND RPC4."ExpnsCode" = -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ISTax ON I1."DocEntry" = ISTax."DocEntry" AND ISTax."TaxType" IN (5) AND ISTax."RelateType" = 1 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "IExDuty", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "IExDutyFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = -90 AND RPC4."GroupNum" = -1 AND RPC4."RelateType" = 1 AND RPC4."ExpnsCode" = -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType") AS IExDuty ON I1."DocEntry" = IExDuty."DocEntry" AND IExDuty."TaxType" IN (-90) AND IExDuty."RelateType" = 1 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "IEXD", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "IEXDFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = 10 AND RPC4."GroupNum" = -1 AND RPC4."RelateType" = 1 AND RPC4."ExpnsCode" = -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS IEXD ON I1."DocEntry" = IEXD."DocEntry" AND IEXD."TaxType" IN (10) AND IEXD."RelateType" = 1 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", MAX(RPC4."TaxRate") AS "TaxRate", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "IKKCess", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "IKKCessFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = 8 AND RPC4."GroupNum" = -1 AND RPC4."RelateType" = 1 AND RPC4."ExpnsCode" = -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS IKKCess ON I1."DocEntry" = IKKCess."DocEntry" AND IKKCess."TaxType" IN (8) AND IkkCess."RelateType" = 1 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ISBCess", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ISBCessFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = 9 AND RPC4."GroupNum" = -1 AND RPC4."RelateType" = 1 AND RPC4."ExpnsCode" = -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ISBCess ON I1."DocEntry" = ISBCess."DocEntry" AND ISBCess."TaxType" IN (9) AND IsbCess."RelateType" = 1 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "IHSCess_ST", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "IHSCess_STFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = -10 AND RPC4."GroupNum" = -1 AND RPC4."RelateType" = 1 AND RPC4."ExpnsCode" = -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS IHSCess_ST ON I1."DocEntry" = IHSCess_ST."DocEntry" AND IHSCess_ST."TaxType" IN (-10) AND IHSCess_ST."RelateType" = 1 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ISED", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ISEDFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = -70 AND RPC4."GroupNum" = -1 AND RPC4."RelateType" = 1 AND RPC4."ExpnsCode" = -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ISED ON I1."DocEntry" = ISED."DocEntry" AND ISED."TaxType" IN (-70) AND ISED."RelateType" = 1 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ICess_ST", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ICess_STFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = 6 AND RPC4."GroupNum" = -1 AND RPC4."RelateType" = 1 AND RPC4."ExpnsCode" = -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ICess_ST ON I1."DocEntry" = ICess_ST."DocEntry" AND ICess_ST."TaxType" IN (6) AND Icess_ST."RelateType" = 1 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ItmAED", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ItmAEDFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = -80 AND RPC4."GroupNum" = -1 AND RPC4."RelateType" = 1 AND RPC4."GroupNum" = -1 AND RPC4."RelateType" = 1 AND RPC4."ExpnsCode" = -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ItmAED ON I1."DocEntry" = ItmAED."DocEntry" AND ItmAED."TaxType" IN (-80) AND ItmAED."RelateType" = 1 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ICeH", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ICeHFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE (OSTT."AbsId" = -60) AND RPC4."GroupNum" = -1 AND RPC4."RelateType" = 1 AND RPC4."ExpnsCode" = -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ICeH ON I1."DocEntry" = ICeH."DocEntry" AND ICeH."TaxType" IN (-60) AND ICeH."RelateType" = 1 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ICeH1", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ICeH1FC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE (OSTT."AbsId" = -55) AND RPC4."GroupNum" = -1 AND RPC4."RelateType" = 1 AND RPC4."ExpnsCode" = -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ICeH1 ON I1."DocEntry" = ICeH1."DocEntry" AND ICeH1."TaxType" IN (-55) AND ICeH1."RelateType" = 1 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."RelateType", SUM(RPC4."TaxSum") AS "ITaxTot" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE RPC4."RelateType" = 1 AND RPC4."ExpnsCode" = -1 GROUP BY RPC4."DocEntry", RPC4."RelateType") AS ITaxTot ON I1."DocEntry" = ITaxTot."DocEntry" AND ITaxTot."RelateType" = 1 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ItmVAT", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ItmVATFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = 1 AND RPC4."GroupNum" = -1 AND RPC4."RelateType" = 1 AND RPC4."ExpnsCode" = -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ItmVAT ON I1."DocEntry" = ItmVAT."DocEntry" AND ItmVAT."TaxType" IN (1) AND ItmVAT."RelateType" = 1 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ItmCST", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ItmCSTFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = 4 AND RPC4."GroupNum" = -1 AND RPC4."RelateType" = 1 AND RPC4."ExpnsCode" = -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ItmCST ON I1."DocEntry" = ItmCST."DocEntry" AND ItmCST."TaxType" IN (4) AND ItmCST."RelateType" = 1 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ItmVATCST", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ItmVATCSTFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" IN (4,1) AND RPC4."GroupNum" = -1 AND RPC4."RelateType" = 1 AND RPC4."ExpnsCode" = -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ItmVATCST ON I1."DocEntry" = ItmVATCST."DocEntry" AND ItmVATCST."TaxType" IN (4,1) AND ItmVATCST."RelateType" = 1 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ISTax", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ISTaxFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = 5 AND RPC4."RelateType" = 3 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ISTaxDoc ON I1."DocEntry" = ISTaxDoc."DocEntry" AND ISTaxDoc."TaxType" IN (5) AND ISTaxDoc."RelateType" = 3 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "IExDuty", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "IExDutyFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = -90 AND RPC4."RelateType" = 3 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType") AS IExDutyDoc ON I1."DocEntry" = IExDutyDoc."DocEntry" AND IExDutyDoc."TaxType" IN (-90) AND IExDutyDoc."RelateType" = 3 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "IEXD", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "IEXDFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = 10 AND RPC4."RelateType" = 3 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS IEXDDoc ON I1."DocEntry" = IEXDDoc."DocEntry" AND IEXDDoc."TaxType" IN (10) AND IEXDDoc."RelateType" = 3 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", MAX(RPC4."TaxRate") AS "TaxRate", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "IKKCess", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "IKKCessFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = 8 AND RPC4."RelateType" = 3 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS IKKCessDoc ON I1."DocEntry" = IKKCessDoc."DocEntry" AND IKKCessDoc."TaxType" IN (8) AND IkkCessDoc."RelateType" = 3 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ISBCess", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ISBCessFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = 9 AND RPC4."RelateType" = 3 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ISBCessDoc ON I1."DocEntry" = ISBCessDoc."DocEntry" AND ISBCessDoc."TaxType" IN (9) AND IsbCessDoc."RelateType" = 3 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "IHSCess_ST", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "IHSCess_STFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = -10 AND RPC4."RelateType" = 3 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS IHSCess_STDoc ON I1."DocEntry" = IHSCess_STDoc."DocEntry" AND IHSCess_STDoc."TaxType" IN (-10) AND IHSCess_STDoc."RelateType" = 3 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ISED", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ISEDFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = -70 AND RPC4."RelateType" = 3 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ISEDDoc ON I1."DocEntry" = ISEDDoc."DocEntry" AND ISEDDoc."TaxType" IN (-70) AND ISEDDoc."RelateType" = 3 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ICess_ST", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ICess_STFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = 6 AND RPC4."RelateType" = 3 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ICess_STDoc ON I1."DocEntry" = ICess_STDoc."DocEntry" AND ICess_STDoc."TaxType" IN (6) AND ICess_STDoc."RelateType" = 3 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ItmAED", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ItmAEDFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = -80 AND RPC4."RelateType" = 3 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ItmAEDDoc ON I1."DocEntry" = ItmAEDDoc."DocEntry" AND ItmAEDDoc."TaxType" IN (-80) AND ItmAEDDoc."RelateType" = 3 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ICeH", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ICeHFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE (OSTT."AbsId" = -60) AND RPC4."RelateType" = 3 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ICeHDoc ON I1."DocEntry" = ICeHDoc."DocEntry" AND ICeHDoc."TaxType" IN (-60) AND ICeHDoc."RelateType" = 3 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ICeH1", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ICeH1FC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE (OSTT."AbsId" = -55) AND RPC4."RelateType" = 3 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ICeH1Doc ON I1."DocEntry" = ICeH1Doc."DocEntry" AND ICeH1Doc."TaxType" IN (-55) AND ICeH1Doc."RelateType" = 3 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."RelateType", SUM(RPC4."TaxSum") AS "ITaxTot" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE RPC4."RelateType" = 3 GROUP BY RPC4."DocEntry", RPC4."RelateType") AS ITaxTotDoc ON I1."DocEntry" = ITaxTotDoc."DocEntry" AND ITaxTotDoc."RelateType" = 3 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ItmVAT", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ItmVATFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = 1 AND RPC4."RelateType" = 3 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ItmVATDoc ON I1."DocEntry" = ItmVATDoc."DocEntry" AND ItmVATDoc."TaxType" IN (1) AND ItmVATDoc."RelateType" = 3 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ItmCST", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ItmCSTFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = 4 AND RPC4."RelateType" = 3 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ItmCSTDoc ON I1."DocEntry" = ItmCSTDoc."DocEntry" AND ItmCSTDoc."TaxType" IN (4) AND ItmCSTDoc."RelateType" = 3 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ItmVATCST", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ItmVATCSTFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" IN (4,1) AND RPC4."RelateType" = 3 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ItmVATCSTDoc ON I1."DocEntry" = ItmVATCSTDoc."DocEntry" AND ItmVATCSTDoc."TaxType" IN (4,1) AND ItmVATCSTDoc."RelateType" = 3 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ISTax", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ISTaxFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = 5 AND RPC4."GroupNum" <> -1 AND RPC4."RelateType" <> 1 AND RPC4."ExpnsCode" <> -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ISTaxD ON I1."DocEntry" = ISTaxD."DocEntry" AND ISTaxD."TaxType" IN (5) AND ISTaxD."RelateType" <> 1 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "IExDuty", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "IExDutyFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = -90 AND RPC4."GroupNum" = -1 AND RPC4."RelateType" = 1 AND RPC4."ExpnsCode" <> -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType") AS IExDutyD ON I1."DocEntry" = IExDutyD."DocEntry" AND IExDutyD."TaxType" IN (-90) AND IExDutyD."RelateType" <> 1 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "IEXD", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "IEXDFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = 10 AND RPC4."GroupNum" <> -1 AND RPC4."RelateType" <> 1 AND RPC4."ExpnsCode" <> -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType") AS IEXDD ON I1."DocEntry" = IEXDD."DocEntry" AND IEXDD."TaxType" IN (10) AND IEXDD."RelateType" <> 1 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", MAX(RPC4."TaxRate") AS "TaxRate", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "IKKCess", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "IKKCessFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = 8 AND RPC4."GroupNum" <> -1 AND RPC4."RelateType" <> 1 AND RPC4."GroupNum" <> -1 AND RPC4."RelateType" <> 1 AND RPC4."ExpnsCode" <> -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS IKKCessD ON I1."DocEntry" = IKKCessD."DocEntry" AND IKKCessD."TaxType" IN (8) AND IKKCessD."RelateType" <> 1 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ISBCess", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ISBCessFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = 9 AND RPC4."GroupNum" <> -1 AND RPC4."RelateType" <> 1 AND RPC4."ExpnsCode" <> -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ISBCessD ON I1."DocEntry" = ISBCessD."DocEntry" AND ISBCessD."TaxType" IN (9) AND ISBCessD."RelateType" <> 1 LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "IHSCess_ST", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "IHSCess_STFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = -10 AND RPC4."GroupNum" <> -1 AND RPC4."RelateType" <> 1 AND RPC4."ExpnsCode" <> -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS IHSCess_STD ON I1."DocEntry" = IHSCess_STD."DocEntry" AND IHSCess_STD."TaxType" IN (-10) LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ISED", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ISEDFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = -70 AND RPC4."GroupNum" <> -1 AND RPC4."RelateType" <> 1 AND RPC4."ExpnsCode" <> -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ISEDD ON I1."DocEntry" = ISEDD."DocEntry" AND ISEDD."TaxType" IN (-70) LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ICess_ST", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ICess_STFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = 6 AND RPC4."GroupNum" <> -1 AND RPC4."RelateType" <> 1 AND RPC4."ExpnsCode" <> -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ICess_STDD ON I1."DocEntry" = ICess_STDD."DocEntry" AND ICess_STDD."TaxType" IN (6) LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ItmAED", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ItmAEDFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = -80 AND RPC4."GroupNum" <> -1 AND RPC4."RelateType" <> 1 AND RPC4."ExpnsCode" <> -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ItmAEDD ON I1."DocEntry" = ItmAEDD."DocEntry" AND ItmAEDD."TaxType" IN (-80) LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ICeH", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ICeHFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE (OSTT."AbsId" = -60) AND RPC4."GroupNum" <> -1 AND RPC4."RelateType" <> 1 AND RPC4."ExpnsCode" <> -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ICeHD ON I1."DocEntry" = ICeHD."DocEntry" AND ICeHD."TaxType" IN (-60) LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ICeH1", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ICeH1FC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE (OSTT."AbsId" = -55) AND RPC4."GroupNum" <> -1 AND RPC4."RelateType" <> 1 AND RPC4."ExpnsCode" <> -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ICeH1D ON I1."DocEntry" = ICeH1D."DocEntry" AND ICeH1D."TaxType" IN (-55) LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."RelateType", SUM(RPC4."TaxSum") AS "ITaxTot" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE RPC4."ExpnsCode" <> -1 GROUP BY RPC4."DocEntry", RPC4."RelateType") AS ITaxTotD ON I1."DocEntry" = ITaxTotD."DocEntry" LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ItmVAT", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ItmVATFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = 1 AND RPC4."GroupNum" <> -1 AND RPC4."RelateType" <> 1 AND RPC4."ExpnsCode" <> -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ItmVATD ON I1."DocEntry" = ItmVATD."DocEntry" AND ItmVATD."TaxType" IN (1) LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ItmCST", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ItmCSTFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" = 4 AND RPC4."GroupNum" <> -1 AND RPC4."RelateType" <> 1 AND RPC4."ExpnsCode" <> -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ItmCSTDD ON I1."DocEntry" = ItmCSTDD."DocEntry" AND ItmCSTDD."TaxType" IN (4) LEFT OUTER JOIN (SELECT RPC4."DocEntry", RPC4."staType" AS "TaxType", RPC4."RelateType", SUM(IFNULL((RPC4."TaxSum"), 0)) AS "ItmVATCST", SUM(IFNULL((RPC4."TaxSumSys"), 0)) AS "ItmVATCSTFC" FROM RPC4 INNER JOIN OSTT ON RPC4."staType" = OSTT."AbsId" WHERE OSTT."AbsId" IN (4,1) AND RPC4."GroupNum" <> -1 AND RPC4."RelateType" <> 1 AND RPC4."ExpnsCode" <> -1 GROUP BY RPC4."DocEntry", RPC4."staType", RPC4."RelateType", RPC4."GroupNum") AS ItmVATCSTDD ON I1."DocEntry" = ItmVATCSTDD."DocEntry" AND ItmVATCSTDD."TaxType" IN (4,1) LEFT OUTER JOIN (SELECT RPC2."DocEntry", SUM(CASE WHEN RPC2."FixCurr" = 'INR' THEN IFNULL((RPC2."LineTotal"), 0) ELSE IFNULL((RPC2."TotalSumSy"), 0) END) AS "LLFreTot" FROM RPC2 WHERE ifnull(cast(RPC2."ExpnsCode" as varchar),'') <> '' GROUP BY RPC2."DocEntry") AS LLFreTot ON I1."DocEntry" = LLFreTot."DocEntry" 
LEFT OUTER JOIN (SELECT RPC3."DocEntry", SUM(CASE WHEN RPC3."FixCurr" = 'INR' THEN IFNULL((RPC3."LineTotal"), 0) ELSE IFNULL((RPC3."TotalSumSy"), 0) END) AS "DocLevFreight" FROM RPC3 WHERE ifnull(cast(RPC3."ExpnsCode" as varchar),'') <> '' GROUP BY RPC3."DocEntry") AS DocLevFreight ON I1."DocEntry" = DocLevFreight."DocEntry" LEFT OUTER JOIN (SELECT "CardCode", "Address", "TaxId0", "TaxId1", "TaxId2", "TaxId3" FROM CRD7 crd7 WHERE "Address" <> '' AND ("AddrType" = 'S')) AS crd7 ON OI."CardCode" = crd7."CardCode" AND OI."ShipToCode" = crd7."Address" WHERE OI.CANCELED = 'N'


) as sr
group by sr."Invoice No",sr."GRN No",sr."GRN Date",sr."DocEntry",sr."Invoice Date",sr."Currency",sr."Vendor Code",sr."Vendor Name",sr."Vendor Ref Date",
sr."Value Before Disc",
sr."Taxable Amt before Ex Ser Tax",sr."Value After Disc",
sr."Service Tax ItemL",sr."Excise Duty ItemL",sr."AED ItemL",sr."Cess HeCess ItemL",sr."EXD ItemL",sr."KKCess ItemL",sr."SBCess ItemL",
sr."HSCess ST ItemL",sr."SED ItemL",sr."ICess ST ItemL",sr."VAT ItemL",sr."CST ItemL",
sr."Total Fright ItemL",
sr."Total Fright DocL",
sr."Service Tax ItemL Fre",sr."Excise Duty ItemL Fre",sr."AED ItemL Fre",sr."Cess HeCess ItemL Fre",sr."EXD ItemL Fre",sr."KKCess ItemL Fre",sr."SBCess ItemL Fre",
sr."HSCess ST ItemL Fre",sr."SED ItemL Fre",sr."ICess ST ItemL Fre",sr."VAT ItemL Fre",sr."CST ItemL Fre",

sr."Service Tax DocL",sr."Excise Duty DocL",sr."AED DocL",sr."Cess HeCess DocL",sr."EXD DocL",sr."KKCess DocL",sr."SBCess DocL",
sr."HSCess ST DocL",sr."SED DocL",sr."ICess ST DocL",sr."VAT DocL",sr."CST DocL",
sr."Round Off",
sr."Discount Percentage",
sr."Discount Amount",
sr."Doc Total",
sr."Remarks",
sr."DocTotal FC"
--order by sr."Invoice Date"


