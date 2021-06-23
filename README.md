# Exchange Rates T-SQL

Procedure	:	dbo.sp_ExchangeRates
Create Date	:	2021.06.23
Author		:	Uğur Yıldız
Description	:	Returns the Turkish Lira exchange rate values ​​according to the given date.
Parameter(s):		@Date					:	The date of the exchange rate you want to receive
			@ErrorStatus				:	If 0 is given, it gives an error if there is no data. If 1 is given, empty record is returned if there is no data.
Usage		:	DECLARE @CurrencyDate date = GETDATE()
				EXEC dbo.sp_ExchangeRates @Date = @CurrencyDate, @ErrorStatus = 0
Dependencies:	Ole Automation:
					sp_configure 'show advanced options', 1;
					GO
					RECONFIGURE;
					GO
					sp_configure 'Ole Automation Procedures', 1;
					GO
					RECONFIGURE;
					GO
