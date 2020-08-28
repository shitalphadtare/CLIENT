SELECT 'Open Invoice' AS "Doc Type", T0."DocEntry", T0."DocNum", T0."DocDate", T0."TaxDate", T0."DocDueDate" AS "Due Date", T0."CardCode", 
T0."CardName", T0."DocTotal", T0."DocTotalFC", T0."DocCur", T0."Comments"
 FROM OINV T0 WHERE T0."DocStatus" = 'O'