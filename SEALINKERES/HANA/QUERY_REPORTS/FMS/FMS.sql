------DELEVERY DATE ALERT
SELECT "DocNum" FROM ORDR t0 WHERE (CAST(ADD_DAYS(T0."DocDueDate", -1) AS varchar(50))) = CAST(NOW() AS varchar(50)) AND t0."DocStatus" = 'O';
----------Delivery Transporter
SELECT T0."U_Transporter" FROM OCRD T0 WHERE T0."CardCode" = $[ODLN.CardCode];
-----------Trasport invoice
SELECT T0."U_Transporter" FROM OCRD T0 WHERE T0."CardCode" = $[OINV.CardCode];
-----------Customer Ref Number
SELECT * from "@BPREFNO"
------Vendor Debit note 5% disc
SELECT ($[RPC1.U_Qty_Acptd.NUMBER] *0.05 )
