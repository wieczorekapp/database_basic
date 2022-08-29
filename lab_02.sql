-- prosty przyklad procedury i jej wywolanie
CREATE OR REPLACE PROCEDURE Podwyzka IS
BEGIN
    UPDATE Pracownicy
    SET placa_pod = placa_pod * 1.1;
END Podwyzka;


BEGIN
    Podwyzka;
END;


-- zad 1 #######################################################################
CREATE OR REPLACE PROCEDURE NowyPracownik (
    -- argumenty procedury
    vNazwisko IN Pracownicy.nazwisko%TYPE,
    vNazwaZespolu IN Zespoly.nazwa%TYPE,
    vNazwiskoSzefa IN Pracownicy.nazwisko%TYPE,
    VPlacaPod IN Pracownicy.placa_pod%TYPE,
    vEtat IN Pracownicy.etat%TYPE DEFAULT 'STAZYSTA',
    vZatrudniony IN Pracownicy.zatrudniony%TYPE DEFAULT SYSDATE) IS
    -- inne zmienne wewnatrz procedury
    vIdPrac NUMBER(4);
    vIdSzefa NUMBER(4);
    vIdZespolu NUMBER(4);
    
BEGIN
        
    SELECT MAX(id_prac) + 1 INTO vIdPrac FROM pracownicy;
    SELECT id_prac INTO vIdSzefa FROM pracownicy WHERE nazwisko LIKE vNazwiskoSzefa;
    SELECT id_zesp INTO vIdZespolu FROM zespoly WHERE nazwa LIKE vNazwaZespolu;
    
    
    INSERT INTO Pracownicy(id_prac, nazwisko, etat, id_szefa, zatrudniony, placa_pod, placa_dod, id_zesp) 
    VALUES(vIdPrac, vNazwisko, vEtat, vIdSzefa, vZatrudniony, VPlacaPod, 0, vIdZespolu);
    
END NowyPracownik;

BEGIN
    NowyPracownik('WIECZOREK', 'ALGORYTMY', 'WEGLARZ', 1500);
END;


-- zad 2 #######################################################################
CREATE OR REPLACE FUNCTION PlacaNetto (
    vPlacaPod IN NUMBER,
    vStawkaVat IN NUMBER := 20)  
    RETURN NUMBER IS 
    vNetto NUMBER; 
BEGIN 
    vNetto := vPlacaPod * ((100 - vStawkaVat) / 100);
    vNetto := ROUND(vNetto, 2);
 
    RETURN vNetto; 
END PlacaNetto;

-- wywoanie funkcji wewnatrz zapytania
SELECT nazwisko, placa_pod AS BRUTTO,
    PlacaNetto(placa_pod, 35) AS NETTO
FROM Pracownicy 
WHERE etat = 'PROFESOR' 
ORDER BY nazwisko;


-- zad 3 #######################################################################
CREATE OR REPLACE FUNCTION Silnia (
    vPodstawaSilnia IN NATURAL)  
    RETURN NATURAL IS 
    vWynikSilnia NATURAL := 1; 
BEGIN
    IF vPodstawaSilnia = 0 THEN
        RETURN 1;
    END IF;
 
    IF vPodstawaSilnia < 0 THEN
        RETURN 0;
    END IF;   
    
    FOR vI IN 1..vPodstawaSilnia LOOP
        vWynikSilnia := vWynikSilnia * vI;
    END LOOP;
    
    RETURN vWynikSilnia; 
    
END Silnia;

-- wywoanie funkcji wewnatrz zapytania
SELECT Silnia(8)
FROM DUAL;


-- zad 4 #######################################################################
CREATE OR REPLACE FUNCTION SilniaRek (
    vPodstawaSilnia IN NATURAL)  
    RETURN NATURAL IS 
BEGIN
    IF vPodstawaSilnia = 0 THEN
        RETURN 1;
    END IF;
 
    IF vPodstawaSilnia < 0 THEN
        RETURN 0;
    END IF;   
    
    RETURN vPodstawaSilnia * SilniaRek(vPodstawaSilnia - 1); 
    
END SilniaRek;

-- wywoanie funkcji wewnatrz zapytania
SELECT SilniaRek(10)
FROM DUAL;


-- zad 5 #######################################################################
CREATE OR REPLACE FUNCTION IleLat (
    vZatrudniony IN pracownicy.zatrudniony%TYPE)  
    RETURN NATURAL IS 
BEGIN  
    
    RETURN TRUNC((MONTHS_BETWEEN(SYSDATE, vZatrudniony)/12)); 
    
END IleLat;

-- wywoanie funkcji wewnatrz zapytania
SELECT nazwisko, zatrudniony, IleLat(zatrudniony) AS STAZ
FROM pracownicy
WHERE placa_pod > 1000
ORDER BY nazwisko;


-- zad 6 #######################################################################
-- okreslenie interfejsu pakietu dostepngo 'na zewnatrz'
CREATE OR REPLACE PACKAGE Konwersja IS
    FUNCTION Cels_To_Fahr(vCels NUMBER)
        RETURN NUMBER;

    FUNCTION Fahr_To_Cels(vFahr NUMBER)
        RETURN NUMBER;

END Konwersja;

CREATE OR REPLACE PACKAGE BODY Konwersja IS 
    FUNCTION Cels_To_Fahr(vCels NUMBER)
        RETURN NUMBER IS
        vFahr NUMBER;
    BEGIN
        vFahr := 9/5 * vCels + 32;
        
        RETURN vFahr;
    END Cels_To_Fahr;
    
    FUNCTION Fahr_To_Cels(vFahr NUMBER)
        RETURN NUMBER IS
        vCels NUMBER;
    BEGIN
        vCels := 5/9 * (vFahr - 32);
        
        RETURN vCels;
    END Fahr_To_Cels;    
    
END Konwersja;

SELECT Konwersja.Fahr_To_Cels(212) AS CELSJUSZ
FROM dual;

SELECT Konwersja.Cels_To_Fahr(0) AS FAHRENHEIT
FROM dual;


-- zad 7 #######################################################################
SET SERVEROUTPUT ON

CREATE OR REPLACE PACKAGE Zmienne IS
    PROCEDURE ZwiekszLicznik;
    PROCEDURE ZmniejszLicznik;
    FUNCTION PokazLicznik
        RETURN NATURAL;
END Zmienne;

CREATE OR REPLACE PACKAGE BODY Zmienne IS 
    vLicznik NATURAL;
    
    PROCEDURE ZwiekszLicznik IS
    BEGIN
        vLicznik := vLicznik + 1;
        DBMS_OUTPUT.PUT_LINE('Zwiekszono');
    END ZwiekszLicznik;
    
    PROCEDURE ZmniejszLicznik IS
    BEGIN
        vLicznik := vLicznik - 1;
        DBMS_OUTPUT.PUT_LINE('Zmniejszono');
    END ZmniejszLicznik;
    
    FUNCTION PokazLicznik
        RETURN NATURAL IS
    BEGIN
        RETURN vLicznik;
    END PokazLicznik;
BEGIN
    
    vLicznik := 1;
    DBMS_OUTPUT.PUT_LINE('Zainicjalizowano');
    
END Zmienne;

SET SERVEROUTPUT ON

SELECT Zmienne.PokazLicznik
FROM dual;

BEGIN
    DBMS_OUTPUT.PUT_LINE(Zmienne.PokazLicznik);
    Zmienne.ZwiekszLicznik;
    DBMS_OUTPUT.PUT_LINE(Zmienne.PokazLicznik);
END;

BEGIN
    DBMS_OUTPUT.PUT_LINE(Zmienne.PokazLicznik);
    Zmienne.ZmniejszLicznik;
    DBMS_OUTPUT.PUT_LINE(Zmienne.PokazLicznik);
END;


-- zad 8 #######################################################################
CREATE OR REPLACE PACKAGE IntZespoly IS
    -- deklaracje procedur interfejsu
    PROCEDURE DodajZespol(
        vNazwa IN Zespoly.nazwa%TYPE,
        vAdres IN Zespoly.adres%TYPE
        );
        
    PROCEDURE UsunZespolId(
        vId IN Zespoly.id_zesp%TYPE
        );
        
    PROCEDURE UsunZespolNazwa(
        vNazwa IN Zespoly.nazwa%TYPE
        );
        
    PROCEDURE ModyfikujNazwaAdresZespolId(
        vId IN Zespoly.id_zesp%TYPE,
        vNazwa IN Zespoly.nazwa%TYPE,
        vAdres IN Zespoly.adres%TYPE
        );
    
     -- deklaracje funkcji interfejsu
    FUNCTION IdZespolNazwa(
        vNazwa IN Zespoly.nazwa%TYPE)
        RETURN Zespoly.id_zesp%TYPE;
        
    FUNCTION NazwaZespolId(
        vId IN Zespoly.id_zesp%TYPE)
        RETURN Zespoly.nazwa%TYPE;
        
    FUNCTION AdresZespolId(
        vId IN Zespoly.id_zesp%TYPE)
        RETURN Zespoly.adres%TYPE; 
        
END IntZespoly;

CREATE OR REPLACE PACKAGE BODY IntZespoly IS
    -- definicje procedur interfejsu
    -- dodanie nowego zespolu
    PROCEDURE DodajZespol(
        vNazwa IN Zespoly.nazwa%TYPE,
        vAdres IN Zespoly.adres%TYPE
        ) IS
        vNoweId Zespoly.id_zesp%TYPE;
    BEGIN
        SELECT MAX(id_zesp) + 1 INTO vNoweId
        FROM zespoly;
            
        INSERT INTO zespoly(id_zesp, nazwa, adres)
        VALUES(vNoweId, vNazwa, vAdres);
            
    END DodajZespol;
    
    -- usuniecie zespolu poprzez jego id
    PROCEDURE UsunZespolId(
        vId IN Zespoly.id_zesp%TYPE) IS
    BEGIN
        DELETE FROM zespoly
        WHERE id_zesp = vId;
    END UsunZespolId;
    
     -- usuniecie zespolu poprzez jego nazwe
    PROCEDURE UsunZespolNazwa(
        vNazwa IN Zespoly.nazwa%TYPE) IS
    BEGIN
        DELETE FROM zespoly
        WHERE nazwa = vNazwa;   
    END UsunZespolNazwa;
    
    -- akrualizuj nazwe i adres zespolo poprzez wskazanie id
    PROCEDURE ModyfikujNazwaAdresZespolId(
        vId IN Zespoly.id_zesp%TYPE,
        vNazwa IN Zespoly.nazwa%TYPE,
        vAdres IN Zespoly.adres%TYPE) IS
    BEGIN
        UPDATE zespoly
        SET nazwa = vNazwa, adres = vAdres
        WHERE id_zesp = vId; 
    END ModyfikujNazwaAdresZespolId;
    
     -- definicje funkcji interfejsu
     -- id zespolu o przeslanej nazwie
    FUNCTION IdZespolNazwa(
        vNazwa IN Zespoly.nazwa%TYPE)
        RETURN Zespoly.id_zesp%TYPE IS
        vId Zespoly.id_zesp%TYPE; 
    BEGIN
        SELECT id_zesp INTO vID
        FROM zespoly
        WHERE nazwa = vNazwa;
    
        RETURN vId;
    END IdZespolNazwa;
        
     -- nazwa zespolu o przeslanym id   
    FUNCTION NazwaZespolId(
        vId IN Zespoly.id_zesp%TYPE)
        RETURN Zespoly.nazwa%TYPE IS
        vNAZWA Zespoly.nazwa%TYPE;
    BEGIN
        SELECT nazwa INTO vNazwa
        FROM zespoly
        WHERE id_zesp = vId;
        
        RETURN vNAZWA;
    END NazwaZespolId;
    
    -- adres zespolu o wskazanym id    
    FUNCTION AdresZespolId(
        vId IN Zespoly.id_zesp%TYPE)
        RETURN Zespoly.adres%TYPE IS
        vAdres Zespoly.adres%TYPE;
    BEGIN
        SELECT adres INTO vAdres
        FROM zespoly
        WHERE id_zesp = vId;
    
        RETURN vAdres;
    END AdresZespolId;
    
END IntZespoly;

BEGIN
    IntZespoly.DodajZespol('SPECJALNY', 'UJSKA 10');
END;

BEGIN
    IntZespoly.UsunZespolId(51);
END;

BEGIN
    IntZespoly.UsunZespolNazwa('SPECJALNY');
END;

BEGIN
    IntZespoly.ModyfikujNazwaAdresZespolId(51, 'TESTERZY', 'TESTOWA 8');
END;

SELECT IntZespoly.IdZespolNazwa('ALGORYTMY') AS ID_ZESPOLU
FROM dual;

SELECT IntZespoly.NazwaZespolId(10) AS NAZWA_ZESPOLU
FROM dual;

SELECT IntZespoly.AdresZespolId(10) AS ADRES_ZESPOLU
FROM dual;


-- zad 8 #######################################################################
-- wszystkie 'samodzielne' procedury
SELECT object_name, status
FROM User_Objects
WHERE object_type = 'PROCEDURE';

-- wszystkie 'samodzielne' funkcje
SELECT object_name, status
FROM User_Objects
WHERE object_type = 'FUNCTION';

-- wszystkie pakiety u¿ytkownika
SELECT object_name, object_type, status
FROM User_Objects
WHERE object_type IN ('PACKAGE', 'PACKAGE BODY');

-- wszystkie porcedury i funkcje w pakietach
SELECT procedure_name AS podprogram, object_name AS pakiet 
FROM User_Procedures 
WHERE object_type = 'PACKAGE' 
AND procedure_name IS NOT NULL  
ORDER BY pakiet, podprogram;

-- kod zrodlowy samodzielenych procedur
SELECT text
FROM User_Source 
WHERE name = 'PODWYZKA' AND type = 'PROCEDURE'
ORDER BY line;

-- kod zrodlowy samodzielenych funkcj
SELECT text
FROM User_Source 
WHERE name = 'PlacaNetto' AND type = 'FUNCTION'
ORDER BY line;

-- kod zrodlowy interfejsow pakietow
SELECT text
FROM User_Source 
WHERE name = 'ZMIENNE' AND type = 'PACKAGE'
ORDER BY line;

-- kod zrodlowy body pakietow
SELECT text
FROM User_Source 
WHERE name = 'ZMIENNE' AND type = 'PACKAGE BODY'
ORDER BY line;

-- rekompilacje
-- ALTER PROCEDURE | FUNCTION <nazwa_programu> COMPILE;
-- ALTER PACKAGE <nazwa_pakietu> COMPILE PACKAGE | PACKAGE BODY;

-- zad 9 #######################################################################
DROP FUNCTION Silnia;
DROP FUNCTION SilniaRek;
DROP FUNCTION IleLat;

-- zad 10 ######################################################################
-- DROP PACKAGE BODY <nazwa_pakietu>;
DROP PACKAGE Konwersja;