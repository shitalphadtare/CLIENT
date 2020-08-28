

create view [dbo].[Form_V_OLD]
as
select dln.DocEntry,
dln.CardName,
dln.DocDate,
NM1.SeriesName+'/'+ CAST(dln.DocNum as varchar) 'Document Number',
dln.numatcard 'PO NO',
dln.U_BPrefdt 'PO DATE',
case WHEN dln.U_tcaddrs='Bill To' then  dln.Address 
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
--,(select isnull(sum(isnull(quantity,0)),0) from odln dln1
--inner join dln1 dn2 on dln1.DocEntry=dn2.DocEntry
--LEFT OUTER JOIN CRD1 CD2 ON DLN1.SHIPTOCODE=CD2.ADDRESS AND AdresType='s' and dln1.cardcode=cd2.CardCode
--where canceled<>'Y' and dln1.CardCode=dln.cardcode and dln1.docentry<dln.DocEntry and CD2.COUNTY=CD3.COUNTY and cast(cast(year(GETDATE()) as char(4))+'0401' as date)<=cast(cast(year(dln.docdate) as char(4))+'0401' as date)
--and dln1.U_DFVReq='YES' and dn2.U_TCReq='YES' and dn2.TargetType<>16
--)+isnull((select U_markno from ocrd where cardcode=dln.cardcode and  GETDATE()<'20200401'),0) 'start_quantity'
,isnull((select cardfname from ocrd where cardcode=dln.cardcode)+'  -','')+(select Name from [@TC_YR] where code=year(dln.docdate)) 'TC_YEAR'
,dln.taxdate
,isnull((select U_TCPrefix from [@TC_NUM] where code='FV'),'')+dln.U_DFVNum 'TC Number'
,dln.U_ship
,dln.U_shipname
,dln.U_offnum
,dln.U_Csign
,dln.U_poreg
,dln.U_owner
,isnull(CD3.COUNTY+'-','')+(select Name from [@TC_YR] where code=year(dln.docdate)) 'COUNTY'
,fv.U_Start_Qty
,fv.U_End_Qty
from ODLN dln 
Inner join DLN1 dn1 on dln.DocEntry=dn1.DocEntry
LEFT OUTER JOIN CRD1 CD3 ON DLN.SHIPTOCODE=CD3.ADDRESS AND CD3.AdresType='s' and cd3.CardCode=dln.CardCode
left outer join OITM itm on dn1.ItemCode=itm.ItemCode
left outer join OITB itb on itm.ItmsGrpCod=itb.ItmsGrpCod
left outer join NNM1 NM1 on NM1.Series=dln.Series
left outer join CRD1 cd1 on dln.CardCode=cd1.CardCode and dln.PayToCode=cd1.Address and CD1.AddrType='B' and cd1.CardCode=dln.CardCode
LEFT OUTER JOIN OWHS WHS ON dn1.WHSCODE = WHS.WHSCODE 
LEFT OUTER JOIN OLCT LCT on dn1.LocCode=LCT.Code
left outer join OCST CST On LCT.State=CST.Code and  LCT.Country=CST.country
left outer join [@FORM_V] FV on fv.DocEntry=dln.DocEntry and fv.VisOrder=dn1.VisOrder
where dln.U_DFVReq='YES' and dn1.U_TCReq='YES' and dn1.TargetType<>16






GO

