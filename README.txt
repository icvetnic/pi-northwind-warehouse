Upute za pokretanje:
1. Potrebno je unijeti 'NorthWind2015' bazu podataka na SQL server.

2. Treba napraviti novu bazu podataka na SQL serveru pod imenom 'NorthWindCvetnicSP'.
   Prilikom kreiranja nove baze potrebno je postaviti COLLATION na 'SQL_Latin1_general_CP1_CI_AS'

3. Zatim se redom pokreću skripte:
	create_dDatum.sql	//prepravljeno iz 1. DZ
	create_dVrijemeDan.sql  //prepravljeno iz 2. DZ
	create_tables.sql	//stvaraju se dimenzije i činjenične tablice
	fill_tables.sql		//kopiraju se podaci iz 'NorthWind2015' baze u skladište podataka

4. Pokretanje zadataka:
   Rješenja zadataka nalaze se u datoteci: zadatci.sql
   Za pokretanje pojedinog upita potrebno je selektirati cijeli upit i pritisnuti F5 