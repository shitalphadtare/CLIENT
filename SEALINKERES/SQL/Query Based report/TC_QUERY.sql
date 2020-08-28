
/* SELECT FROM [dbo].[ODLN] T4 */DECLARE @StartDate As DATETIME/* WHERE */SET @StartDate = /* T4.DocDate */ '[%1]'
/* SELECT FROM [dbo].[ODLN] T5 */DECLARE @EndDate As DATETIME/* WHERE */SET @EndDate = /* T5.DocDate */ '[%2]'
/* SELECT FROM [dbo].[OCRD] T6 */DECLARE @FromCustomer As VARCHAR/* WHERE */SET @FromCustomer = /* T6.CARDCODE */ '[%3]'
/* SELECT FROM [dbo].[OCRD] T7 */DECLARE @ToCustomer As VARCHAR/* WHERE */SET @ToCustomer = /* T7.CardCode */ '[%4]'
/* SELECT FROM [dbo].[@tc_Num] T8 */DECLARE @TC_Certificate As VARCHAR/* WHERE */SET @TC_Certificate = /* T8.Name */ '[%5]'
select * from (
select  dln.docentry ,
       dln.docnum
	  ,case when (dln.U_DTCWCReq='TC' and dn1.U_rtcreq='YES') then 'TEST CERTIFICATE'
       when (Dln.U_DTCWCReq='WC' and dn1.U_RWCReq='YES' ) then 'WORK CERTIFICATE'
	   when (Dln.U_DFVReq='YES' and dn1.U_TCReq='YES' and crd.U_FormVReq='YES') then 'FORM V'
		 end 'TC Type'
	   ,case when (dln.U_DTCWCReq='TC' and dn1.U_rtcreq='YES') 
				then (isnull((select U_TCPrefix from [@TC_NUM] where code='TC'),'')+dln.U_DTCNum)
			 when (Dln.U_DTCWCReq='WC' and dn1.U_RWCReq='YES' )
			    then (isnull((select U_TCPrefix from [@TC_NUM] where code='WC'),'')+dln.U_DWCNum )
			  when (Dln.U_DFVReq='YES' and dn1.U_TCReq='YES' and crd.U_FormVReq='YES')
			    then isnull((select U_TCPrefix from [@TC_NUM] where code='FV'),'')+dln.U_DFVNum
				end 'TC NO',
				dln.taxdate 'Document Date',
				DLN.CardName 'Party Name',
				dn1.Itemcode 'Item Code',
				dn1.quantity ,
			isnull(CD3.COUNTY+'-','')+(select Name from [@TC_YR] where code=year(dln.docdate))+'-'+
			case when (dln.U_DTCWCReq='TC' and dn1.U_rtcreq='YES') then 
					(select cast(cast((case when c=1 then c else c+1-Quantity end) as int) as varchar)+'-'+cast(cast(c as int) as varchar) 'Mark_No'
						from (SELECT SUM(QUANTITY) OVER (PARTITION By county order by number)+quantity1 'C',* FROM
							(select row_number() over (PARTITION BY b,COUNTY order by docentry,visorder ) 'number',* from 
								(select ROW_NUMBER() OVER(PARTITION BY VisOrder,dn1.docentry order by dn1.docentry,dn1.visorder)'b',quantity,
									isnull((select case when crd.CardFName=cd1.county then crd.U_markno else cd1.U_TC_QTY end a
											from ODLN dln1 
											inner join dln1 dn2 on dn2.DocEntry=dln1.DocEntry
											left outer join ocrd crd on dln1.cardcode=crd.cardcode
											left outer join CRD1 cd1 on dln1.CardCode=cd1.CardCode and dln1.shiptocode=cd1.Address and cd1.AdresType='S'
											where  dln1.DocEntry =6 and dn2.visorder=1 and cd1.county=cd3.county  and GETDATE()<'20200101'),0)  'quantity1'
								,dn1.VisOrder,
								dn1.DocEntry,cd3.County
								from ODLN dln 
								Inner join DLN1 dn1 on dln.DocEntry=dn1.DocEntry
								LEFT OUTER JOIN CRD1 CD3 ON DLN.SHIPTOCODE=CD3.ADDRESS AND CD3.AdresType='s' and dln.cardcode=cd3.cardcode
								where dln.U_DTCWCReq='TC' and dn1.U_rtcreq='YES' --AND COUNTY<>''
								)A
							) b
						)C
					where docentry=dn1.DocEntry and visorder=dn1.visorder
				)
			when (Dln.U_DTCWCReq='WC' and dn1.U_RWCReq='YES' ) then
				(select cast(cast((case when c=1 then c else c+1-Quantity end) as int) as varchar)+'-'+cast(cast(c as int) as varchar) 'Mark_No'
						from (SELECT SUM(QUANTITY) OVER (PARTITION By county order by number)+quantity1 'C',* FROM
							(select row_number() over (PARTITION BY b,COUNTY order by docentry,visorder ) 'number',* from 
								(select ROW_NUMBER() OVER(PARTITION BY VisOrder,dn1.docentry order by dn1.docentry,dn1.visorder)'b',quantity,
									isnull((select case when crd.CardFName=cd1.county then crd.U_markno else cd1.U_TC_QTY end a
											from ODLN dln1 
											inner join dln1 dn2 on dn2.DocEntry=dln1.DocEntry
											left outer join ocrd crd on dln1.cardcode=crd.cardcode
											left outer join CRD1 cd1 on dln1.CardCode=cd1.CardCode and dln1.shiptocode=cd1.Address and cd1.AdresType='S'
											where  dln1.DocEntry =6 and dn2.visorder=1 and cd1.county=cd3.county  and GETDATE()<'20200101'),0)  'quantity1'
								,dn1.VisOrder,
								dn1.DocEntry,cd3.County
								from ODLN dln 
								Inner join DLN1 dn1 on dln.DocEntry=dn1.DocEntry
								LEFT OUTER JOIN CRD1 CD3 ON DLN.SHIPTOCODE=CD3.ADDRESS AND CD3.AdresType='s' and dln.cardcode=cd3.cardcode
								where dln.U_DTCWCReq='WC' and dn1.U_RWCReq='YES' --AND COUNTY<>''
								)A
							) b
						)C
					where docentry=dn1.DocEntry and visorder=dn1.visorder
				) 
				when (Dln.U_DFVReq='YES' and dn1.U_TCReq='YES' and crd.U_FormVReq='YES') then 
				(select cast(cast((case when c=1 then c else c+1-Quantity end) as int) as varchar)+'-'+cast(cast(c as int) as varchar) 'Mark_No'
						from (SELECT SUM(QUANTITY) OVER (PARTITION By county order by number)+quantity1 'C',* FROM
							(select row_number() over (PARTITION BY b,COUNTY order by docentry,visorder ) 'number',* from 
								(select ROW_NUMBER() OVER(PARTITION BY VisOrder,dn1.docentry order by dn1.docentry,dn1.visorder)'b',quantity,
									isnull((select case when crd.CardFName=cd1.county then crd.U_markno else cd1.U_TC_QTY end a
											from ODLN dln1 
											inner join dln1 dn2 on dn2.DocEntry=dln1.DocEntry
											left outer join ocrd crd on dln1.cardcode=crd.cardcode
											left outer join CRD1 cd1 on dln1.CardCode=cd1.CardCode and dln1.shiptocode=cd1.Address and cd1.AdresType='S'
											where  dln1.DocEntry =6 and dn2.visorder=1 and cd1.county=cd3.county  and GETDATE()<'20200101'),0)  'quantity1'
								,dn1.VisOrder,
								dn1.DocEntry,cd3.County
								from ODLN dln 
								Inner join DLN1 dn1 on dln.DocEntry=dn1.DocEntry
								LEFT OUTER JOIN CRD1 CD3 ON DLN.SHIPTOCODE=CD3.ADDRESS AND CD3.AdresType='s' and dln.cardcode=cd3.cardcode
								where Dln.U_DFVReq='YES' and dn1.U_TCReq='YES' and crd.U_FormVReq='YES' --AND COUNTY<>''
								)A
							) b
						)C
					where docentry=dn1.DocEntry and visorder=dn1.visorder
				) 
				 else '' end 'Mark_No'
				 ,usr.USER_CODE

 from odln dln
inner join dln1 dn1 on dln.DocEntry=dn1.DocEntry
left outer join ocrd crd on crd.CardCode=dln.CardCode
LEFT OUTER JOIN CRD1 CD3 ON DLN.SHIPTOCODE=CD3.ADDRESS AND CD3.AdresType='s' and dln.cardcode=cd3.cardcode
left outer join ousr usr on dln.usersign=usr.userid

where 
(case when (dln.U_DTCWCReq='TC' and dn1.U_rtcreq='YES') then 'TC'
      when (Dln.U_DTCWCReq='WC' and dn1.U_RWCReq='YES' ) then 'WC'
	  when (Dln.U_DFVReq='YES' and dn1.U_TCReq='YES' and crd.U_FormVReq='YES') then 'Form V'
 end <>'' or case when (dln.U_DTCWCReq='TC' and dn1.U_rtcreq='YES') then 'TC'
      when (Dln.U_DTCWCReq='WC' and dn1.U_RWCReq='YES' ) then 'WC'
	  when (Dln.U_DFVReq='YES' and dn1.U_TCReq='YES' and crd.U_FormVReq='YES') then 'Form V'
 end <> null)
 and dln.DocDate>=[%1] and dln.docdate<=[%2] and dln.cardcode>='[%3]' and dln.CardCode<='[%4]'
 and (case when (dln.U_DTCWCReq='TC' and dn1.U_rtcreq='YES') then 'TEST CERTIFICATE'
       when (Dln.U_DTCWCReq='WC' and dn1.U_RWCReq='YES' ) then 'WORK CERTIFICATE'
	   when (Dln.U_DFVReq='YES' and dn1.U_TCReq='YES' and crd.U_FormVReq='YES') then 'FORM V'
		 end ) in (CASE when '[%5]' is null  or '[%5]' ='' then (case when (dln.U_DTCWCReq='TC' and dn1.U_rtcreq='YES') then 'TEST CERTIFICATE'
       when (Dln.U_DTCWCReq='WC' and dn1.U_RWCReq='YES' ) then 'WORK CERTIFICATE'
	   when (Dln.U_DFVReq='YES' and dn1.U_TCReq='YES' and crd.U_FormVReq='YES') then 'FORM V'
		 end ) else '[%5]' end) and dn1.TargetType<>16 and dln.CANCELED<>'C'
	  union 


	  select  dln.docentry,
       dln.docnum
	  ,'BRAND CERTIFICATE' 'TC Type'
	   ,((select U_TCPrefix from [@TC_NUM] where code='BC')+cast(OSRN.u_TC_NUM as char) ) 'TC NO',
				dln.taxdate 'Document Date',
				DLN.CardName 'Party Name',
				dn1.Itemcode 'Item Code',
				dn1.quantity 
				,osrn.distnumber 'Mark_No'
				,usr.USER_CODE
 from odln dln
inner join dln1 dn1 on dln.DocEntry=dn1.DocEntry
left outer join ocrd crd on crd.CardCode=dln.CardCode
LEFT OUTER JOIN CRD1 CD3 ON DLN.SHIPTOCODE=CD3.ADDRESS AND CD3.AdresType='s' and dln.cardcode=cd3.cardcode
left outer join ousr usr on dln.usersign=usr.userid
inner join OITL on dn1.DocEntry = OITL.ApplyEntry and dn1.LineNum = OITL.ApplyLine and OITL.ApplyType = 15
inner join ITL1 on OITL.LogEntry = ITL1.LogEntry
inner join OSRN on ITL1.Itemcode=osrn.itemcode and ITL1.MdAbsEntry = OSRN.AbsEntry
where U_RBCReq='Yes' and dln.DocDate>=[%1] and dln.docdate<=[%2] and dln.cardcode>='[%3]' and dln.CardCode<='[%4]'
 and 'BRAND CERTIFICATE' in (CASE when '[%5]' is null  or '[%5]' ='' then 'BRAND CERTIFICATE' else '[%5]' end)
 and dn1.TargetType<>16 and dln.CANCELED<>'C'
)  Final

order by Final.docentry,final.[TC NO]
