Create view SALES_ORDER_ITEMWISE as
SELECT rdr."DocNum", rdr."DocDate", rdr."CardCode", rdr."CardName", rdr."NumAtCard", slp."SlpName", RR1."ItemCode", rr1."Dscription", 
rr1."Quantity", rr1."unitMsr", rr1."Price" 
FROM ORDR RDR 
INNER JOIN RDR1 RR1 ON RDR."DocEntry" = RR1."DocEntry" LEFT OUTER JOIN OSLP SLP ON slp."SlpCode" = RDR."SlpCode" 
LEFT OUTER JOIN OITM t2 ON rr1."ItemCode" = t2."ItemCode" 