



Create View Job_Card_Work_Order
as


SELECT
DISTINCT
RDR."DocEntry" AS "Docentry",
RDR."DocNum" AS "Docnum", RDR."DocDate" AS "SO Date", 
RDR."NumAtCard" AS "CustRefNo", RDR."U_BPRefDt" AS "OrdDate", 
RDR."CardName" AS "CustomerName",
RDR."U_JobCrdOw" AS "JobCardOwner", 
RDR."DocDueDate" AS "SODelDate", 
RR1."Dscription" || ' ' || IFNULL(RR1."U_ItemDesc2" || ' ', '') || IFNULL(rr1."U_ItemDesc3" || ' ', '') AS "ItemDesc", 
RR1."ItemCode", RR1."Dscription", 
RR1."U_ItemDesc2", RR1."U_ItemDesc3", 
RR1."U_RemForJC", RR1."Quantity", RR1."unitMsr" AS "UOM", RR1."U_StLoc" AS "Stock Location", RR1."Price", 
IFNULL(itm."PicturName", '') AS "picturname", rr1."VisOrder" 
FROM ORDR RDR 
INNER JOIN RDR1 RR1 ON RR1."DocEntry" = RDR."DocEntry" 
LEFT OUTER JOIN OITM itm ON itm."ItemCode" = rr1."ItemCode"



