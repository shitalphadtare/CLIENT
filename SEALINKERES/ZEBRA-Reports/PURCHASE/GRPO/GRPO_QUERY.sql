
CREATE VIEW GOODS_RECEIPT_NOTE1
 AS
  SELECT
	 T1."DocEntry" ,
	 T1."DocNum" ,
	OCT."PymntGroup" "Payment Terms" ,
	T1."Comments" "Remarks" ,
	T2."SeriesName"||'/'||RTRIM(LTRIM(cast( T1."DocNum" AS char))) as "Invoice No" ,
	T1."DocDate" "Invoice date" ,
	T1."CardCode" ||' - '||T1."CardName" "Vendor Name Code" ,
	T1."Address" "Vendor Address" ,
	POR."DocNum" "Amendmend" ,
	POR."DocDate" "Amendmend Date" ,
	T1."NumAtCard" "QTN Ref No" ,
	T1."U_BPRefDt" "U_BpRefDate" ,
	T1."DocDueDate" "Delivery Date" ,
	T3."TrnspName" "DESPATCH MODE" ,
	PRQ."DocNum" "PR No" ,
	PRQ."DocDate" "PR Date" ,
	T1."Project" "Project Code" ,
	T1."U_OCNo" "OC No" ,
	T11."ItemCode" "ItemCode" ,
	'' "Make" ,
	'' "Model No" ,
	T11."Dscription" "Item description" ,
	T11."Quantity" "Quantity" ,
	T11."unitMsr" "UOM" ,
	T11."Price" "RATE" ,
	T11."DiscPrcnt" "Discount Percent" ,
	((T11."Quantity"*T11."PriceBefDi")-((T11."Quantity"*T11."PriceBefDi") * T11."DiscPrcnt"/100)) "TOTAL AMOUNT" ,
	T11."U_ItemDesc2" "Item Description 2" ,
	T11."U_ItemDesc3" "Item Description 3" ,
	T11."U_Qty_Acptd" "QuantityAccpt" ,
	T11."U_Qty_Rejtd" "QuantityReject", 
	(((T11."Quantity"*T11."PriceBefDi") * T11."DiscPrcnt"/100) + (T11."LineTotal" *T1."DiscPrcnt"/100)) "Item Discount" ,
	((T11."Quantity"*T11."PriceBefDi") - (((T11."Quantity"*T11."PriceBefDi") * T11."DiscPrcnt"/100) + 
	(T11."LineTotal"*T1."DiscPrcnt"/100))) "Item Total After Discount" ,
	(CASE when t1."DocCur" = 'INR' 
	then IFNULL(t1."DiscSum",	0) 
	else IFNULL(t1."DiscSumFC",
	0) 
	end ) "Doclvl discount" ,
	T1."U_Terms_Pay" "U_Terms_Pay" ,
	T1."U_Terms_Del" "U_Terms_Del" ,
	--T1."U_Terms_Scope" "U_Terms_Scope" ,
	T3."TrnspName" "Shipping type" ,
	'' "U_Terms_Spec" ,
	'' "U_Terms_Clari" ,
	'' "U_Terms_STC" ,
	T1."TotalExpns" "freight" ,
	T1."RoundDif" as "Round Diff" ,
	((T11."Quantity"*T11."PriceBefDi") * T11."DiscPrcnt"/100) "disc" ------------------------------------------------------------------------------------------------------------------------------
,
	OC."Name" "CNTACT PERSON" ,
	OC."E_MailL" "Cntct Prsn Email " ,
	 CASE WHEN OC."Tel1" = '' 
OR OC."Tel1" IS NULL 
THEN (CASE WHEN OC."Tel2" = '' 
	OR OC."Tel2" IS NULL 
	THEN OC."Cellolar" 
	ELSE OC."Tel2" 
	END) 
ELSE OC."Tel1" 
END "CNTCT PRSN PHN NO" ,
	'' "Vendor Ref Date" ,
	(case when T6."PrjName" is null 
	then T6."PrjName" 
	else '('||T6."PrjName"||')' 
	end) "Project Name" ,
	olc."Street" "Street" ,
	'' "Street No" ,
	OLC."Block" "Block" ,
	OLC."Building" "Building" ,
	OLC."Location" "Location" ,
	OLC."City" "City" ,
	OLC."PanNo" "Location PAN_NO" ,
	OLC."ZipCode" "Zipcode" ,
	
	OCR."Name" "cOUNTRY" ,
	OCS."Name" "STATE" ,
	(CASE WHEN T1."DocCur" = 'INR' 
	THEN T1."DocTotal" 
	ELSE T1."DocTotalFC" 
	END) AS "Grand Total" ,
	case when s1."SlpName" = '-No Sales Employee-' 
then '' 
else s1."SlpName" 
end as "Sales Person" ,
	s1."SlpName" "our Contact" ,
	s1."Mobil" "Our contact Telephone" ,
	T1."Address2" "Deliver to Address" ,
	'' "Billing Address Option" ,
	OH."firstName" || ' ' ||OH."lastName" "Owner Name" ,
	OCRN."CurrName" AS "Currencyname" ,
	OCRN."F100Name" AS "Hundredthname" ,
	T1."Header" 
"OPENING REMARKS" ,
	 T1."Footer" "CLOSING REMARKS" ,
	T1."DocCur" "Docur" ,
	(case when T1."DocCur"='INR' 
	then T1."DiscSum" 
	else T1."DiscSumFC" 
	end)"Discount" ,
	"vendorShipFrom"."Street" "Street_Vendor" ,
	"vendorShipFrom"."StreetNo" "Street No_Vendor" ,
	"vendorShipFrom"."Block" "Block_Vendor" ,
	"vendorShipFrom"."Building" "Building_Vendor" ,
	"vendorShipFrom"."City" "City_Vendor" ,
	"vendorShipFrom"."ZipCode" "Zipcode_Vendor" ,
	(select
	 distinct "Name" 
	from ocry 
	where "Code"="vendorShipFrom"."Country") "cOUNTRY_Vendor" ,
	(select
	 distinct "Name" 
	from ocst 
	where "Code"="vendorShipFrom"."State" 
	and "vendorShipFrom"."Country"=Ocst."Country") "STATE_Vendor" ,
	(Case when T1."DocCur" = 'INR' 
	then (case when T11."DiscPrcnt">0 
		then (T11."Quantity"*T11."PriceBefDi")*T11."DiscPrcnt"/100 
		else 0 
		end)
	else (case when T11."DiscPrcnt">0 
		then (T11."Quantity"*T11."PriceBefDi")*T11."DiscPrcnt"/100 
		else 0 
		end) 
	end) "Discount Amount_Line" ,
	(case when T1."DocType"='I' 
	then(case when T11."AssblValue">0 
		then IFNULL( T11."AssblValue"*T11."Quantity",
	0) 
		else IFNULL(T11."Quantity"*T11."PriceBefDi",
	0) 
		end) 
	else ((case when T1."DocCur"='INR' 
			then T11."LineTotal" 
			else T11."TotalFrgn" 
			end)) 
	end)"Taxable Value" ,
	OLC."Location" "Whscode" ,
	IT1."Quantity" "BatchQ" ,
	IT1."BatchNum" ,
	BTN."MnfDate" ,
	BTN."ExpDate" ,
	T11."VisOrder"
	
FROM OPDN T1 
INNER JOIN PDN1 T11 ON T1."DocEntry" = T11."DocEntry" 
left outer join POR1 PR1 on T11."BaseEntry"=PR1."DocEntry" 
and T11."BaseLine"=PR1."LineNum" 
left outer join opor POR On POR."DocEntry"=PR1."DocEntry" 
left outer join prq1 PQ1 on PR1."BaseEntry"=PQ1."DocEntry" 
and PR1."BaseLine"=PQ1."LineNum" 
left outer join OPRQ PRQ On PRQ."DocEntry"=PQ1."DocEntry" 
LEFT OUTER JOIN OITM AS ITM ON ITM."ItemCode" = T11."ItemCode" 
left outer join OCRD d1 on d1."CardCode"=T1."CardCode" 
left outer join (select
	 * 
	from CRD1 ) "vendorShipFrom" on "vendorShipFrom"."Address" =T1."ShipToCode" 
and "vendorShipFrom"."CardCode"=T1."CardCode" 
and "vendorShipFrom"."AdresType"='S' 
LEFT OUTER JOIN (SELECT
	 "CardCode",
	 "Address",
	 "TaxId0",
	 "TaxId1",
	 "TaxId2",
	 "TaxId3",
	 "TaxId4",
	 "TaxId5",
	 "TaxId6",
	 "TaxId7",
	 "TaxId8",
	 "TaxId9",
	 "CNAEId",
	 "TaxId10",
	 "TaxId11" ,
	 "AddrType",
	 "ECCNo",
	 "CERegNo" ,
	 "CERange" ,
	 "CEDivis",
	 "CEComRate" ,
	 "LogInstanc" ,
	 "SefazDate" ,
	 "TaxId12" ,
	 "TaxId13" 
	FROM CRD7 AS "CRD7_1" 
	WHERE("AddrType" = 'S') ) AS "Crd7" ON T1."CardCode" = "Crd7"."CardCode" 
AND "Crd7"."Address" = case when T1."ShipToCode" is null 
or T1."ShipToCode" = '' 
then '' 
else T1."ShipToCode" 
end 
INNER JOIN PDN12 AS PR12 ON T1."DocEntry" = PR12."DocEntry" 
LEFT OUTER JOIN OCPR AS OC ON T1."CardCode" = OC."CardCode" 
AND T1."CntctCode" = OC."CntctCode" 
LEFT outer JOIN NNM1 T2 ON T1."Series" = T2."Series" 
LEFT OUTER JOIN OSHP T3 ON T3."TrnspCode" = T1."TrnspCode" 
LEFT OUTER JOIN PRQ1 AS T4 ON T4."DocEntry" = T11."BaseEntry" 
AND T11."BaseLine" = T4."LineNum" 
LEFT OUTER JOIN OPRQ AS T5 ON T5."DocEntry" = T4."DocEntry" 
LEFT OUTER JOIN OCTG OCT ON T1."GroupNum" = OCT."GroupNum" 
LEFT OUTER JOIN OWHS OW ON T11."WhsCode" = OW."WhsCode" 
LEFT OUTER JOIN OLCT OLC ON OLC."Code" = T11."LocCode" 
LEFT OUTER JOIN OCRY OCR ON OLC."Country" = OCR."Code" 
LEFT OUTER JOIN OCST OCS ON OLC."State" = OCS."Code" 
AND OLC."Country" = OCS."Country" 
INNER JOIN OSLP as S1 on T1."SlpCode" = S1."SlpCode" 
LEFT OUTER JOIN OHEM AS OH ON OH."empID" = T1."OwnerCode" 
LEFT OUTER JOIN OCRN ON T1."DocCur" = OCRN."CurrCode" 
LEFT OUTER JOIN PDN4 as r4 on T1."DocEntry" = r4."DocEntry" 
AND T11."LineNum" = r4."LineNum" 
AND r4."staType" IN (1,
	 4) 
and R4."RelateType" IN (1) 
LEFT OUTER JOIN PDN4 as r5 on T1."DocEntry" = r5."DocEntry" 
AND T11."LineNum" = r5."LineNum" 
AND r5."staType" IN (7) 
and R5."RelateType" =1 
LEFT OUTER JOIN PDN4 as r6 on T1."DocEntry" = r6."DocEntry" 
AND T11."LineNum" = r6."LineNum" 
AND r6."staType" IN (5) 
and R6."RelateType" =1 ------------DocLevelFreight------------

LEFT OUTER JOIN ( select
	 * 
	from PDN3 as Q3 
	where Q3."ExpnsCode" in('1') ) as "Frght" on T1."DocEntry" = "Frght"."DocEntry" 
LEFT OUTER JOIN ( select
	 * 
	from PDN3 as Q31 
	where Q31."ExpnsCode" in('2')) as "Insurance" on T1."DocEntry" = "Insurance"."DocEntry" 
LEFT OUTER JOIN ( select
	 * 
	from PDN3 as Q32 
	where Q32."ExpnsCode" in('4')) as "Packing" on T1."DocEntry" = "Packing"."DocEntry" 
LEFT OUTER JOIN ( select
	 * 
	from PDN3 as Q33 
	where Q33."ExpnsCode" in ('3')) as "Octroi" on T1."DocEntry" = "Octroi"."DocEntry" 
LEFT OUTER JOIN ( select
	 * 
	from PDN3 as Q34 
	where Q34."ExpnsCode" in('12',
	'13')) as "Courier" on T1."DocEntry" = "Courier"."DocEntry" 
LEFT OUTER JOIN ( select
	 * 
	from PDN3 as Q35 
	where Q35."ExpnsCode" in ('6')) as "f6" on T1."DocEntry" = "f6"."DocEntry" 
LEFT OUTER JOIN ( select
	 * 
	from PDN3 as Q36 
	where Q36."ExpnsCode" in('40')) as "f7" on T1."DocEntry" = "f7"."DocEntry" 
LEFT OUTER JOIN OPRJ AS T6 ON T6."PrjCode" = T1."Project" ------ItemLevel Freight------------

LEFT OUTER JOIN ( select
	 "DocEntry" ,
	"ExpnsCode",
	SUM("LineTotal" ) "FrghtI",
	SUM("TotalFrgn") "FrghtF" 
	from PDN2 as Q3 
	where Q3."ExpnsCode" in('1') 
	group by "DocEntry",
	"ExpnsCode") as "FrghtI" on T1."DocEntry" = "FrghtI"."DocEntry" --AND T11.LineNum="FrghtI".LineNum 

LEFT OUTER JOIN ( select
	 "DocEntry" ,
	"ExpnsCode",
	SUM("LineTotal" ) "InsuranceI",
	SUM("TotalFrgn") "InsuranceF" 
	from PDN2 as Q31 
	where Q31."ExpnsCode" in('2') 
	group by "DocEntry",
	"ExpnsCode") as "InsuranceI" on T1."DocEntry" = "InsuranceI"."DocEntry" 
LEFT OUTER JOIN ( select
	 "DocEntry" ,
	"ExpnsCode",
	SUM("LineTotal" ) "PackingI",
	SUM("TotalFrgn") "PackingF" 
	from PDN2 as Q32 
	where Q32."ExpnsCode" in('4') 
	group by "DocEntry",
	"ExpnsCode") as "PackingI" on T1."DocEntry" = "PackingI"."DocEntry" 
LEFT OUTER JOIN ( select
	 "DocEntry" ,
	"ExpnsCode",
	SUM("LineTotal" ) "OctroiI",
	SUM("TotalFrgn") "OctroiF" 
	from PDN2 as Q33 
	where Q33."ExpnsCode" in ('3')
	group by "DocEntry",
	"ExpnsCode") as "OctroiI" on T1."DocEntry" = "OctroiI"."DocEntry" 
LEFT OUTER JOIN ( select
	 "DocEntry" ,
	"ExpnsCode",
	SUM("LineTotal" ) "CourierI",
	SUM("TotalFrgn") "CourierF" 
	from PDN2 as Q34 
	where Q34."ExpnsCode" in('12',
	'13') 
	group by "DocEntry",
	"ExpnsCode") as "CourierI" on T1."DocEntry" = "CourierI"."DocEntry" 
LEFT OUTER JOIN ( select
	 "DocEntry" ,
	"ExpnsCode",
	SUM("LineTotal" ) "f6I",
	SUM("TotalFrgn") "f6F" 
	from PDN2 as Q35 
	where Q35."ExpnsCode" in('6')
	group by "DocEntry",
	"ExpnsCode") as "f6I" on T1."DocEntry" = "f6I"."DocEntry" 
LEFT OUTER JOIN ( select
	 "DocEntry" ,
	"ExpnsCode",
	SUM("LineTotal" ) "f7I",
	SUM("TotalFrgn") "f7F" 
	from PDN2 as Q36 
	where Q36."ExpnsCode" in('40') 
	group by "DocEntry",
	"ExpnsCode") as "f7I" on T1."DocEntry" = "f7I"."DocEntry" ------------for GST item tax calculation ------------

LEFT OUTER JOIN PDN4 as cgst on T1."DocEntry" = cgst."DocEntry" 
AND T11."LineNum" = cgst."LineNum" 
AND cgst."staType" IN (-100) 
and cgst."RelateType" =1 
LEFT OUTER JOIN PDN4 as sgst on T1."DocEntry" = sgst."DocEntry" 
AND T11."LineNum" = sgst."LineNum" 
AND sgst."staType" IN (-110) 
and sgst."RelateType" =1 
LEFT OUTER JOIN PDN4 as igst on T1."DocEntry" = igst."DocEntry" 
AND T11."LineNum" = igst."LineNum" 
AND igst."staType" IN (-120) 
and igst."RelateType" =1 ----------------for Freight GST Tax Calculation ---------------
---Freigt (f1)---------------------

LEFT OUTER JOIN (select
	 "DocEntry" ,
	"TaxRate" ,
	sum("TaxSum") "TaxSum",
	sum("TaxSumFrgn")"TaxSumtF",
	"staType" 
	from PDN4 
	where "ExpnsCode" in('1') 
	and "staType" IN (-100) 
	group by "DocEntry" ,
	"TaxRate" ,
	"staType" ) "Frgcgst" on T1."DocEntry" = "Frgcgst"."DocEntry" 
LEFT OUTER JOIN (select
	 "DocEntry" ,
	"TaxRate" ,
	sum("TaxSum") "TaxSum",
	sum("TaxSumFrgn")"TaxSumtF",
	"staType" 
	from PDN4 
	where "ExpnsCode" in('1') 
	and "staType" IN (-110) 
	group by "DocEntry" ,
	"TaxRate" ,
	"staType") "Frgsgst" on T1."DocEntry" = "Frgsgst"."DocEntry" 
LEFT OUTER JOIN (select
	 "DocEntry" ,
	"TaxRate" ,
	sum("TaxSum") "TaxSum",
	sum("TaxSumFrgn")"TaxSumtF",
	"staType" 
	from PDN4 
	where "ExpnsCode" in('1') 
	and "staType" IN (-120) 
	group by "DocEntry" ,
	"TaxRate" ,
	"staType") "Frgigst" on T1."DocEntry" = "Frgigst"."DocEntry" ----------Insurance (f2)----------

LEFT OUTER JOIN (select
	 "DocEntry" ,
	"TaxRate" ,
	sum("TaxSum") "TaxSum",
	sum("TaxSumFrgn")"TaxSumtF",
	"staType" 
	from PDN4 
	where "ExpnsCode" in('2') 
	and "staType" IN (-100) 
	group by "DocEntry" ,
	"TaxRate" ,
	"staType") "Inscgst" on T1."DocEntry" = "Inscgst"."DocEntry" 
LEFT OUTER JOIN (select
	 "DocEntry" ,
	"TaxRate" ,
	sum("TaxSum") "TaxSum",
	sum("TaxSumFrgn")"TaxSumtF",
	"staType" 
	from PDN4 
	where "ExpnsCode" in('2') 
	and "staType" IN (-110) 
	group by "DocEntry" ,
	"TaxRate" ,
	"staType") "Inssgst" on T1."DocEntry" = "Inssgst"."DocEntry" 
LEFT OUTER JOIN (select
	 "DocEntry" ,
	"TaxRate" ,
	sum("TaxSum") "TaxSum",
	sum("TaxSumFrgn")"TaxSumtF",
	"staType" 
	from PDN4 
	where "ExpnsCode" in('2') 
	and "staType" IN (-120) 
	group by "DocEntry" ,
	"TaxRate" ,
	"staType") "Insigst" on T1."DocEntry" = "Insigst"."DocEntry" ----------P & F (f3)----------

LEFT OUTER JOIN (select
	 "DocEntry" ,
	"TaxRate" ,
	sum("TaxSum") "TaxSum",
	sum("TaxSumFrgn")"TaxSumtF",
	"staType" 
	from PDN4 
	where "ExpnsCode" in('4') 
	and "staType" IN (-100) 
	group by "DocEntry" ,
	"TaxRate" ,
	"staType") "PFcgst" on T1."DocEntry" = "PFcgst"."DocEntry" 
LEFT OUTER JOIN (select
	 "DocEntry" ,
	"TaxRate" ,
	sum("TaxSum") "TaxSum",
	sum("TaxSumFrgn")"TaxSumtF",
	"staType" 
	from PDN4 
	where "ExpnsCode" in('4') 
	and "staType" IN (-110) 
	group by "DocEntry" ,
	"TaxRate" ,
	"staType") "PFsgst" on T1."DocEntry" = "PFsgst"."DocEntry" 
LEFT OUTER JOIN (select
	 "DocEntry" ,
	"TaxRate" ,
	sum("TaxSum") "TaxSum",
	sum("TaxSumFrgn")"TaxSumtF",
	"staType" 
	from PDN4 
	where "ExpnsCode" in('4') 
	and "staType" IN (-120) 
	group by "DocEntry" ,
	"TaxRate" ,
	"staType") "PFigst" on T1."DocEntry" = "PFigst"."DocEntry" ----------------Octroi (f4)-----------------

LEFT OUTER JOIN (select
	 "DocEntry" ,
	"TaxRate" ,
	sum("TaxSum") "TaxSum",
	sum("TaxSumFrgn")"TaxSumtF",
	"staType" 
	from PDN4 
	where "ExpnsCode" in('3') 
	and "staType" IN (-100) 
	group by "DocEntry" ,
	"TaxRate" ,
	"staType") "Octcgst" on T1."DocEntry" = "Octcgst"."DocEntry" 
LEFT OUTER JOIN (select
	 "DocEntry" ,
	"TaxRate" ,
	sum("TaxSum") "TaxSum",
	sum("TaxSumFrgn")"TaxSumtF",
	"staType" 
	from PDN4 
	where "ExpnsCode" in('3') 
	and "staType" IN (-110) 
	group by "DocEntry" ,
	"TaxRate" ,
	"staType") "Octsgst" on T1."DocEntry" = "Octsgst"."DocEntry" 
LEFT OUTER JOIN (select
	 "DocEntry" ,
	"TaxRate" ,
	sum("TaxSum") "TaxSum",
	sum("TaxSumFrgn")"TaxSumtF",
	"staType" 
	from PDN4 
	where "ExpnsCode" in('3') 
	and "staType" IN (-120) 
	group by "DocEntry" ,
	"TaxRate" ,
	"staType") "Octigst" on T1."DocEntry" = "Octigst"."DocEntry" ----------------Courier (f5)-----------------

LEFT OUTER JOIN (select
	 "DocEntry" ,
	"TaxRate" ,
	sum("TaxSum") "TaxSum",
	sum("TaxSumFrgn")"TaxSumtF",
	"staType" 
	from PDN4 
	where "ExpnsCode" in('12',
	'13') 
	and "staType" IN (-100) 
	group by "DocEntry" ,
	"TaxRate" ,
	"staType") "Coucgst" on T1."DocEntry" = "Coucgst"."DocEntry" 
LEFT OUTER JOIN (select
	 "DocEntry" ,
	"TaxRate" ,
	sum("TaxSum") "TaxSum",
	sum("TaxSumFrgn")"TaxSumtF",
	"staType" 
	from PDN4 
	where "ExpnsCode" in('12',
	'13') 
	and "staType" IN (-110) 
	group by "DocEntry" ,
	"TaxRate" ,
	"staType") "Cousgst" on T1."DocEntry" = "Cousgst"."DocEntry" 
LEFT OUTER JOIN (select
	 "DocEntry" ,
	"TaxRate" ,
	sum("TaxSum") "TaxSum",
	sum("TaxSumFrgn")"TaxSumtF",
	"staType" 
	from PDN4 
	where "ExpnsCode" in('12',
	'13') 
	and "staType" IN (-120) 
	group by "DocEntry" ,
	"TaxRate" ,
	"staType") "Couigst" on T1."DocEntry" = "Couigst"."DocEntry" ---------------------------(f6)----------
 
LEFT OUTER JOIN (select
	 "DocEntry" ,
	"TaxRate" ,
	sum("TaxSum") "TaxSum",
	sum("TaxSumFrgn")"TaxSumtF",
	"staType" 
	from PDN4 
	where "ExpnsCode" in('6') 
	and "staType" IN (-100) 
	group by "DocEntry" ,
	"TaxRate" ,
	"staType") "f6cgst" on T1."DocEntry" = "f6cgst"."DocEntry" 
LEFT OUTER JOIN (select
	 "DocEntry" ,
	"TaxRate" ,
	sum("TaxSum") "TaxSum",
	sum("TaxSumFrgn")"TaxSumtF",
	"staType" 
	from PDN4 
	where "ExpnsCode" in('6') 
	and "staType" IN (-110) 
	group by "DocEntry" ,
	"TaxRate" ,
	"staType") "f6sgst" on T1."DocEntry" = "f6sgst"."DocEntry" 
LEFT OUTER JOIN (select
	 "DocEntry" ,
	"TaxRate" ,
	sum("TaxSum") "TaxSum",
	sum("TaxSumFrgn")"TaxSumtF",
	"staType" 
	from PDN4 
	where "ExpnsCode" in('6') 
	and "staType" IN (-120) 
	group by "DocEntry" ,
	"TaxRate" ,
	"staType") "f6igst" on T1."DocEntry" = "f6igst"."DocEntry" -------(f7) -----------

LEFT OUTER JOIN (select
	 "DocEntry" ,
	"TaxRate" ,
	sum("TaxSum") "TaxSum",
	sum("TaxSumFrgn")"TaxSumtF",
	"staType" 
	from PDN4 
	where "ExpnsCode" in('40') 
	and "staType" IN (-100) 
	group by "DocEntry" ,
	"TaxRate" ,
	"staType") "f7cgst" on T1."DocEntry" = "f7cgst"."DocEntry" 
LEFT OUTER JOIN (select
	 "DocEntry" ,
	"TaxRate" ,
	sum("TaxSum") "TaxSum",
	sum("TaxSumFrgn")"TaxSumtF",
	"staType" 
	from PDN4 
	where "ExpnsCode" in('40') 
	and "staType" IN (-110) 
	group by "DocEntry" ,
	"TaxRate" ,
	"staType") "f7sgst" on T1."DocEntry" ="f7sgst"."DocEntry" 
LEFT OUTER JOIN (select
	 "DocEntry" ,
	"TaxRate" ,
	sum("TaxSum") "TaxSum",
	sum("TaxSumFrgn")"TaxSumtF",
	"staType" 
	from PDN4 
	where "ExpnsCode" in('40') 
	and "staType" IN (-120) 
	group by "DocEntry" ,
	"TaxRate" ,
	"staType") "f7igst" on T1."DocEntry" = "f7igst"."DocEntry" 
LEFT OUTER JOIN IBT1 IT1 ON T1."DocEntry" = IT1."BaseEntry" 
AND IT1."ItemCode" = T11."ItemCode" 
AND IT1."BaseLinNum"=T11."LineNum" 
left outer join OBTN BTN on BTN."ItemCode"=IT1."ItemCode" 
and BTN."DistNumber"=IT1."BatchNum"


--GO


