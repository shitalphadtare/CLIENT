CREATE VIEW  BANK_DETAILS  AS SELECT
	 DISTINCT "RevOffice" AS "Pan No",
	 "DflBnkCode" AS "bankcode",
	 dsc."BankName",
	 "DflBnkAcct" AS "account no",
	 "DflBranch" AS "branch",
	 dc1."SwiftNum" 
FROM OADM ADM 
LEFT OUTER JOIN ODSC dsc ON adm."DflBnkCode" = dsc."BankCode" 
AND "DflBnkAcct" = "DflBnkCode" 
LEFT OUTER JOIN DSC1 dc1 ON adm."DflBnkCode" = dc1."BankCode" 
AND "DflBnkAcct" ="Account"