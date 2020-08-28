CREATE VIEW  COMPANY_ADDR AS SELECT
	 IFNULL("Block" || ' ',
	 '') || IFNULL("Building" || ' ',
	 '') || IFNULL("Street" || ' ',
	 '') || IFNULL("City" || ' -',
	 '') || IFNULL("ZipCode" || ' ',
	 '') || IFNULL((SELECT
	 "Name" 
		FROM OCST 
		WHERE "Code" = "State") || ',',
	 '') || IFNULL(OCRY."Name" || '.',
	 '') AS "Address" 
FROM ADM1 
LEFT OUTER JOIN OCRY ON OCRY."Code" = ADM1."Country"  