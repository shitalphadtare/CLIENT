create procedure TEMP2 
(in dockey int)
LANGUAGE SQLSCRIPT
AS
Val1 INT;
Val2 INT;
QTY INT;
QTY1 INT;
begin
Val1 := 1;

(SELECT COUNT("VisOrder") into QTY FROM DLN1 WHERE "DocEntry"=dockey);
create global temporary table "SPL_TESTH"."tab1" (SiteValue INT,DocKey INT,VISORDER int);
truncate table "SPL_TESTH"."tab1";
 

WHILE (Val1 <= QTY)
do
	BEGIN
		Val2 :=1 ;
		(SELECT SUM("Quantity") into QTY1  FROM DLN1 WHERE "DocEntry"=dockey AND "VisOrder"=(Val1-1));
		WHILE Val2 <= QTY1
		do
			BEGIN
				--PRINT VAL2;
				--PRINT VAL1-1;
				
				 Val2 := Val2 + 1;
				INSERT INTO "SPL_TESTH"."tab1" VALUES(VAL2-1,dockey,VAL1-1);
			END;
			END WHILE;
		Val1 := Val1 + 1;
	END ;
	END WHILE;
	SELECT * FROM "tab1" WHERE dockey=dockey;
	drop table "tab1";
	END;