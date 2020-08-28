create view PTS_PURCHASE_ORDER_ITEMWISE as
SELECT POR."DocNum", POR."DocDate", POR."CardCode", POR."CardName", POR."NumAtCard", slp."SlpName", PR1."ItemCode", PR1."Dscription", 
PR1."Quantity", PR1."unitMsr", PR1."PriceBefDi" 
FROM OPOR POR 
INNER JOIN POR1 PR1 ON POR."DocEntry" = PR1."DocEntry" 
LEFT OUTER JOIN OSLP SLP ON slp."SlpCode" = POR."SlpCode" 
LEFT OUTER JOIN OITM t2 ON PR1."ItemCode" = t2."ItemCode" 