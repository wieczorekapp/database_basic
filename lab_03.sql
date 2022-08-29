-- zad 1 #######################################################################
SET SERVEROUTPUT ON

DECLARE 
    CURSOR cAsystenci IS
        SELECT *
        FROM Pracownicy
        WHERE etat = 'ASYSTENT';
        
    vAsystent Pracownicy%ROWTYPE;    
BEGIN
    OPEN cAsystenci;
    LOOP
        FETCH cAsystenci INTO vAsystent;
        EXIT WHEN cAsystenci%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(vAsystent.nazwisko || ' pracuje od ' || vAsystent.zatrudniony);
    END LOOP;
    CLOSE cAsystenci;
END;


-- zad 2 #######################################################################
DECLARE 
    CURSOR cZarobki IS
        SELECT *
        FROM Pracownicy
        ORDER BY placa_pod DESC;
        
    vPlace Pracownicy%ROWTYPE;    
BEGIN
    OPEN cZarobki;
    LOOP
        FETCH cZarobki INTO vPlace;
        EXIT WHEN cZarobki%NOTFOUND;
        EXIT WHEN cZarobki%ROWCOUNT = 4;
        
        DBMS_OUTPUT.PUT_LINE(cZarobki%ROWCOUNT || ' : ' || vPlace.nazwisko);
    END LOOP;
    CLOSE cZarobki;
END;


-- zad 3 #######################################################################
DECLARE 
    CURSOR cPodwyzka IS
        SELECT *
        FROM Pracownicy
        WHERE TO_CHAR(zatrudniony, 'd') = 1
        ORDER BY nazwisko
        FOR UPDATE;
        
    vPodwyzka Pracownicy%ROWTYPE;    
BEGIN    
    FOR vPodwyzka IN cPodwyzka LOOP
        UPDATE Pracownicy
        SET placa_pod = placa_pod * 1.2
        WHERE CURRENT OF cPodwyzka;
    END LOOP;
END;


SELECT *
FROM Pracownicy
WHERE TO_CHAR(zatrudniony, 'd') = 1
ORDER BY nazwisko;


-- zad 4 #######################################################################
DECLARE
    CURSOR cPracownicy IS
        SELECT *
        FROM Pracownicy p LEFT JOIN Zespoly z
        ON p.id_zesp = z.id_zesp 
        FOR UPDATE; -- FOR UPDATE nazwisko;
BEGIN
    FOR vPracownik IN cPracownicy LOOP
        IF vPracownik.nazwa = 'ALGORYTMY' THEN
            UPDATE Pracownicy
            SET placa_dod = COALESCE(placa_dod, 0) + 100
            WHERE CURRENT OF cPracownicy;
        ELSIF vPracownik.nazwa = 'ADMINISTRACJA' THEN
            UPDATE Pracownicy
            SET placa_dod = COALESCE(placa_dod, 0) + 150
            WHERE CURRENT OF cPracownicy;   
        ELSIF vPracownik.etat = 'STAZYSTA' THEN
            DELETE FROM Pracownicy
            WHERE CURRENT OF cPracownicy; 
        END IF;
    END LOOP;
END;


-- zad 5 #######################################################################
CREATE OR REPLACE PROCEDURE PokazPracownikowEtatu (
    -- argumenty procedury
    vEtat IN Pracownicy.etat%TYPE) IS
    
    CURSOR cPracownicy(pEtat Pracownicy.etat%TYPE) IS
        SELECT nazwisko
        FROM Pracownicy
        WHERE etat = pEtat
        ORDER BY nazwisko;
BEGIN
    FOR vPracownika IN cPracownicy(vEtat) LOOP
        DBMS_OUTPUT.PUT_LINE(vPracownika.nazwisko);
    END LOOP;     
    
END PokazPracownikowEtatu;

BEGIN
    PokazPracownikowEtatu('PROFESOR');
END;


-- zad 6 #######################################################################
CREATE OR REPLACE PROCEDURE RaportKadrowy  IS
    
    CURSOR cPracownicy(pEtat Pracownicy.etat%TYPE) IS
        SELECT nazwisko, placa_pod
        FROM Pracownicy
        WHERE etat = pEtat
        ORDER BY nazwisko;
        
    CURSOR cEtaty IS
        SELECT DISTINCT etat
        FROM Pracownicy
        ORDER BY etat;
        
    vLiczbaPracownikow NUMBER;
    vSumaPlac NUMBER;
    vSredniaPlaca NUMBER;
BEGIN

    FOR vEtat IN cEtaty LOOP
        vLiczbaPracownikow := 0;
        vSumaPlac := 0;
        vSredniaPlaca := 0;
        
        DBMS_OUTPUT.PUT_LINE('Etat: ' || vEtat.etat);
        DBMS_OUTPUT.PUT_LINE('---------------------------');
        
        FOR vPracownika IN cPracownicy(vEtat.etat) LOOP
            vLiczbaPracownikow := vLiczbaPracownikow + 1;
            vSumaPlac := vSumaPlac + COALESCE(vPracownika.placa_pod, 0);
            
            DBMS_OUTPUT.PUT_LINE(vLiczbaPracownikow || '. ' || vPracownika.nazwisko || ', pensja: ' || vPracownika.placa_pod);
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('Liczba pracowników w zespole: ' || vLiczbaPracownikow);
        
        IF vLiczbaPracownikow > 0 THEN
            vSredniaPlaca := ROUND(vSumaPlac/vLiczbaPracownikow, 2);
            DBMS_OUTPUT.PUT_LINE('Œrednia pensja: ' || vSredniaPlaca);
        ELSE
            DBMS_OUTPUT.PUT_LINE('Œrednia pensja: 0');
        END IF;
        
    END LOOP;   
    
END RaportKadrowy;

BEGIN
    RaportKadrowy;
END;

-- zad 7 #######################################################################
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
        
        IF NOT SQL%FOUND THEN
             DBMS_OUTPUT.PUT_LINE('Nie udao siê dodaæ rekordu');
        END IF;
            
    END DodajZespol;
    
    -- usuniecie zespolu poprzez jego id
    PROCEDURE UsunZespolId(
        vId IN Zespoly.id_zesp%TYPE) IS
    BEGIN
        DELETE FROM zespoly
        WHERE id_zesp = vId;
        
        IF NOT SQL%FOUND THEN
             DBMS_OUTPUT.PUT_LINE('Nie udao siê usunaæ rekordu');
        END IF;        
    END UsunZespolId;
    
     -- usuniecie zespolu poprzez jego nazwe
    PROCEDURE UsunZespolNazwa(
        vNazwa IN Zespoly.nazwa%TYPE) IS
    BEGIN
        DELETE FROM zespoly
        WHERE nazwa = vNazwa;

        IF NOT SQL%FOUND THEN
             DBMS_OUTPUT.PUT_LINE('Nie udao siê usunaæ rekordu');
        END IF;
        
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

        IF NOT SQL%FOUND THEN
             DBMS_OUTPUT.PUT_LINE('Nie udao siê zmodyfikowac rekordu');
        END IF;
        
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
    IntZespoly.UsunZespolId(120);
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
    
    -- wyjatki 
    exNazwaBrakZespolu EXCEPTION;
    exIdBrakZespolu EXCEPTION;
    exPowieloneId EXCEPTION;
    
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
        
        EXCEPTION 
            WHEN DUP_VAL_ON_INDEX THEN 
            RAISE exPowieloneId;   
            
    END DodajZespol;
    
    -- usuniecie zespolu poprzez jego id
    PROCEDURE UsunZespolId(
        vId IN Zespoly.id_zesp%TYPE) IS
        vTest Zespoly.id_zesp%TYPE;
    BEGIN
        SELECT id_zesp INTO vTest
        FROM Zespoly
        WHERE id_zesp = vId;
    
        DELETE FROM zespoly
        WHERE id_zesp = vId;
        
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN 
            RAISE exIdBrakZespolu;    
        
    END UsunZespolId;
    
     -- usuniecie zespolu poprzez jego nazwe
    PROCEDURE UsunZespolNazwa(
        vNazwa IN Zespoly.nazwa%TYPE) IS
        vTest Zespoly.nazwa%TYPE;
    BEGIN
        SELECT nazwa INTO vTest
        FROM Zespoly
        WHERE nazwa = vNazwa;
        
        DELETE FROM zespoly
        WHERE nazwa = vNazwa;

        EXCEPTION 
            WHEN NO_DATA_FOUND THEN 
            RAISE exNazwaBrakZespolu;   
        
    END UsunZespolNazwa;
    
    -- akrualizuj nazwe i adres zespolo poprzez wskazanie id
    PROCEDURE ModyfikujNazwaAdresZespolId(
        vId IN Zespoly.id_zesp%TYPE,
        vNazwa IN Zespoly.nazwa%TYPE,
        vAdres IN Zespoly.adres%TYPE) IS
        vTest Zespoly.id_zesp%TYPE;
    BEGIN
        SELECT id_zesp INTO vTest
        FROM Zespoly
        WHERE id_zesp = vId;
    
        UPDATE zespoly
        SET nazwa = vNazwa, adres = vAdres
        WHERE id_zesp = vId; 

        EXCEPTION 
            WHEN NO_DATA_FOUND THEN 
            RAISE exIdBrakZespolu; 
        
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
        
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN 
            RAISE exNazwaBrakZespolu;   
    
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
        
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN 
            RAISE exIdBrakZespolu; 
        
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
        
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN 
            RAISE exIdBrakZespolu; 
    
        RETURN vAdres;
    END AdresZespolId;
    
END IntZespoly;

BEGIN
    IntZespoly.DodajZespol('SPECJALNY', 'UJSKA 10');
    
    EXCEPTION
        WHEN IntZespoly.exPowieloneId THEN
            DBMS_OUTPUT.PUT_LINE('Powielenie ID');
END;

BEGIN
    IntZespoly.UsunZespolId(120);
    
    EXCEPTION
        WHEN IntZespoly.exIdBrakZespolu THEN
            DBMS_OUTPUT.PUT_LINE('Brak zespolu o wskazanym id');
END;

BEGIN
    IntZespoly.UsunZespolNazwa('SPECJALNY');
    
    EXCEPTION
        WHEN IntZespoly.exNazwaBrakZespolu THEN
            DBMS_OUTPUT.PUT_LINE('Brak zespolu o wskazanym id');
END;


DECLARE 
    vAdres Zespoly.adres%TYPE;
BEGIN
    SELECT IntZespoly.adreszespolid(500) INTO vAdres
    FROM dual;
    
    EXCEPTION
        WHEN IntZespoly.exIdBrakZespolu THEN
            DBMS_OUTPUT.PUT_LINE('Brak zespolu o wskazanym id');
END;

BEGIN
    IntZespoly.ModyfikujNazwaAdresZespolId(51, 'TESTERZY', 'TESTOWA 8');
    
    EXCEPTION
        WHEN IntZespoly.exIdBrakZespolu THEN
            DBMS_OUTPUT.PUT_LINE('Brak zespolu o wskazanym id');    
END;

SELECT IntZespoly.IdZespolNazwa('ALGORYTMY') AS ID_ZESPOLU
FROM dual;

SELECT IntZespoly.NazwaZespolId(10) AS NAZWA_ZESPOLU
FROM dual;

SELECT IntZespoly.AdresZespolId(10) AS ADRES_ZESPOLU
FROM dual;