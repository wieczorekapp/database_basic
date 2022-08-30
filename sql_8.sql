1.
INSERT INTO pracownicy(id_prac,nazwisko,etat,id_szefa,zatrudniony,placa_pod,placa_dod,id_zesp) VALUES 
(250,'KOWALSKI','ASYSTENT',NULL,date '2015-01-13',1500,NULL,10);

INSERT INTO pracownicy(id_prac,nazwisko,etat,id_szefa,zatrudniony,placa_pod,placa_dod,id_zesp) VALUES 
(260,'ADAMSKI','ASYSTENT',NULL,date '2014-09-10',1500,NULL,10);

INSERT INTO pracownicy(id_prac,nazwisko,etat,id_szefa,zatrudniony,placa_pod,placa_dod,id_zesp) VALUES 
(270,'NOWAK','ADIUNKT',NULL,date '1990-05-01',2050,NULL,20);


2.
UPDATE pracownicy
SET placa_pod = coalesce(placa_pod*1.1,0),
placa_dod = coalesce(placa_dod*1.2,100)
WHERE id_prac IN (250,260,270);

SELECT * 
FROM pracownicy
WHERE id_prac IN (250,260,270);


3.
INSERT INTO zespoly(id_zesp,nazwa,adres) VALUES 
(60,'BAZY DANYCH','PIOTROWO 2');

SELECT * 
FROM zespoly
WHERE id_zesp = 60;


4.
UPDATE pracownicy
SET id_zesp = (SELECT id_zesp
FROM zespoly
WHERE nazwa = 'BAZY DANYCH')
WHERE id_prac IN (250,260,270); 


5.
UPDATE pracownicy
SET id_szefa = (SELECT id_prac
FROM pracownicy
WHERE nazwisko = 'MORZY')
WHERE id_zesp = (SELECT id_zesp
FROM zespoly
WHERE nazwa = 'BAZY DANYCH');


6.
DELETE FROM zespoly
WHERE id_zesp = 60;

Nie można usunąć tego rekordu, ponieważ jest on kluczem obcym w tabeli pracownicy, gdzie są powiązane rekordy z tym zespołem


7.
DELETE FROM pracownicy
WHERE id_prac IN (250,260,270);

DELETE FROM zespoly
WHERE id_zesp = 60;


8.
SELECT p.nazwisko, p.placa_pod, (SELECT 0.1*AVG(placa_pod)
FROM pracownicy
WHERE id_zesp = p.id_zesp
GROUP BY id_zesp) AS podwyzka
FROM pracownicy p
ORDER BY nazwisko;


9.
UPDATE pracownicy p
SET placa_pod = placa_pod + (SELECT 0.1*AVG(placa_pod)
FROM pracownicy
WHERE id_zesp = p.id_zesp
GROUP BY id_zesp);


10.
SELECT *
FROM pracownicy
ORDER BY placa_pod
FETCH FIRST 1 ROWS ONLY;

SELECT *
FROM pracownicy p
WHERE p.placa_pod = (SELECT MIN(placa_pod) FROM pracownicy p1);


11.
UPDATE pracownicy
SET placa_pod = placa_pod + (SELECT AVG(placa_pod) FROM pracownicy)
WHERE id_prac IN (SELECT id_prac
FROM pracownicy p
WHERE p.placa_pod = (SELECT MIN(placa_pod) FROM pracownicy p1))


12.
UPDATE pracownicy
SET placa_dod = (SELECT AVG(p1.placa_pod)
FROM pracownicy p1
WHERE p1.id_szefa = 140)
WHERE id_zesp = 20;

SELECT nazwisko, placa_dod
FROM pracownicy
WHERE id_zesp = 20
ORDER BY nazwisko;


13.
UPDATE pracownicy p
SET placa_pod = 1.25 * placa_pod
WHERE p.id_prac IN (SELECT p1.id_prac
FROM pracownicy p1 JOIN zespoly z
ON p1.id_zesp = z.id_zesp
WHERE z.nazwa = 'SYSTEMY ROZPROSZONE');

SELECT p1.nazwisko, p1.placa_pod
FROM pracownicy p1 JOIN zespoly z
ON p1.id_zesp = z.id_zesp
WHERE z.nazwa = 'SYSTEMY ROZPROSZONE';


14.
SELECT p1.nazwisko AS pracownik, p2.nazwisko AS szef
FROM pracownicy p1 JOIN pracownicy p2
ON p1.szef_id = p2.id_prac
WHERE p2.nazwisko = 'MORZY';


DELETE FROM pracownicy
WHERE id_prac IN (SELECT p1.id_prac
FROM pracownicy p1 JOIN pracownicy p2
ON p1.id_szefa = p2.id_prac
WHERE p2.nazwisko = 'MORZY');


15.
SELECT * 
FROM pracownicy;


16.
CREATE SEQUENCE prac_seq START WITH 300 INCREMENT BY 10;


17.
INSERT INTO pracownicy(id_prac,nazwisko,etat,placa_pod)
VALUES (prac_seq.NEXTVAL,'Trąbczyński','STAZYSTA',1000);
  
SELECT * 
FROM pracownicy
WHERE id_prac = 300;


18.
UPDATE pracownicy
SET placa_dod = prac_seq.CURRVAL
WHERE id_prac = 300;

SELECT * 
FROM pracownicy
WHERE id_prac = 300;


19.
DELETE FROM pracownicy
WHERE nazwisko = 'Trąbczyński';


20.
CREATE SEQUENCE mala_seq START WITH 0 INCREMENT BY 1 MAXVALUE 10 MINVALUE 0;
SELECT mala_seq.NEXTVAL FROM dual;


21
DROP SEQUENCE mala_seq;
