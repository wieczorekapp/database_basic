1.
-- klucz główny
ALTER TABLE projekty
ADD CONSTRAINT pk_projekty PRIMARY KEY (id_projektu);

-- klucz unikalny
ALTER TABLE projekty
ADD CONSTRAINT uk_projekty UNIQUE (opis_projektu);

-- opis NOT NULL
ALTER TABLE projekty
MODIFY opis_projektu NOT NULL;

-- check na datach
ALTER TABLE projekty
ADD CONSTRAINT chk_date CHECK(data_zakonczenia > data_rozpoczecia);

-- check na fundusze
ALTER TABLE projekty
ADD CONSTRAINT chk_fundusz CHECK(fundusz > 0 OR fundusz IS NULL);

-- sprawdzenie ograczniczeń
SELECT constraint_name, search_condition, table_name
FROM USER_CONSTRAINTS
WHERE table_name = 'PRZYDZIALY';

SELECT constraint_name, column_name
FROM user_cons_columns
WHERE table_name = 'PROJEKTY'
ORDER BY constraint_name, position;


2.
INSERT INTO projekty(opis_projektu,data_rozpoczecia,data_zakonczenia,fundusz) 
VALUES ('Indeksy bitmapowe', DATE '1999-04-02', DATE '2001-08-31', 25000.00);

Operacja zakończyła się niepowodzeniem, ponieważ naruszone zostało ograniczenie uk_projekty gwarantujące UNIQUE


3.
CREATE TABLE projekty(
	id_projektu NUMBER(4,0) NOT NULL,
  	nr_pracownika NUMBER(6,0) NOT NULL,
  	od DATE DEFAULT CURRENT_DATE,
  	od DATE,
  	stawka NUMBER(7,2),
	rola VARCHAR(20),
	CONSTRAINT fk_przydzialy_01 
		FOREIGN KEY(id_projektu)
		REFERENCES projekty(id_projektu),
	CONSTRAINT fk_przydzialy_02 
		FOREIGN KEY (nr_pracownika )
		REFERENCES projekty(id_prac),
	CONSTRAINT pk_przydzialy
		PRIMARY KEY(id_projektu, nr_pracownika),
	CONSTRAINT chk_przydzialy_data
		CHECK(od > od),
	CONSTRAINT chk_przydzialy_stawka
		CHECK(stawka > 0),
	CONSTRAINT chk_przydzialy_rola
		CHECK(rola IN('KIERUJĄCY','ANALITYK','PROGRAMISTA'))	
);


4.
INSERT INTO przydzialy
VALUES ((SELECT id_projektu FROM projekty WHERE opis_projektu = 'Indeksy bitmapowe'), 
	170,DATE '1999-04-10', DATE '1999-05-10',1000,'KIERUJĄCY');

INSERT INTO przydzialy
VALUES ((SELECT id_projektu FROM projekty WHERE opis_projektu = 'Indeksy bitmapowe'), 
	140,DATE '2000-12-01', NULL,1500,'ANALITYK');

INSERT INTO przydzialy
VALUES ((SELECT id_projektu FROM projekty WHERE opis_projektu = 'Sieci kręgosłupowe'), 
	140,DATE '2015-09-14', NULL,2500,'KIERUJĄCY');

SELECT *
FROM przydzialy;


5.
ALTER TABLE przydzialy
ADD godziny NUMBER(4,0) NOT NULL;

Nie można wykonać tego polecenia ponieważ w istnijących rekordach wartość godzina byłaby null, co jest niezgodne


6.
ALTER TABLE przydzialy
ADD godziny NUMBER(4,0);

UPDATE przydzialy
SET godziny = 1000;

ALTER TABLE przydzialy
MODIFY godziny NOT NULL;


7.
ALTER TABLE projekty
DISABLE CONSTRAINT uk_projekty;

SELECT constraint_name, status, search_condition, table_name
FROM USER_CONSTRAINTS
WHERE table_name = 'PROJEKTY';


8.
INSERT INTO projekty(opis_projektu,data_rozpoczecia,data_zakonczenia,fundusz) 
VALUES ('Indeksy bitmapowe', DATE '2015-04-12', DATE '2016-09-30', 20000.00);

Po wyłączeniu ograniczenia udało się


9.
ALTER TABLE projekty
ENABLE CONSTRAINT uk_projekty;

Nie udało się, ponieważ w tabeli nie są zachowanie warunki ograniczenia


10.
UPDATE projekty
SET opis_projektu = 'Inne indeksy'
WHERE id_projektu = 5;

ALTER TABLE projekty
ENABLE CONSTRAINT uk_projekty;

Udało się, ponieważ wszystkie istnijące rekordy spełniją założenie ograniczenia


11.
ALTER TABLE projekty
MODIFY opis_projektu CHAR(10 BYTE);

Nie można wprowadzić tej zminay, ponieważ istniją rekordy o większej długości


12.
DELETE FROM projekty
WHERE opis_projektu = 'Sieci kręgosłupowe';

Nie można usunąć rekordu ponieważ, ustawiony jest klucz obcy i istniej taki przydział pracownika do projektu, dopóki on jest nie można usunąć projektu


13.
ALTER TABLE przydzialy
DROP CONSTRAINT fk_przydzialy_01;

ALTER TABLE przydzialy
ADD CONSTRAINT fk_przydzialy_01
FOREIGN KEY(id_projektu)
REFERENCES projekty(id_projektu)
ON DELETE CASCADE;

DELETE FROM projekty
WHERE opis_projektu = 'Sieci kręgosłupowe';

SELECT *
FROM projekty;

SELECT *
FROM przydzialy;


14.
DROP TABLE projekty
CASCADE CONSTRAINTS;

SELECT constraint_name, search_condition, table_name
FROM USER_CONSTRAINTS
WHERE table_name = 'PRZYDZIALY';

W tabeli przydzialy został usunięty klucz obcy powiązany projektami


15.
DROP TABLE przydzialy;
DROP TABLE projekty_kopia;

SELECT table_name
FROM all_tables
WHERE owner = 'ZAO140858';




