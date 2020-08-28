
create proc [dbo].[TEMP2] (@dockey int)
as 

bEGIN

DECLARE @Val1 INT,
	@Val2 INT
SET @Val1 = 1

IF object_id('tempdb..#tab1') IS NOT NULL
BEGIN
   DROP TABLE #tab1
END
 
CREATE TABLE #tab1
(SiteValue INT,DocKey INT,VISORDER int
)
 

WHILE @Val1 <= (SELECT COUNT("VisOrder") FROM DLN1 WHERE "DocEntry"=@dockey)
	BEGIN
		SET @Val2 =1 
		WHILE @Val2 <= (SELECT SUM("Quantity") FROM DLN1 WHERE "DocEntry"=@dockey AND "VisOrder"=@Val1-1)
			BEGIN
				PRINT @VAL2
				PRINT @VAL1-1
				
				SET @Val2 = @Val2 + 1
				INSERT INTO #tab1 VALUES(@VAL2-1,@dockey,@VAL1-1)
			END
		SET @Val1 = @Val1 + 1
	END
	SELECT * FROM #tab1 wHERE @dockey=@dockey
	END
	--EXEC TEMP2 1
--	select SUM(Quantity) from DLN1 where DocEntry=1
GO


