DECLARE
@StartDate DATETIME,
@EndDate DATETIME,
@Dummy INTEGER
SELECT TOP 1 @Dummy = DocNum FROM  OPCH T0 WHERE T0.DocDate >= [%0] AND T0.DocDate <= [%1]
SELECT
@StartDate= '[%0]',
@EndDate = '[%1]'
select * from 
(SELECT T0.Docentry, cast(MONTH(T0.[DocDate]) as nvarchar(2))+'/'+cast(YEAR(T0.[DocDate]) as nvarchar(4))as 'Month',  T4.[WTName],OSEC.Code as Section ,
--OACT.AcctName as Particular,
T0.[CardCode]as BPCode,  T0.[CardName] as 'Party Name',T3.[TaxId0]as 'PAN No.', 
case when T5.[TypWTReprt] ='P' then 'Others' else   case when    T5.[TypWTReprt] = 'C' then 'Company'    end end  [Status], 
isnull(T0.[NumAtCard],'')+' - ' + cast(convert(date,T0.[TaxDate],103) as varchar) as 'Bill No & Date' , T0.[DocDate] EntryDate,T0.[DocNum] as 'A/P Num','Advance Payment' 'Type',
(T0.[DocTotal] +T1.[WTAmnt]) as 'Total Bill Amount',  T1.[TaxbleAmnt] as 'Amount Debited to P&L' , T1. [Rate] as 'TDS Rate', T1.[WTAmnt] as TDS ,T1.[WTCode], T4.[BaseType] 
,vpm.challanno 'Challan No.',vpm.challandat 'Challan Date',vpm.bsrcode 'BSR Code',vpm.challanbak 'Bank Name'
FROM ODPO T0   
INNER JOIN DPO5 T1 ON T0.DocEntry = T1.AbsEntry  
INNER JOIN DPO12 T3 ON T0.DocEntry = T3.DocEntry  INNER JOIN OWHT T4 ON T1.WTCode = T4.WTCode  
INNER JOIN OCRD T5 ON T0.CardCode = T5.CardCode LEFT JOIN OWHT on OWHT.WTCode=T1.WTCode      
LEFT JOIN OSEC on OSEC.AbsId=OWHT.Section 
left outer join vpm8 vm8 on vm8.docentry=t0.docentry and vm8.invtype=204
left outer join ovpm vpm on vm8.docnum=vpm.docnum
where T0.[DocDate] >= [%0] and T0.[DocDate] <= [%1] AND 
T0.[CANCELED]!='Y' and T0.[CANCELED]!='C'

Union All


SELECT T0.Docentry, cast(MONTH(T0.[DocDate]) as nvarchar(2))+'/'+cast(YEAR(T0.[DocDate]) as nvarchar(4))as 'Month',  T4.[WTName],OSEC.Code as Section ,
--OACT.AcctName as Particular,
T0.[CardCode]as BPCode,  T0.[CardName] as 'Party Name',T3.[TaxId0]as 'PAN No.', 
case when T5.[TypWTReprt] ='P' then 'Others' else   case when    T5.[TypWTReprt] = 'C' then 'Company'    end end  [Status], 
isnull(T0.[NumAtCard],'')+' - ' + cast(convert(date,T0.[TaxDate],103) as varchar) as 'Bill No & Date' , T0.[DocDate] EntryDate,T0.[DocNum] as 'A/P Num','Invoice' 'Type',
(T0.[DocTotal] +T1.[WTAmnt]) as 'Total Bill Amount',  
T1.[TaxbleAmnt] as 'Amount Debited to P&L' , T1. [Rate] as 'TDS Rate', 
T1.[WTAmnt] as TDS ,T1.[WTCode], T4.[BaseType] 
,vpm.challanno 'Challan No.',vpm.challandat 'Challan Date',vpm.bsrcode 'BSR Code',vpm.challanbak 'Bank Name'
FROM OPCH T0   
INNER JOIN PCH5 T1 ON T0.DocEntry = T1.AbsEntry  
INNER JOIN PCH12 T3 ON T0.DocEntry = T3.DocEntry  INNER JOIN OWHT T4 ON T1.WTCode = T4.WTCode  
INNER JOIN OCRD T5 ON T0.CardCode = T5.CardCode LEFT JOIN OWHT on OWHT.WTCode=T1.WTCode      
LEFT JOIN OSEC on OSEC.AbsId=OWHT.Section 
left outer join vpm8 vm8 on vm8.docentry=t0.docentry and vm8.invtype=18
left outer join ovpm vpm on vm8.docnum=vpm.docnum
where  T0.[DocDate] >= [%0] and T0.[DocDate] <= [%1] AND 
T0.[CANCELED]!='Y' and T0.[CANCELED]!='C'

) a
