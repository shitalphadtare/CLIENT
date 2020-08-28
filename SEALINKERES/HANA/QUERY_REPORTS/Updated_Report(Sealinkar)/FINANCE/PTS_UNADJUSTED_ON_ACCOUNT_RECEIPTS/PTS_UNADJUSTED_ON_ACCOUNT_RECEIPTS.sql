Create view PTS_UNADJUSTED_ON_ACCOUNT_RECEIPTS as
SELECT T0."DocEntry", T0."DocNum", T0."DocDate", T0."TransId", T0."TaxDate", T0."CardCode", T0."CardName", T0."OpenBal" AS "Unadjusted Receipt", 
T0."CashSum", T0."CheckSum", T0."TrsfrSum", T0."TrsfrDate", T0."TrsfrRef" AS "Bank Transfer Ref", T0."PayNoDoc", 
T0."NoDocSum", T0."DocCurr", T0."DocRate", T0."DocTotal", T0."DocTotalFC", T0."Comments", T0."JrnlMemo", T1."LineID", T1."CheckNum" 
FROM ORCT T0 INNER JOIN RCT1 T1 ON T0."DocEntry" = T1."DocNum" 
WHERE T0."PayNoDoc" = 'Y' AND T0."OpenBal" <> 0