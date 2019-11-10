USE NorthWindCvetnicSP
GO

CREATE TABLE	NorthWindCvetnicSP.dbo.dDatum
	(	sifDatum INT PRIMARY KEY, 
		datum DATE,
		tip VARCHAR(20) , -- datum, nepoznat, nije primjenjivo
		danMjGod CHAR(11), -- datum u dd-MM-yyyy formatu 
		dan VARCHAR(2), -- broj dana u mjesecu
		mjesec VARCHAR(2), --broj mjseseca u godini
		godina CHAR(4),  
		kvartal CHAR(1),-- 1, 2, 3, 4 kvartal
		rbrDanUTjednu CHAR(1),-- Ponedjeljak=1, Nedjelja=7
		nazDanUTjednu VARCHAR(12), --naziv dana
		nazMjesec VARCHAR(12), --naziv mjeseca
		oznRadniDan CHAR(2), --Da ili Ne
		oznZadnjiDanMjesec CHAR(2), --Da ili Ne
		sezona VARCHAR(10), --Proljeæe, Ljeto...
		dogaðaj VARCHAR(30), --Utakmica, Štrajk
		praznik CHAR(2), --Da, Ne
		nazPraznik VARCHAR(30), --Praznik rada
	)
GO

-- napuni tablicu
DECLARE @StartDate DATE = '01/01/2000'
DECLARE @EndDate DATE = '01/01/2021'

DECLARE @CurrentDate DATE = @StartDate

SET DATEFIRST 1; --prvi dan u tjednu je Ponedjljak 

WHILE	@CurrentDate < @EndDate
	BEGIN
		INSERT INTO dbo.dDatum
		(
			sifDatum, 
			datum,
			tip,
			danMjGod,
			dan,
			mjesec,
			godina,
			kvartal,
			rbrDanUTjednu,
			nazDanUTjednu,
			nazMjesec,
			oznRadniDan,
			oznZadnjiDanMjesec,
			sezona,
			dogaðaj,
			praznik,
			nazPraznik
		)
		VALUES
		(
			CAST(CONVERT(char(8), @CurrentDate, 112) AS INT), --pretvori datum u string 'yyyymmdd', pa iz stringa stvori broj
			@CurrentDate,
			'datum',
			CONVERT(char(11), @CurrentDate, 104),
			DATEPART(DD, @CurrentDate),
			DATEPART(MM, @CurrentDate),
			DATEPART(YY, @CurrentDate),
			DATEPART(QQ, @CurrentDate),
			DATEPART(DW, @CurrentDate),
			CASE DATEPART(DW, @CurrentDate)
				WHEN 1 THEN 'Ponedjeljak'
				WHEN 2 THEN 'Utorak'
				WHEN 3 THEN 'Srijeda'
				WHEN 4 THEN 'Èetvrak'
				WHEN 5 THEN 'Petak'
				WHEN 6 THEN 'Subota'
				WHEN 7 THEN 'Nedjelja'
			END,
			CASE DATEPART(MM, @CurrentDate)
				WHEN 1 THEN 'Sijeèanj'
				WHEN 2 THEN 'Veljaèa'
				WHEN 3 THEN 'Ožujak'
				WHEN 4 THEN 'Travanj'
				WHEN 5 THEN 'Svibanj'
				WHEN 6 THEN 'Lipanj'
				WHEN 7 THEN 'Srpanj'
				WHEN 8 THEN 'Kolovoz'
				WHEN 9 THEN 'Rujan'
				WHEN 10 THEN 'Listopad'
				WHEN 11 THEN 'Studeni'
				WHEN 12 THEN 'Prosinac'
			END,
			IIF(DATEPART(DW, @CurrentDate) BETWEEN 1 AND 5, 'Da', 'Ne'), --za sada su samo vikendi neradni, kroz UPDATE æe se postaviti i blagdani
			IIF(@CurrentDate = EOMONTH(@CurrentDate), 'Da', 'Ne'),
			CASE 
				WHEN @CurrentDate BETWEEN DATEFROMPARTS(DATEPART(YY, @CurrentDate),3,21) AND DATEFROMPARTS(DATEPART(YY, @CurrentDate),6,20)
					THEN 'Proljeæe'
				WHEN @CurrentDate BETWEEN DATEFROMPARTS(DATEPART(YY, @CurrentDate),6,21) AND DATEFROMPARTS(DATEPART(YY, @CurrentDate),9,22)
					THEN 'Ljeto'
				WHEN @CurrentDate BETWEEN DATEFROMPARTS(DATEPART(YY, @CurrentDate),9,23) AND DATEFROMPARTS(DATEPART(YY, @CurrentDate),12,20)
					THEN 'Jesen'
				WHEN (@CurrentDate BETWEEN DATEFROMPARTS(DATEPART(YY, @CurrentDate),1,1) AND DATEFROMPARTS(DATEPART(YY, @CurrentDate),3,20))
					 OR (@CurrentDate BETWEEN DATEFROMPARTS(DATEPART(YY, @CurrentDate),12,21) AND DATEFROMPARTS(DATEPART(YY, @CurrentDate),12,31))
					THEN 'Zima'
			END,
			'Ništa',
			'Ne',
			'Ništa'
			)
		SET @CurrentDate = DATEADD(DD, 1, @CurrentDate)
	END
GO

--update sa dogaðajima i praznicima
UPDATE dbo.dDatum
	SET nazPraznik = 'Nova godina',
		praznik = 'Da',
		oznRadniDan = 'Ne'
	WHERE mjesec = 1 AND dan = 1;

UPDATE dbo.dDatum
	SET nazPraznik = 'Sveta tri kralja',
		praznik = 'Da',
		oznRadniDan = 'Ne'
	WHERE mjesec = 1 AND dan = 6;

UPDATE dbo.dDatum
	SET dogaðaj = 'Valentinovo'
	WHERE mjesec = 2 AND dan = 14

UPDATE dbo.dDatum
	SET nazPraznik = 'Uskrs',
		praznik = 'Da',
		oznRadniDan = 'Ne'
	WHERE datum IN (
		'04/23/2000',
		'04/15/2001',
		'03/31/2002',
		'04/20/2003',
		'04/11/2004',
		'03/27/2005',
		'04/16/2006',
		'04/08/2007',
		'03/23/2008',
		'04/12/2009',
		'04/04/2010',
		'04/24/2011',
		'04/08/2012',
		'03/31/2013',
		'04/20/2014',
		'04/05/2015',
		'03/27/2016',
		'04/16/2017',
		'04/01/2018',
		'04/21/2019',
		'04/12/2020'
		);

GO

UPDATE dbo.dDatum
	SET nazPraznik = 'Uskršnji ponedjeljak',
		praznik = 'Da',
		oznRadniDan = 'Ne'
	WHERE datum IN (
			SELECT DATEADD(DD, 1, datum)
			FROM dbo.dDatum
			WHERE nazPraznik = 'Uskrs');

UPDATE dbo.dDatum
	SET nazPraznik = 'Praznik rada',
		praznik = 'Da',
		oznRadniDan = 'Ne'
	WHERE mjesec = 5 AND dan = 1

UPDATE dbo.dDatum
	SET nazPraznik = 'Tijelovo',
		praznik = 'Da',
		oznRadniDan = 'Ne'
	WHERE datum IN (
			SELECT DATEADD(DD, 60, datum)
			FROM dbo.dDatum
			WHERE nazPraznik = 'Uskrs');

UPDATE dbo.dDatum
	SET nazPraznik = 'Dan antifašitièke borbe',
		praznik = 'Da',
		oznRadniDan = 'Ne'
	WHERE mjesec = 6 AND dan = 22

UPDATE dbo.dDatum
	SET nazPraznik = 'Dan državnosti',
		praznik = 'Da',
		oznRadniDan = 'Ne'
	WHERE mjesec = 6 AND dan = 25

UPDATE dbo.dDatum
	SET nazPraznik = 'Dan domovinske zahvalnosti',
		praznik = 'Da',
		oznRadniDan = 'Ne'
	WHERE mjesec = 8 AND dan = 5

UPDATE dbo.dDatum
	SET nazPraznik = 'Velika gospa',
		praznik = 'Da',
		oznRadniDan = 'Ne'
	WHERE mjesec = 8 AND dan = 15

UPDATE dbo.dDatum
	SET nazPraznik = 'Dan nezavisnosti',
		praznik = 'Da',
		oznRadniDan = 'Ne'
	WHERE mjesec = 10 AND dan = 8

UPDATE dbo.dDatum
	SET nazPraznik = 'Dan svih svetih',
		praznik = 'Da',
		oznRadniDan = 'Ne'
	WHERE mjesec = 11 AND dan = 1

UPDATE dbo.dDatum
	SET nazPraznik = 'Božiæ',
		praznik = 'Da',
		oznRadniDan = 'Ne'
	WHERE mjesec = 12 AND dan = 25

UPDATE dbo.dDatum
	SET nazPraznik = 'Sveti Stjepan',
		praznik = 'Da',
		oznRadniDan = 'Ne'
	WHERE mjesec = 12 AND dan = 26

UPDATE dbo.dDatum
	SET dogaðaj = 'SP Rusija'
	WHERE datum BETWEEN '06/14/2018' AND '07/15/2018'


INSERT INTO dbo.dDatum (sifDatum, tip)
	VALUES
		(1000000000,'nepoznat'),
		(1000000001,'nije se još dogodilo')

GO