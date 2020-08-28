CREATE VIEW SALES_GROSS_PROFIT_REPORT  AS ((SELECT
	 DISTINCT T0."TaxDate" AS "Posted",
	 CASE WHEN T0."ObjType" = 13 
		THEN 'Invoice' WHEN T0."ObjType" = 14 
		THEN 'CrMemo' 
		ELSE 'Error' 
		END AS "Inv/CM",
	 T0."DocEntry",
	 T0."DocNum" AS "Num",
	 T0."CardCode" AS "Cust Code",
	 T0."CardName" AS "Customer",
	 CASE WHEN T0."DocType" = 'S' 
		THEN 'Service' WHEN T0."DocType" = 'I' 
		THEN 'Item' 
		ELSE 'Error' 
		END AS "Sales Type",
	 (T0."DocTotal" - T0."VatSum") - T0."TotalExpns" AS "Line Sales",
	 T0."GrosProfit",
	 CASE WHEN ((T0."DocTotal" - T0."VatSum") - T0."TotalExpns") = 0.000 
		THEN 0.000 
		ELSE ((T0."GrosProfit") / ((T0."DocTotal" - T0."VatSum") - T0."TotalExpns")) * 100 
		END AS "Gross Prof %" 
		FROM OINV T0) 
	UNION ALL (SELECT
	 DISTINCT T0."TaxDate" AS "Posted",
	 CASE WHEN T0."ObjType" = 13 
		THEN 'Invoice' WHEN T0."ObjType" = 14 
		THEN 'CrMemo' 
		ELSE 'Error' 
		END AS "Inv/CM",
	 T0."DocEntry",
	 T0."DocNum" AS "Num",
	 T0."CardCode" AS "Cust Code",
	 T0."CardName" AS "Customer",
	 CASE WHEN T0."DocType" = 'S' 
		THEN 'Service' WHEN T0."DocType" = 'I' 
		THEN 'Item' 
		ELSE 'Error' 
		END AS "Sales Type",
	 ((T0."DocTotal" - T0."VatSum") - T0."TotalExpns") * -1 AS "Line Sales",
	 T0."GrosProfit" * -1,
	 CASE WHEN ((T0."DocTotal" - T0."VatSum") - T0."TotalExpns") = 0.000 
		THEN 0.000 
		ELSE ((T0."GrosProfit") / ((T0."DocTotal" - T0."VatSum") - T0."TotalExpns")) * -100 
		END AS "Gross Prof %" 
		FROM ORIN T0)) WITH READ ONLY