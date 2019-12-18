USE NorthWindCvetnicSP
GO

/*
DROP TABLE NorthWindCvetnicSP.dbo.dVrijemeDan
GO
*/

CREATE TABLE NorthWindCvetnicSP.dbo.dVrijemeDan
	(	sifVrijemeDan INT PRIMARY KEY, 
		tip VARCHAR(20), -- noramalan, nepoznato, nije se jo� dogodilo ...
		sekundePonoc INT, -- broj prije�enih sekundi od pono�i 
		minutePonoc INT, -- broj prije�enih minuta od pono�i
		vrijeme TIME(0), --broj mjseseca u godini
		sekunda INT, -- broj prije�enih sekunda u trenutnoj minuti
		minuta INT, -- broj prije�enih minuta u trenutnom satu
		sat INT, -- broj prije�enih sati u danu
		period VARCHAR(20) --no�, prijepodne, poslijepodne, ... 
	)
GO

-- napuni tablicu
DECLARE @StartTime TIME(0) = '00:00:00'
DECLARE @EndTime TIME(0) = '23:59:59'
DECLARE @lastSecond BIT = 0

DECLARE @CurrentTime TIME(0) = @StartTime

WHILE	((@CurrentTime <= @EndTime) AND (@lastSecond = 0))
	BEGIN

		IF @CurrentTime = @EndTime
			BEGIN
				SET @lastSecond = 1
			END

		INSERT INTO dbo.dVrijemeDan
			(
				sifVrijemeDan,
				tip,
				sekundePonoc,
				minutePonoc,
				vrijeme, 
				sekunda, 
				minuta, 
				sat,
				period
			)
			VALUES
			(
				DATEDIFF(ss, 0, @CurrentTime),
				'normalan',
				DATEDIFF(ss, 0, @CurrentTime),
				DATEDIFF(mi, 0, @CurrentTime),
				@CurrentTime,
				DATEPART(ss, @CurrentTime),
				DATEPART(mi, @CurrentTime),
				DATEPART(hh, @CurrentTime),
				CASE
					WHEN (@CurrentTime BETWEEN '00:00:00' AND '06:30:00') 
						OR (@CurrentTime BETWEEN '20:00:01' AND '23:59:59')
						THEN 'No�'
					WHEN (@CurrentTime BETWEEN '18:00:01' AND '20:00:00')
						THEN 'Ve�er'
					WHEN (@CurrentTime BETWEEN '06:30:01' AND '08:30:00')
						THEN 'Jutro'
					WHEN (@CurrentTime BETWEEN '08:30:01' AND '12:00:00')
						THEN 'Prije podne'
					WHEN (@CurrentTime BETWEEN '12:00:01' AND '18:00:00')
						THEN 'Poslije podne'
				END
			)

		SET @CurrentTime = DATEADD(ss, 1, @CurrentTime)

	END


INSERT INTO dbo.dVrijemeDan (sifVrijemeDan, tip, period)
	VALUES
		(DATEDIFF(ss, 0, @EndTime) + 1,'nepoznat', 'nepoznat'),
		(DATEDIFF(ss, 0, @EndTime) + 2,'nije se jo� dogodilo', 'nepoznat')
