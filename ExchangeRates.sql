
/*
Procedure	:	dbo.sp_ExchangeRates
Create Date	:	2021.06.23
Author		:	Uğur Yıldız
Description	:	Returns the Turkish Lira exchange rate values ​​according to the given date.
Parameter(s):	@Date					:	The date of the exchange rate you want to receive
				@ErrorStatus			:	If 0 is given, it gives an error if there is no data. If 1 is given, empty record is returned if there is no data.
Usage		:	DECLARE @CurrencyDate date = GETDATE()
				EXEC dbo.sp_ExchangeRates @Date = @CurrencyDate, @ErrorStatus = 0
Dependencies:	
				sp_configure 'show advanced options', 1;
				GO
				RECONFIGURE;
				GO
				sp_configure 'Ole Automation Procedures', 1;
				GO
				RECONFIGURE;
				GO
*/

CREATE PROCEDURE sp_ExchangeRates 
@Date date,
@ErrorStatus float 
AS
BEGIN

			DECLARE @XMLTables TABLE (XMLColumn XML)
			DECLARE @URL VARCHAR(8000);
			DECLARE @Obj INT;
			DECLARE @Result INT;
			DECLARE @HTTPStatus INT;
			DECLARE @XMLTable XML;

			SET @URL = 'https://www.tcmb.gov.tr/kurlar/'+CAST(YEAR(@Date) AS VARCHAR(10))+CAST(FORMAT(@Date,'MM') AS VARCHAR(10))+'/'+CAST(DAY(@Date) AS VARCHAR(10))+CAST(FORMAT(@Date,'MM') AS VARCHAR(10))+CAST(YEAR(@Date) AS VARCHAR(10))+'.xml';
			
			EXEC @Result = sp_OACreate 'MSXML2.XMLHttp', @Obj OUT;
			EXEC @Result = sp_OAMethod @Obj, 'open', NULL, 'GET', @URL, false;
			EXEC @Result = sp_OAMethod @Obj,
									   'setRequestHeader',
									   NULL,
									   'Content-Type',
									   'application/x-www-form-urlencoded';
			EXEC @Result = sp_OAMethod @Obj, send, NULL, '';
			EXEC @Result = sp_OAGetProperty @Obj, 'status', @HTTPStatus OUT;
			insert into @XMLTables 
			EXEC @Result = sp_OAGetProperty @Obj, 'responseXML.xml'; 
			set @XMLTable = (select * from @XMLTables)

			IF @XMLTable IS NULL AND @ErrorStatus =0 BEGIN
				DECLARE @ErrorMessage VARCHAR(250) = 'The exchange rate information for the date '+CONVERT(varchar(15),@Date,104)+' could not be accessed.'
				RAISERROR (@ErrorMessage,10,1)
				RETURN 0
			END
			
			ELSE BEGIN
				SELECT Currency.value('Unit[1]','varchar(100)') as Unit,
				Currency.value('Isim[1]','varchar(100)') as CurrencyNameTR,
				Currency.value('CurrencyName[1]','varchar(100)') as CurrencyName,
				Currency.value('ForexBuying[1]','varchar(100)') as ForexBuying,
				Currency.value('ForexSelling[1]','varchar(100)') as ForexSelling,
				Currency.value('BanknoteBuying[1]','varchar(100)') as BanknoteBuying,
				Currency.value('BanknoteSelling[1]','varchar(100)') as BanknoteSelling,
				Currency.value('CrossRateUSD[1]','varchar(100)') as CrossRateUSD,
				Currency.value('CrossRateOther[1]','varchar(100)') as CrossRateOther
				FROM @XMLTable.nodes('/Tarih_Date/Currency') as Tarih_Date(Currency)
			END
			

END





