

CREATE VIEW GST_PROFORMA_INVOICE_SUBREPORT
AS

SELECT 
C."ExpnsCode",
 C."ExpnsName" AS "CEX", C."SacCode" AS "CSAC", I."SacCode" AS "ISAC", dpi."DocEntry", I."ExpnsName" AS "IEX", 
 CASE WHEN dpi."DocCur" = 'INR' THEN CGSTBASESUM ELSE CGSTBASESUMFRG END AS "CGSTBASESUM", CGSTTAXRATE, 
 CASE WHEN dpi."DocCur" = 'INR' THEN CGSTTAXSUM ELSE CGSTTAXSUMFRG END AS "CGSTTAXSUM", 
 CASE WHEN dpi."DocCur" = 'INR' THEN SGSTBASESUM ELSE SGSTBASESUMFRG END AS "SGSTBASESUM", SGSTRATE, 
 CASE WHEN dpi."DocCur" = 'INR' THEN SGSTTAXSUM ELSE SGSTTAXSUMFRG END AS "SGSTTAXSUM", 
 CASE WHEN dpi."DocCur" = 'INR' THEN IGSTBASESUM ELSE IGSTBASESUMFRGN END AS "IGSTBASESUM", IGSTRATE, 
 CASE WHEN dpi."DocCur" = 'INR' THEN IGSTTAXSUM ELSE IGSTTAXSUMFRG END AS "IGSTTAXSUM" 
 FROM ODPI dpi 
 LEFT OUTER JOIN (SELECT DISTINCT i4."DocEntry", ox."ExpnsCode", ox."ExpnsName", ox."SacCode", 
 MAX(i4."TaxRate") AS "IGSTRATE", SUM(i4."TaxSum") AS "IGSTTAXSUM", SUM(i4."TaxSumFrgn") AS "IGSTTAXSUMFRG", 
 SUM(i4."BaseSum") AS "IGSTBASESUM", SUM(i4."BaseSumFrg") AS "IGSTBASESUMFRGN" 
 FROM DPI4 i4 LEFT OUTER JOIN OEXD ox ON ox."ExpnsCode" = i4."ExpnsCode" WHERE "RelateType" IN (2,3) AND "staType" = -120 
 GROUP BY ox."ExpnsCode", ox."ExpnsName", i4."DocEntry", ox."SacCode") AS I ON i."DocEntry" = dpi."DocEntry" 
 LEFT OUTER JOIN (SELECT DISTINCT i4."DocEntry", ox."ExpnsCode", ox."ExpnsName", ox."SacCode", MAX(i4."TaxRate") AS "CGSTTAXRATE", 
 SUM(i4."TaxSum") AS "CGSTTAXSUM", SUM(i4."TaxSumFrgn") AS "CGSTTAXSUMFRG", SUM(i4."BaseSum") AS "CGSTBASESUM", 
 SUM(i4."BaseSumFrg") AS "CGSTBASESUMFRG" 
 FROM DPI4 i4 
 LEFT OUTER JOIN OEXD ox ON ox."ExpnsCode" = i4."ExpnsCode" WHERE "RelateType" IN (2,3) AND "staType" = -100 
 GROUP BY ox."ExpnsCode", ox."ExpnsName", i4."DocEntry", ox."SacCode") AS C ON dpi."DocEntry" = c."DocEntry" 
 LEFT OUTER JOIN (SELECT DISTINCT i4."DocEntry", ox."ExpnsCode", ox."ExpnsName", MAX(i4."TaxRate") AS "SGSTRATE", 
 SUM(i4."TaxSum") AS "SGSTTAXSUM", SUM(i4."TaxSumFrgn") AS "SGSTTAXSUMFRG", SUM(i4."BaseSum") AS "SGSTBASESUM", 
 SUM(i4."BaseSumFrg") AS "SGSTBASESUMFRG" 
 FROM DPI4 i4 
 LEFT OUTER JOIN OEXD ox ON ox."ExpnsCode" = i4."ExpnsCode" WHERE "RelateType" IN (2,3) AND "staType" = -110 
 GROUP BY ox."ExpnsCode", ox."ExpnsName", i4."DocEntry") AS S ON c."ExpnsCode" = s."ExpnsCode" AND s."DocEntry" = dpi."DocEntry"
