------------Contact Person
SELECT T0."Name" FROM OCPR T0 WHERE T0."CardCode" = $[ORDR.CARDCODE];

-----------------ITEM BRAND
SELECT T0."U_Brand" FROM OITM T0 WHERE T0."ItemCode" = $[$38.1.0];

-------------ITEM CATEGORY
SELECT T0."U_Category" FROM OITM T0 WHERE T0."ItemCode" = $[$38.1.0];

------------Item Desc 2
SELECT "U_ItemDesc2" FROM OITM WHERE "ItemCode" = $[RDR1.ItemCode];

--------------Item Desc 3
SELECT "U_ItemDesc3" FROM OITM WHERE "ItemCode" = $[POR1.ItemCode];

-------- Transporter
SELECT T0."U_Transporter" FROM OCRD T0 WHERE T0."CardCode" = $[Ordr.CardCode];



