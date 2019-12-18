USE NorthWindCvetnicSP
GO

  --- DROP TABLES:
/*
USE NorthWindCvetnicSP
GO
DROP  TABLE tabAtributAgrFun 
DROP  TABLE dimCinj 
DROP  TABLE tabAtribut 
DROP  TABLE tipAtrib 
DROP  TABLE tablica 
DROP  TABLE tipTablica 
DROP  TABLE agrFun 

DROP VIEW dOrderDate 
DROP VIEW dRequriedDate 
DROP VIEW dShippedDate
DROP VIEW dOrderTime 
DROP VIEW dRequriedTime 
DROP VIEW dShippedTime 
*/

CREATE TABLE tipTablica (
    sifTipTablica TINYINT CONSTRAINT pkTipTablica PRIMARY KEY 
  , nazTipTablica CHAR(30) NOT NULL  
)
INSERT INTO tipTablica VALUES (1, 'Èinjenièna tablica');
INSERT INTO tipTablica VALUES (2, 'Dimenzijska tablica');

CREATE TABLE tablica (
    sifTablica       INTEGER IDENTITY (100, 1) CONSTRAINT pkTablica PRIMARY KEY
  , nazTablica       CHAR(100) NOT NULL
  , nazSQLTablica   CHAR(100) NOT NULL   
  , sifTipTablica    TINYINT   NOT NULL
)

ALTER TABLE tablica ADD CONSTRAINT fkTablicaTipTablica FOREIGN KEY (sifTipTablica) REFERENCES tipTablica (sifTipTablica)



CREATE TABLE tipAtrib (
    sifTipAtrib   TINYINT CONSTRAINT pkTipAtrib PRIMARY KEY
  , nazTipAtrib   CHAR(40) NOT NULL  
)
INSERT INTO tipAtrib VALUES (1, 'Mjera')
INSERT INTO tipAtrib VALUES (2, 'Dimenzijski atribut')
INSERT INTO tipAtrib VALUES (3, 'Strani kljuè')

CREATE TABLE agrFun (
  sifAgrFun TINYINT PRIMARY KEY
  , nazAgrFun CHAR(6) NOT NULL  
)
INSERT INTO agrFun VALUES (1, 'SUM')
INSERT INTO agrFun VALUES (2, 'COUNT')
INSERT INTO agrFun VALUES (3, 'AVG')
INSERT INTO agrFun VALUES (4, 'MIN')
INSERT INTO agrFun VALUES (5, 'MAX')


CREATE TABLE tabAtribut (
    sifTablica  INTEGER  CONSTRAINT fkTabAtribTablica REFERENCES tablica(sifTablica)
  , rbrAtrib    TINYINT  NOT NULL  
  , imeSQLAtrib char(50) NOT NULL  
  , sifTipAtrib TINYINT CONSTRAINT fkTabAtribTipAtrib REFERENCES tipAtrib(sifTipAtrib)  
  , imeAtrib    CHAR(50) NOT NULL
 -- , sifAgrFun   TINYINT     
  , CONSTRAINT pkTabAtribut PRIMARY KEY (sifTablica, rbrAtrib)
)
--CREATE UNIQUE INDEX idxTabAtribAtribAgrFun ON tabAtribut(sifTablica, imeSQLAtrib, sifAgrFun)
-- ALTER TABLE tabAtribut ADD CONSTRAINT fkTabAtributAgrFun FOREIGN KEY (sifAgrFun) REFERENCES agrFun (sifAgrFun)

CREATE TABLE dimCinj (
    sifCinjTablica INTEGER
  , sifDimTablica  INTEGER
  , rbrCinj  		 TINYINT  NOT NULL  
  , rbrDim         TINYINT  NOT NULL  
  , CONSTRAINT pkDimCinj PRIMARY KEY (sifCinjTablica, sifDimTablica, rbrCinj, rbrDim) 
  , CONSTRAINT fkDimCinjTablica1 FOREIGN KEY (sifCinjTablica, rbrCinj) REFERENCES tabAtribut(sifTablica, rbrAtrib)
  , CONSTRAINT fkDimCinjTablica2 FOREIGN KEY (sifDimTablica, rbrDim) REFERENCES tabAtribut(sifTablica, rbrAtrib)
)

CREATE TABLE tabAtributAgrFun (
    sifTablica  INTEGER  
  , rbrAtrib    TINYINT  
  , sifAgrFun   TINYINT  CONSTRAINT fkTabAtributAgrFun_AgrFun REFERENCES agrFun (sifAgrFun)
  , imeAtrib    CHAR(50) NOT NULL
  , CONSTRAINT pkTabAtributAgrFun PRIMARY KEY (sifTablica, rbrAtrib, sifAgrFun)
  , CONSTRAINT fkTabAtributAgrFun_TabAtribut foreign key (sifTablica, rbrAtrib) REFERENCES tabAtribut(sifTablica, rbrAtrib)  
)


------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
--             PUNJENJE STRUKTURE S TESTNIM PODACIMA
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

INSERT INTO tablica (nazTablica, nazSQLTablica, sifTipTablica) 
SELECT name, name, 1
  FROM sysobjects
 WHERE xtype = 'u'
   AND name LIKE 'c%' -- za AdventureWorks staviti LIKE 'Fact%'


INSERT INTO tablica (nazTablica, nazSQLTablica, sifTipTablica) 
SELECT name, name, 2
  FROM sysobjects
 WHERE xtype = 'u'
   AND name LIKE 'd%' -- za AdventureWorks staviti LIKE 'Dim%'
   AND name <> 'dimCinj' 

-- Prepisuje podatke o SVIM atributima u naše tablice
-- Poslije ruèno promijeniti neki naziv kako bi se testiralo imeAtrib <> imeSQLAtrib

--dim atr:
INSERT INTO tabAtribut  
SELECT (SELECT sifTablica FROM tablica WHERE nazSQLTablica =  t.name)
     , c.colid
     , c.name
     , 2
     , c.name
     
  FROM sysobjects t, syscolumns c
  WHERE t.id = c.id
    AND t.xtype = 'u'
    AND t.name LIKE 'd%' -- za AdventureWorks staviti LIKE 'Dim%'
    AND t.name <> 'dimCinj'
  ORDER BY 1, 2
  
 
-- Prepisuje podatke o SVIM atributuma iz èinjeniène tablice
-- promijeniti neki naziv kako bi se testiralo imeAtrib <> imeSQLAtrib
 
-- mjere i ostali atributi èinjeniènih tablica:
--upiti æe ispravno napuniti tabAtribut tablicu ako ste se pri imenovanju atributa držali neke konvencije 
--npr. kljuèevi dimenzija i strani kljuèevi èinjeniènih tablica sadrže neki uzorak ('%sif%' ili '%ID%' ili '%key%',...)
   
--INSERT INTO tabAtribut
--  
--SELECT (SELECT sifTablica FROM tablica WHERE nazSQLTablica =  t.name)
--     , c.colid
--     , c.name
--     , 1
--     , c.name
--     
--  FROM sysobjects t, syscolumns c
-- WHERE t.id = c.id
--   AND t.xtype = 'u'
--   AND t.name LIKE 'c%'   -- za AdventureWorks staviti LIKE 'Fact%'
--   AND t.name <> 'dimCinj'
--   AND NOT (c.name LIKE 'sif%') -- za AdventureWorks staviti LIKE '%Key'
-- ORDER BY 1, 2

INSERT INTO tabAtribut  

SELECT (SELECT sifTablica FROM tablica WHERE nazSQLTablica =  t.name)
     , c.colid
     , c.name
     , 1	--mjere
     , c.name
     
  FROM sysobjects t, syscolumns c
 WHERE t.id = c.id
   AND t.xtype = 'u'
   AND t.name LIKE 'c%'   -- za AdventureWorks staviti LIKE 'Fact%'
   AND t.name <> 'dimCinj'
   AND (c.name NOT LIKE '%ID%' 
		AND c.name NOT LIKE '%Key%')-- za AdventureWorks staviti NOT LIKE '%Key'

UNION 

SELECT (SELECT sifTablica FROM tablica WHERE nazSQLTablica =  t.name)
     , c.colid
     , c.name
     , 3 --strani kljuèevi prema dimenzijskim tablicama
     , c.name
     
  FROM sysobjects t, syscolumns c
 WHERE t.id = c.id
   AND t.xtype = 'u'
   AND t.name LIKE 'c%'   -- za AdventureWorks staviti LIKE 'Fact%'
   AND t.name <> 'dimCinj'
   AND (c.name LIKE '%ID%'
   		OR c.name LIKE '%Key%')-- za AdventureWorks staviti LIKE '%Key'

 ORDER BY 1, 2

  

-- Na temelju definiranih stranih kljuèeva prepisuje podatke u naše tablice:

INSERT INTO dimCinj  
  SELECT (SELECT sifTablica FROM tablica WHERE nazSQLTablica =  t1.name)
       , (SELECT sifTablica FROM tablica WHERE nazSQLTablica =  t2.name)
      , (SELECT rbrAtrib FROM tabAtribut, tablica
          WHERE tabAtribut.sifTablica = tablica.sifTablica
            AND tablica.nazSQLTablica = t1.name
            and upper(tabAtribut.imeSQLAtrib) = UPPER(c1.name))
      , (SELECT rbrAtrib FROM tabAtribut, tablica
          WHERE tabAtribut.sifTablica = tablica.sifTablica
            AND tablica.nazSQLTablica = t2.name
            and upper(tabAtribut.imeSQLAtrib) = UPPER(c2.name))
      
  FROM sys.sysforeignkeys fk, sysobjects t1, sysobjects t2, syscolumns c1, syscolumns c2

 WHERE fk.fkeyid = t1.id
   AND fk.rkeyid = t2.id
   AND fk.fkey   = c1.colid
   AND t1.id = c1.id
   AND fk.rkey   = c2.colid
   AND t2.id = c2.id
   AND t1.name LIKE 'c%' -- za AdventureWorks staviti LIKE 'Fact%'

 ORDER BY 1, 2
 
 
-- Za svaki mjeru definiram SUM i AVG:
-- Neke kombinacije mogu biti besmislene (npr. sum neaditivne mjere), može se poslije ruèno obrisati.
  
INSERT INTO tabAtributAgrFun 

SELECT sifTablica
     , rbrAtrib
     , 1 -- sum
     , 'Sum of ' + imeAtrib     
  FROM tabAtribut
 WHERE sifTipAtrib = 1
 ORDER BY 1, 2
 
 
INSERT INTO tabAtributAgrFun
  
SELECT sifTablica
     , rbrAtrib
     , 3 -- avg
     , 'Avg of ' + imeAtrib     
  FROM tabAtribut
 WHERE sifTipAtrib = 1
 ORDER BY 1, 2

 GO

 CREATE VIEW dOrderDate AS SELECT * FROM dDatum
 GO
 CREATE VIEW dRequriedDate AS SELECT * FROM dDatum
 GO
 CREATE VIEW dShippedDate AS SELECT * FROM dDatum
 GO

  CREATE VIEW dOrderTime AS SELECT * FROM dVrijemeDan
 GO
 CREATE VIEW dRequriedTime AS SELECT * FROM dVrijemeDan
 GO
 CREATE VIEW dShippedTime AS SELECT * FROM dVrijemeDan
 GO

 INSERT INTO tablica VALUES ('Order Date', 'dOrderDate', 2);
 INSERT INTO tablica VALUES ('Requried Date', 'dRequriedDate', 2);
 INSERT INTO tablica VALUES ('Shipped Date', 'dShippedDate', 2);
 INSERT INTO tablica VALUES ('Order Time', 'dOrderTime', 2);
 INSERT INTO tablica VALUES ('Requried Time', 'dRequriedTime', 2);
 INSERT INTO tablica VALUES ('Shipped Time', 'dShippedTime', 2);

 DROP TABLE #ta1

 SELECT * INTO #ta1 
	FROM tabAtribut 
	WHERE sifTablica = 
		(SELECT TOP 1 sifTablica FROM tablica WHERE nazSQLTablica = 'dDatum')

UPDATE #ta1 SET sifTablica = 
	(SELECT TOP 1 sifTablica FROM tablica WHERE nazSQLTablica = 'dRequriedDate')
INSERT INTO tabAtribut SELECT * FROM #ta1

UPDATE #ta1 SET sifTablica = 
	(SELECT TOP 1 sifTablica FROM tablica WHERE nazSQLTablica = 'dOrderDate')
INSERT INTO tabAtribut SELECT * FROM #ta1

UPDATE #ta1 SET sifTablica = 
	(SELECT TOP 1 sifTablica FROM tablica WHERE nazSQLTablica = 'dShippedDate')
INSERT INTO tabAtribut SELECT * FROM #ta1

 DROP TABLE #ta2

 SELECT * INTO #ta2 
	FROM tabAtribut 
	WHERE sifTablica = 
		(SELECT TOP 1 sifTablica FROM tablica WHERE nazSQLTablica = 'dVrijemeDan')

UPDATE #ta2 SET sifTablica = 
	(SELECT TOP 1 sifTablica FROM tablica WHERE nazSQLTablica = 'dOrderTime')
INSERT INTO tabAtribut SELECT * FROM #ta2


UPDATE #ta2 SET sifTablica = 
	(SELECT TOP 1 sifTablica FROM tablica WHERE nazSQLTablica = 'dRequriedTime')
INSERT INTO tabAtribut SELECT * FROM #ta2

UPDATE #ta2 SET sifTablica = 
	(SELECT TOP 1 sifTablica FROM tablica WHERE nazSQLTablica = 'dShippedTime')
INSERT INTO tabAtribut SELECT * FROM #ta2

GO

CREATE PROCEDURE alterDimCinj @zamjenskaTablica char(100), @cinjeicnaTablica char(100), @imeAtributa char(100)
AS
UPDATE dimCinj
	SET sifDimTablica = (SELECT TOP 1 sifTablica FROM tablica WHERE nazSQLTablica =  @zamjenskaTablica)
	WHERE sifCinjTablica = (SELECT TOP 1 sifTablica FROM tablica WHERE nazSQLTablica =  @cinjeicnaTablica)
		AND rbrCinj = (SELECT TOP 1 rbrAtrib FROM tabAtribut WHERE imeSQLAtrib = @imeAtributa AND sifTablica = (SELECT TOP 1 sifTablica FROM tablica WHERE nazSQLTablica =  @cinjeicnaTablica))
GO

EXEC alterDimCinj @zamjenskaTablica = 'dOrderDate', @cinjeicnaTablica = 'cOrders',  @imeAtributa = 'OrderDateKey';
EXEC alterDimCinj @zamjenskaTablica = 'dRequriedDate', @cinjeicnaTablica = 'cOrders',  @imeAtributa = 'RequiredDateKey';
EXEC alterDimCinj @zamjenskaTablica = 'dShippedDate', @cinjeicnaTablica = 'cOrders',  @imeAtributa = 'ShippedDateKey';

EXEC alterDimCinj @zamjenskaTablica = 'dOrderTime', @cinjeicnaTablica = 'cOrders',  @imeAtributa = 'OrderTimeKey';
EXEC alterDimCinj @zamjenskaTablica = 'dRequriedTime', @cinjeicnaTablica = 'cOrders',  @imeAtributa = 'RequiredTimeKey';
EXEC alterDimCinj @zamjenskaTablica = 'dShippedTime', @cinjeicnaTablica = 'cOrders',  @imeAtributa = 'ShippedTimeKey';

EXEC alterDimCinj @zamjenskaTablica = 'dOrderDate', @cinjeicnaTablica = 'cOrderItems',  @imeAtributa = 'OrderDateKey';
EXEC alterDimCinj @zamjenskaTablica = 'dRequriedDate', @cinjeicnaTablica = 'cOrderItems',  @imeAtributa = 'RequiredDateKey';
EXEC alterDimCinj @zamjenskaTablica = 'dShippedDate', @cinjeicnaTablica = 'cOrderItems',  @imeAtributa = 'ShippedDateKey';

EXEC alterDimCinj @zamjenskaTablica = 'dOrderTime', @cinjeicnaTablica = 'cOrderItems',  @imeAtributa = 'OrderTimeKey';
EXEC alterDimCinj @zamjenskaTablica = 'dRequriedTime', @cinjeicnaTablica = 'cOrderItems',  @imeAtributa = 'RequiredTimeKey';
EXEC alterDimCinj @zamjenskaTablica = 'dShippedTime', @cinjeicnaTablica = 'cOrderItems',  @imeAtributa = 'ShippedTimeKey';
