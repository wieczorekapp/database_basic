1.
CREATE TABLE projekty(
	id_projektu NUMBER(4,0) GENERATED ALWAYS AS IDENTITY,
  	opis_projektu CHAR(20 BYTE),
  	data_rozpoczecia DATE DEFAULT CURRENT_DATE,
  	data_zakonczenia DATE,
  	fundusz NUMBER(7,2)
);


2.
INSERT INTO projekty(opis_projektu,data_rozpoczecia,data_zakonczenia,fundusz) 
VALUES ('Indeksy bitmapowe', DATE '1999-04-02', DATE '2001-08-31', 25000.00);

INSERT INTO projekty(opis_projektu,data_rozpoczecia,data_zakonczenia,fundusz) 
VALUES ('Sieci kręgosłupowe', DEFAULT, '', 19000.00);


3.
SELECT id_projektu, opis_projektu
FROM projekty;


4.
INSERT INTO projekty(id_projektu,opis_projektu,data_rozpoczecia,data_zakonczenia,fundusz) 
VALUES (10,'Indeksy drzewiaste', DATE '2013-12-24', DATE '2014-01-01', 1200.00);

nie można, ponieważ kolumna id_projektu ma cechę GENERATED ALWAYS, nie pozwala na "ręczne" nadanie wartości 

INSERT INTO projekty(opis_projektu,data_rozpoczecia,data_zakonczenia,fundusz) 
VALUES ('Indeksy drzewiaste', DATE '2013-12-24', DATE '2014-01-01', 1200.00);


5.
UPDATE projekty
SET id_projektu = 10
WHERE opis_projektu = 'Indeksy drzewiaste';

nie można, ponieważ kolumna id_projektu ma cechę GENERATED ALWAYS, nie pozwala na "ręczne" modyfikowanie


6.
CREATE TABLE projekty_kopia AS 
SELECT * FROM projekty;


7.
INSERT INTO projekty_kopia(id_projektu,opis_projektu,data_rozpoczecia,data_zakonczenia,fundusz) 
VALUES (10,'Sieci lokalne', CURRENT_DATE, add_months(CURRENT_DATE,12), 24500.00);

Udało się ponieważ kopia tabeli przenosi tylko typy danych bez żadnych atrybutów

8.
DELETE FROM projekty
WHERE opis_projektu = 'Indeksy drzewiaste';

Rekord w relazcji projekty_kopia nie został usunięty, ponieważ w momencie tworzenia zostałą wkonana niezależna kopia danych do tej tabeli


9.
SELECT table_name
FROM all_tables
WHERE owner = 'ZAO140858';