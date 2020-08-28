


alter view [dbo].[Form_V_P]
as
select dln.DocEntry,
dln.CardName,
dln.docnum,
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
,(select isnull(sum(isnull(quantity,0)),0) from odln dln1
inner join dln1 dn2 on dln1.DocEntry=dn2.DocEntry
LEFT OUTER JOIN CRD1 CD2 ON DLN1.SHIPTOCODE=CD2.ADDRESS AND AdresType='s'
where canceled<>'Y' and dln1.CardCode=dln.cardcode 
and dln1.docentry<dln.DocEntry and CD2.COUNTY=CD3.COUNTY 
and cast(cast(year(GETDATE()) as char(4))+'0401' as date)<=cast(cast(year(dln.docdate) as char(4))+'0401' as date)
and dln1.U_DFVReq='YES' and dn2.U_TCReq='YES' and dn2.TargetType<>16
)+isnull((select U_markno from ocrd where cardcode=dln.cardcode and  GETDATE()<'20200401'),0) 'start_quantity'
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
,(select cast(cast((case when c=1 then c else c+1-Quantity end) as int) as varchar)+'-'+cast(cast(c as int) as varchar) 'Mark_No'
						from (SELECT SUM(QUANTITY) OVER (PARTITION By county order by number) 'C',* FROM
							(select row_number() over (PARTITION BY b,COUNTY order by docentry,visorder ) 'number',* from 
								(select ROW_NUMBER() OVER(PARTITION BY VisOrder,dn1.docentry order by dn1.docentry,dn1.visorder)'b',quantity,
									isnull((select case when crd.CardFName=cd1.county then crd.U_markno else cd1.U_TC_QTY end a
											from ODLN dln1 
											inner join dln1 dn2 on dn2.DocEntry=dln1.DocEntry
											left outer join ocrd crd on dln1.cardcode=crd.cardcode
											left outer join CRD1 cd1 on dln1.CardCode=cd1.CardCode and dln1.shiptocode=cd1.Address and cd1.AdresType='S'
											where  dln1.DocEntry =dln.docentry and dln1.cardcode=dln1.cardcode and dn2.visorder=dn1.visorder and cd1.county=cd3.county  and GETDATE()<'20200101'),0)  'quantity1'
								,dn1.VisOrder,
								dn1.DocEntry,cd3.County
								from ODLN dln 
								Inner join DLN1 dn1 on dln.DocEntry=dn1.DocEntry
								left outer join ocrd crd on dln.cardcode=crd.cardcode
								LEFT OUTER JOIN CRD1 CD3 ON DLN.SHIPTOCODE=CD3.ADDRESS AND CD3.AdresType='s' and dln.cardcode=cd3.cardcode
								where dln.U_DFVReq='YES' and dn1.U_TCReq='YES' and crd.U_FormVReq='Yes' and dn1.TargetType<>16 and dln.CANCELED<>'Y'
								)A
							) b
						)C
					where docentry=dn1.DocEntry and visorder=dn1.visorder
				) 'Mark_No'

from ODLN dln 
Inner join DLN1 dn1 on dln.DocEntry=dn1.DocEntry
left outer join ocrd crd on crd.cardcode=dln.CardCode
LEFT OUTER JOIN CRD1 CD3 ON DLN.SHIPTOCODE=CD3.ADDRESS AND CD3.AdresType='s' and cd3.CardCode=dln.CardCode
left outer join OITM itm on dn1.ItemCode=itm.ItemCode
left outer join OITB itb on itm.ItmsGrpCod=itb.ItmsGrpCod
left outer join NNM1 NM1 on NM1.Series=dln.Series
left outer join CRD1 cd1 on dln.CardCode=cd1.CardCode and dln.PayToCode=cd1.Address and CD1.AddrType='B' and cd1.CardCode=dln.CardCode
LEFT OUTER JOIN OWHS WHS ON dn1.WHSCODE = WHS.WHSCODE 
LEFT OUTER JOIN OLCT LCT on dn1.LocCode=LCT.Code
left outer join OCST CST On LCT.State=CST.Code and  LCT.Country=CST.country
where dln.U_DFVReq='YES' and dn1.U_TCReq='YES' and crd.U_FormVReq='Yes' and dn1.TargetType<>16 and dln.CANCELED<>'Y'




GO


