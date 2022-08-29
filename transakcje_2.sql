-- sesja A
-- 417
-- Wspó³bie¿noœæ, blokady
select sys_context('USERENV', 'SID') from dual;



-- aktualizacja
UPDATE pracownicy
SET placa_pod = placa_pod + 100
WHERE nazwisko = 'HAPKE';

-- zalozona jest blokad na tabeli TM na relacji pracownicy
select * from table(sbd.blokady);


-- czy blokuje inna wskazuje na 1, czyli nasza sesje b
select * from table(sbd.blokady);

-- sesja blokada oczekuje na TX EXCLUSIVE X 
select * from table(sbd.blokady(234));

-- odblokowuje wykonanie update z sesji B
ROLLBACK;

-- teraz sesja b zalozyla blkade TM
select * from table(sbd.blokady(234));

-- nie widac zmian wprowadzonych przez sesje B bo nie zatwierdzone
SELECT *
FROM pracownicy
WHERE nazwisko = 'HAPKE';

-- Wspó³bie¿noœæ, poziomy izolacji
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- 480
SELECT placa_pod
FROM pracownicy
WHERE nazwisko = 'KONOPKA';

-- udalo sie zaktualizowac wartosc
UPDATE pracownicy
SET placa_pod = 280
WHERE nazwisko = 'KONOPKA';

COMMIT;
-- koncowo uzytkowanik ma 280
-- a powinien miec 780
-- wystapil problem Utracona modyfikacja (ang. lost update)

-- przy serializable nie pozwala zaminic na 280 bez wczesnijszego zatwierdzenia transakcji i ponownym ustawieniu 280
-- SPRAWDZIC


-- Anomalia skroœnego zapisu na poziomie izolacji SERIALIZABLE w Oracle
COMMIT;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

update pracownicy
set placa_pod=(select placa_pod
from pracownicy
where nazwisko='SLOWINSKI')
where nazwisko = 'BRZEZINSKI';


COMMIT;

-- rezultat polecenia pokazuje ze transakcje serializable wykorzystuja migawke z momentu tworzenia transakcji
-- gdyby nastapila pelna serializacjia obu uzytkownikow mialo taka sama wartosc placy podstawowaej(taka jak pierwszys update w sesji A)
SELECT *
FROM pracownicy
WHERE nazwisko = 'BRZEZINSKI' OR nazwisko = 'SLOWINSKI';


-- Zakleszczenie
UPDATE pracownicy
SET placa_pod = placa_pod + 10
WHERE id_prac = 210;

-- RDMS wykryl zakleszczenie 
UPDATE pracownicy
SET placa_pod = placa_pod + 10
WHERE id_prac = 220;

ROLLBACK;

-- sesja B
-- 234
-- Wspó³bie¿noœæ, blokady
select sys_context('USERENV', 'SID') from dual;

-- nie widzimy niezatwierdzonych zmian sesji A
SELECT *
FROM pracownicy
WHERE nazwisko = 'HAPKE';

-- aktualizacja, przy jej probie narzedzie zawisza sie poniewaz zalozona jest blokada na ktora czeka
UPDATE pracownicy
SET placa_pod = placa_pod + 50
WHERE nazwisko = 'HAPKE';

ROLLBACK;
-- przywrocenie placy podstawowe do 480

-- Wspó³bie¿noœæ, poziomy izolacji
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- rowniez 480
SELECT placa_pod
FROM pracownicy
WHERE nazwisko = 'KONOPKA';

UPDATE pracownicy
SET placa_pod = 780
WHERE nazwisko = 'KONOPKA';

COMMIT;


-- Anomalia skroœnego zapisu na poziomie izolacji SERIALIZABLE w Oracle
COMMIT;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

update pracownicy
set placa_pod=(select placa_pod
from pracownicy
where nazwisko='BRZEZINSKI')
where nazwisko = 'SLOWINSKI';

COMMIT;


-- Zakleszczenie
UPDATE pracownicy
SET placa_pod = placa_pod + 10
WHERE id_prac = 220;

UPDATE pracownicy
SET placa_pod = placa_pod + 10
WHERE id_prac = 210;

-- po wycofaniu w sesji A mozna zatwierdzic zmiany
COMMIT;
