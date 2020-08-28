SELECT T0."CardCode", T0."CardName", T0."CntctPrsn", T0."Phone1", T0."Cellular", T1."Address", T1."Block", T1."Building", T1."Street", 
T1."City", T1."ZipCode", T1."State", T1."Country", T1."GSTRegnNo" 
FROM OCRD T0 
INNER JOIN CRD1 T1 ON T0."CardCode" = T1."CardCode"
 WHERE T0."CardType" = 'C' AND T1."AdresType" = 'B'