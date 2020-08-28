

CREATE view [dbo].[Work_certificate_New]
as
select dln.DocEntry,
dln.CardName,
dln.DocDate,
NM1.SeriesName+'/'+ CAST(dln.DocNum as varchar) 'Document Number',
dln.numatcard 'PO NO',
dln.U_BPrefdt 'PO DATE',
case 
     when dln.U_tcaddrs='Bill To' then  dln.Address 
	 else dln.Address2 end 'bill to address',
dn1.ItemCode,
isnull(dn1.U_itemdesc3,dn1.Dscription) 'Dscription',
dn1.Quantity,
dn1.U_TCDT 'TEST DATE',
dn1.U_Proofload 'PROOF LOAD',
dn1.U_SWL 'SWL',
'' 'DISTING MARK',
'' 'TYPE OF',
'' 'SERIAL NO',
dn1.U_LIft 'LIFT',
0 'Item Quanitity',
dn1.VisOrder
,'' ItmsGrpNam
,(select U_Start_Qty from [@WC_D] where DocEntry=Dln.DocEntry and visorder=dn1.VisOrder) 'start_quantity'
,(select U_End_Qty from [@WC_D] where DocEntry=Dln.DocEntry and visorder=dn1.VisOrder) 'end_quantity'
,isnull((select cardfname from ocrd where cardcode=dln.cardcode)+'  -','')+(select Name from [@TC_YR] where code=year(dln.docdate)) 'TC_YEAR'
,dln.taxdate
,isnull((select U_TCPrefix from [@TC_NUM] where code='WC'),'')+dln.U_DWCNum 'TC Number'
,dln.U_SIGN
,isnull(CD3.COUNTY+'-','') +(select Name from [@TC_YR] where code=year(dln.docdate)) 'COUNTY'
from ODLN dln 
Inner join DLN1 dn1 on dln.DocEntry=dn1.DocEntry
left outer join ocrd crd on dln.cardcode=crd.cardcode
left outer join OITM itm on dn1.ItemCode=itm.ItemCode
left outer join OITB itb on itm.ItmsGrpCod=itb.ItmsGrpCod
LEFT OUTER JOIN CRD1 CD3 ON DLN.SHIPTOCODE=CD3.ADDRESS AND CD3.AdresType='s'
left outer join NNM1 NM1 on NM1.Series=dln.Series
left outer join CRD1 cd1 on dln.CardCode=cd1.CardCode and dln.PayToCode=cd1.Address and cd1.AdresType='B'
LEFT OUTER JOIN OWHS WHS ON dn1.WHSCODE = WHS.WHSCODE 
LEFT OUTER JOIN OLCT LCT on dn1.LocCode=LCT.Code
left outer join OCST CST On LCT.State=CST.Code and  LCT.Country=CST.country
where dln.U_DTCWCReq='WC' and dn1.U_RWCReq='Yes'



GO


