create Procedure [dbo].[SP_WorkC_Report_p]
as
begin

;with CTE_RunningTotal as
		( select number,quantity+isnull(quantity1,0) 'quantity',county,docentry,visorder,quantity1 
		from
		(select row_number() over (PARTITION BY b,COUNTY order by docentry,visorder ) 'number',* 
								from 
								(select ROW_NUMBER() OVER(PARTITION BY VisOrder,dn1.docentry order by dn1.docentry,dn1.visorder)'b',quantity,
									isnull((select case when crd.CardFName=cd1.county then crd.U_WCMarkNo else cd1.U_WC_QTY end a
											from ODLN dln1 
											inner join dln1 dn2 on dn2.DocEntry=dln1.DocEntry
											left outer join ocrd crd on dln1.cardcode=crd.cardcode
											left outer join CRD1 cd1 on dln1.CardCode=cd1.CardCode and dln1.shiptocode=cd1.Address and cd1.AdresType='S'
											where  dln1.DocEntry =dln.docentry and dln1.cardcode=dln1.cardcode 
											and dn2.visorder=dn1.visorder and cd1.county=cd3.county  
											and GETDATE()<'20200101'),0)  'quantity1'
								,dn1.VisOrder,
								dn1.DocEntry,cd3.County
								from ODLN dln 
								Inner join DLN1 dn1 on dln.DocEntry=dn1.DocEntry
								LEFT OUTER JOIN CRD1 CD3 ON DLN.SHIPTOCODE=CD3.ADDRESS AND CD3.AdresType='s' and dln.cardcode=cd3.cardcode
								where dln.U_DTCWCReq='WC' and dn1.U_RWCReq='Yes' and dln.CANCELED<>'Y' and dn1.TargetType<>16 
								)A
		)b),
------------------------------------------------------------------------------
WorkC_Report_p as(
					select  dln.DocEntry,
							dln.CardName,
							dln.DocDate,
							NM1.SeriesName+'/'+ CAST(dln.DocNum as varchar) 'Document Number',
							dln.numatcard 'PO NO',
							dln.U_BPrefdt 'PO DATE',
							case when dln.U_tcaddrs='Bill To' then  dln.Address 
								else dln.Address2 end 'bill to address',
							dn1.ItemCode,
							isnull(dn1.U_itemdesc3,dn1.Dscription) 'Dscription',
							dn1.Quantity,
							case when DN7.U_TCDT='' or dn7.U_TCDT is null then dn1.U_TCDT else dn7.U_TCDT end 'TEST DATE',
							case when dn7.U_PRROFLOAD='' or dn7.U_PRROFLOAD is null then dn1.U_PROOFLOAD else dn7.U_PRROFLOAD end 'PROOF LOAD',
							case when DN7.U_SWL='' or dn7.U_SWL is null then dn1.U_swl else dn7.U_SWL end 'SWL',
							case when dn7.U_LIfi='' OR dn7.U_LIFI is null then dn1.U_LIFT else dn7.U_LIFI end 'LIFT',
							0 'Item Quanitity',
							dn1.VisOrder
							,'' ItmsGrpNam
							,isnull((select cardfname from ocrd where cardcode=dln.cardcode)+'  -','')
							+(select Name from [@TC_YR] where code=year(dln.docdate)) 'TC_YEAR'
							,dln.taxdate
							,isnull((select U_TCPrefix from [@TC_NUM] where code='WC'),'')+dln.U_DWCNum 'TC Number'
							,dln.U_SIGN
							,isnull(CD3.COUNTY+'-','') +(select Name from [@TC_YR] where code=year(dln.docdate)) 'COUNTY'
							,case when dln.U_tcaddrs='Bill To' then  dln.PayToCode
							else dln.ShipToCode end 'THIRD_PARTY'
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
					LEFT OUTER JOIN DLN8 DN8 ON DLN.DocEntry = DN8.DocEntry and dn1.ItemCode=dn8.ItemCode
					LEFT OUTER JOIN DLN7 AS DN7 ON DN7.DocEntry = DLN.DocEntry and DN7.PackageNum =DN8.PackageNum
where dln.U_DTCWCReq='WC' and dn1.U_RWCReq='Yes' and dn1.TargetType<>16 and dln.CANCELED<>'Y'
)


------------------------------------------------------------------------------------------------------------------------

select cast(cast((case when Mark_Qty=1 then Mark_Qty else Mark_Qty+1-Quantity end) as int) as varchar)+'-'+cast(cast(Mark_Qty as int) as varchar) 'Mark_No'
		,*		
		from 
		(select (select sum(Quantity) from CTE_RunningTotal c where c.number<=b.number and isnull(c.County,'')=isnull(b.County,''))'Mark_Qty'
					,b.number,b.Quantity 'B_Qty',b.County 'B_County',b.VisOrder 'B_Vis',a.*
				from WorkC_Report_p A
				left outer join CTE_RunningTotal B on a.DocEntry=b.DocEntry and a.VisOrder=b.VisOrder
		) final
	order by final.DocEntry,final.VisOrder
end
go