
ALTER view [dbo].[TestC_Report_New]
as
select dln.DocEntry,
dln.CardName,
dln.DocDate,
NM1.SeriesName+'/'+ CAST(dln.DocNum as varchar) 'Document Number',
dln.numatcard 'PO NO',
dln.U_BPrefdt 'PO DATE',
case      when dln.U_tcaddrs='Bill To' then  dln.Address
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
--LEFT OUTER JOIN CRD1 CD2 ON DLN1.SHIPTOCODE=CD2.ADDRESS AND AdresType='s'
--where canceled<>'Y' and dln1.CardCode=dln.CardCode and dln1.docentry<dln.DocEntry and CD2.COUNTY=CD3.COUNTY and dn2.U_RTCReq='Yes'
-- and year(getdate())=year(dln1.docdate) and dln1.U_DTCWCReq='TC' and dn2.TargetType<>16)
--+isnull((select case when crd.CardFName=cd1.county
--then crd.U_markno else cd1.U_TC_QTY end a
--from ODLN dln1 
--left outer join ocrd crd on dln1.cardcode=crd.cardcode
--left outer join CRD1 cd1 on dln1.CardCode=cd1.CardCode and dln1.shiptocode=cd1.Address and cd1.AdresType='S'
--where  dln1.DocEntry =dln.docentry and GETDATE()<'20200101'),0 )  'start_quantity'
,(select U_Start_Qty from [@TC_D] where DocEntry=dln.docentry and VisOrder=dn1.visorder) 'start_quantity'
,(select U_End_Qty from [@TC_D] where DocEntry=dln.docentry and VisOrder=dn1.visorder) 'end_quantity'
,isnull((select cardfname from ocrd where cardcode=dln.cardcode)+'  -','')+(select Name from [@TC_YR] where code=year(dln.docdate)) 'TC_YEAR'
,dln.taxdate
,dln.U_SIGN
--,isnull((select U_TCPrefix from [@TC_NUM] where code='TC'),'')+dln.U_DTCNum 'TC Number'
---change on 06012020
,case when year(dln.docdate)='2019' then isnull((select U_TCPrefix from [@TC_NUM] where code='TC'),'')
else (select U_TCPrefix from [@TC_NUM] where right(code,4)=cast(year(dln.DocDate) as varchar) and left(Code,2)='TC') end

+dln.U_DTCNum 'TC Number'
,isnull(CD3.COUNTY+'-','')+(select Name from [@TC_YR] where code=year(dln.docdate)) 'COUNTY'
,case 
     when dln.U_tcaddrs='Bill To' then  dln.PayToCode
	 else dln.ShipToCode end 'THIRD_PARTY'


from ODLN dln 
Inner join DLN1 dn1 on dln.DocEntry=dn1.DocEntry
LEFT OUTER JOIN CRD1 CD3 ON DLN.SHIPTOCODE=CD3.ADDRESS AND CD3.AdresType='s' and dln.cardcode=cd3.cardcode
left outer join OITM itm on dn1.ItemCode=itm.ItemCode
left outer join OITB itb on itm.ItmsGrpCod=itb.ItmsGrpCod
left outer join NNM1 NM1 on NM1.Series=dln.Series
left outer join CRD1 cd1 on dln.CardCode=cd1.CardCode and dln.PayToCode=cd1.Address and cd1.AdresType='B'
LEFT OUTER JOIN OWHS WHS ON dn1.WHSCODE = WHS.WHSCODE 
LEFT OUTER JOIN OLCT LCT on dn1.LocCode=LCT.Code
left outer join OCST CST On LCT.State=CST.Code and  LCT.Country=CST.country
where dln.U_DTCWCReq='TC' and dn1.U_RTCReq='Yes' and dn1.TargetType<>16



GO


