

CREATE view [dbo].[TC_table] as
select dln.DocEntry,dn1.VisOrder,dn1.Quantity,cd3.U_Mark_No,
(case when isnull((select max(U_End_qty) from [@TC_D] where U_Mark_no=CD4.U_mark_no),0)=0 then isnull(CD4.U_mark_qty,0)
else (select max(U_End_qty) from [@TC_D] where U_Mark_no=CD4.U_mark_no) end)+1 'Start_Quantity'
,dln.cardcode
,cd3.U_mark_qty
from ODLN dln 
Inner join DLN1 dn1 on dln.DocEntry=dn1.DocEntry
left outer join ocrd crd on dln.cardcode=crd.cardcode
LEFT OUTER JOIN CRD1 CD3 ON DLN.SHIPTOCODE=CD3.ADDRESS AND CD3.AdresType='s' and dln.cardcode=cd3.cardcode
LEFT OUTER JOIN CRD1 CD4 ON CD3.U_MARK_No=CD4.U_MARK_No 
where  dln.U_DTCWCReq='TC' and dn1.U_RTCReq='Yes' and dn1.TargetType<>16


GO


