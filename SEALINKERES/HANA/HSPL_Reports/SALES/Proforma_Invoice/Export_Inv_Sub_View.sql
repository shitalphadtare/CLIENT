
create view Export_Inv_Sub
as


SELECT  
iv3."DocEntry", exd."ExpnsName", (CASE WHEN oi."DocCur" = 'INR' THEN iv3."LineTotal" ELSE iv3."TotalFrgn" END) AS "LineTotal", 
oi."DocCur" FROM OINV oi LEFT OUTER JOIN INV3 iv3 ON oi."DocEntry" = iv3."DocEntry" 
LEFT OUTER JOIN OEXD exd ON iv3."ExpnsCode" = exd."ExpnsCode"





