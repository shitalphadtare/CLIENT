
CREATE VIEW GST_TAX_INVOICE_SUB
AS

SELECT C."ExpnsCode", C."ExpnsName" AS "CEX", C."SacCode" AS "CSAC", I."SacCode" AS "ISAC", INV."DocEntry", I."ExpnsName" AS "IEX", 
CASE WHEN inv."DocCur" = 'INR' THEN CGSTBASESUM ELSE CGSTBASESUMFRG END AS "CGSTBASESUM", CGSTTAXRATE, 
CASE WHEN inv."DocCur" = 'INR' THEN CGSTTAXSUM ELSE CGSTTAXSUMFRG END AS "CGSTTAXSUM", 
CASE WHEN inv."DocCur" = 'INR' THEN SGSTBASESUM ELSE SGSTBASESUMFRG END AS "SGSTBASESUM", SGSTRATE, 
CASE WHEN inv."DocCur" = 'INR' THEN SGSTTAXSUM ELSE SGSTTAXSUMFRG END AS "SGSTTAXSUM", 
CASE WHEN inv."DocCur" = 'INR' THEN IGSTBASESUM ELSE IGSTBASESUMFRGN END AS "IGSTBASESUM", IGSTRATE, 
CASE WHEN inv."DocCur" = 'INR' THEN IGSTTAXSUM ELSE IGSTTAXSUMFRG END AS "IGSTTAXSUM" 

FROM OINV inv 
LEFT OUTER JOIN (SELECT DISTINCT i4."DocEntry", ox."ExpnsCode", ox."ExpnsName", ox."SacCode", MAX(i4."TaxRate") AS "IGSTRATE", SUM(i4."TaxSum") AS "IGSTTAXSUM", 
				SUM(i4."TaxSumFrgn") AS "IGSTTAXSUMFRG", SUM(i4."BaseSum") AS "IGSTBASESUM", SUM(i4."BaseSumFrg") AS "IGSTBASESUMFRGN" 
				FROM INV4 i4 
				LEFT OUTER JOIN OEXD ox ON ox."ExpnsCode" = i4."ExpnsCode" WHERE "RelateType" IN (2,3) AND "staType" = -120 
				GROUP BY ox."ExpnsCode", ox."ExpnsName", i4."DocEntry", ox."SacCode") AS I ON i."DocEntry" = inv."DocEntry" 
LEFT OUTER JOIN (SELECT DISTINCT i4."DocEntry", ox."ExpnsCode", ox."ExpnsName", ox."SacCode", MAX(i4."TaxRate") AS "CGSTTAXRATE", SUM(i4."TaxSum") AS "CGSTTAXSUM", 
				SUM(i4."TaxSumFrgn") AS "CGSTTAXSUMFRG", SUM(i4."BaseSum") AS "CGSTBASESUM", SUM(i4."BaseSumFrg") AS "CGSTBASESUMFRG" 
				FROM INV4 i4 
				LEFT OUTER JOIN OEXD ox ON ox."ExpnsCode" = i4."ExpnsCode" WHERE "RelateType" IN (2,3) AND "staType" = -100 
				GROUP BY ox."ExpnsCode", ox."ExpnsName", i4."DocEntry", ox."SacCode") AS C ON inv."DocEntry" = c."DocEntry" 
LEFT OUTER JOIN (SELECT DISTINCT i4."DocEntry", ox."ExpnsCode", ox."ExpnsName", MAX(i4."TaxRate") AS "SGSTRATE", SUM(i4."TaxSum") AS "SGSTTAXSUM", 
				SUM(i4."TaxSumFrgn") AS "SGSTTAXSUMFRG", SUM(i4."BaseSum") AS "SGSTBASESUM", SUM(i4."BaseSumFrg") AS "SGSTBASESUMFRG" 
				FROM INV4 i4 
				LEFT OUTER JOIN OEXD ox ON ox."ExpnsCode" = i4."ExpnsCode" WHERE "RelateType" IN (2,3) AND "staType" = -110 
				GROUP BY ox."ExpnsCode", ox."ExpnsName", i4."DocEntry") AS S ON c."ExpnsCode" = s."ExpnsCode" AND s."DocEntry" = inv."DocEntry";


