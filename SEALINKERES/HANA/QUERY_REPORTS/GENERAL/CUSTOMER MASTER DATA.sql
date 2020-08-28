SELECT T0."CardCode", T0."CardName", T0."CardType", T1."Name", T1."Tel1", T1."Cellolar", 
T2."Address", T2."Building", T2."Street", T2."Block", T2."City", T2."ZipCode", T2."Country", T2."State", T2."GSTRegnNo" 
FROM OCRD T0 INNER JOIN OCPR T1 ON T0."CardCode" = T1."CardCode" INNER JOIN CRD1 T2 ON T0."CardCode" = T2."CardCode";
