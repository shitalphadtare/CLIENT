CREATE view PTS_ITEM_MASTER_LISTING as
SELECT T0."ItemCode", T0."ItemName", T0."U_ItemDesc2", T0."U_ItemDesc3", T0."ItmsGrpCod",T1."ItmsGrpNam" "Item Group Name", T0."BuyUnitMsr",
 T0."SalUnitMsr", T0."CreateDate", T0."CreateTS" , T0."UpdateDate",
case when T0."InvntItem"='Y' then 'Yes' else 'No' end "Inventory Item",
case when T0."SellItem"='Y' then 'Yes' else 'No' end "Sales Item",
case when T0."PrchseItem"='Y' then 'Yes' else 'No' end "Purchase Item",
 T0."BuyUnitMsr" "Purchase UOM",
 T0."SalUnitMsr" "Sales UOM",
 case when T0."validFor"='Y' then 'Active' else 'Inactive' end "Active/NOT",T3."ChapterID"
FROM OITM T0
INNER JOIN OITB T1 ON T0."ItmsGrpCod" = T1."ItmsGrpCod" 
LEFT OUTER JOIN OCHP T3 ON T0."ChapterID" = T3."AbsEntry" 