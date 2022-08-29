-- zad 1 #######################################################################
-- mo¿liwoœæ wyœwitlania komunikatów na konsoli
SET SERVEROUTPUT ON

DECLARE
    vTekst VARCHAR(50) := 'Witaj, œwiecie';
    vLiczba NUMBER(7,3) := 1000.456;
BEGIN

    DBMS_OUTPUT.PUT_LINE('Zmienna vTekst: ' || vTekst);
    DBMS_OUTPUT.PUT_LINE('Zmienna vLiczba: ' || vLiczba);
END;

-- zad 2 #######################################################################
-- mo¿liwoœæ wyœwitlania komunikatów na konsoli
SET SERVEROUTPUT ON

DECLARE
    vTekst VARCHAR(50) := 'Witaj, œwiecie';
    vLiczba NUMBER(20,3) := 1000.456;
BEGIN
    vTekst := vTekst || ' Witaj, nowy dniu!';
    vLiczba := vLiczba + 10**15;

    DBMS_OUTPUT.PUT_LINE('Zmienna vTekst: ' || vTekst);
    DBMS_OUTPUT.PUT_LINE('Zmienna vLiczba: ' || vLiczba);
END;

-- zad 3 #######################################################################
-- mo¿liwoœæ wyœwitlania komunikatów na konsoli
SET SERVEROUTPUT ON

DECLARE
    vLiczba1 NUMBER(20,7) := 10.2356000;
    vLiczba2 NUMBER(20,7) := 0.0000001;
    vWynik NUMBER(20,7);
BEGIN
    vWynik := vLiczba1 + vLiczba2;
    
    DBMS_OUTPUT.PUT_LINE('Wynik dodawania ' || vLiczba1 || ' i ' || vLiczba2 || ': ' || vWynik);
END;

-- zad 4 #######################################################################
-- mo¿liwoœæ wyœwitlania komunikatów na konsoli
SET SERVEROUTPUT ON

DECLARE
    cPI CONSTANT NUMBER(3,2) := 3.14;
    vPromien NUMBER(6) := 5;
    vPole NUMBER(10,4);
    vObwod NUMBER(10,4);
BEGIN
    vPole := cPI * vPromien * vPromien;
    vObwod := 2 * cPI * vPromien;
    
    DBMS_OUTPUT.PUT_LINE('Pole kola o promieniu: ' || vPromien || ' = ' || vPole);
    DBMS_OUTPUT.PUT_LINE('Obwod kola o promieniu: ' || vPromien || ' = ' || vObwod);
END;

-- zad 5 #######################################################################
-- mo¿liwoœæ wyœwitlania komunikatów na konsoli
SET SERVEROUTPUT ON

DECLARE
    vNazwisko Pracownicy.nazwisko%TYPE;
    vEtat Pracownicy.etat%TYPE;
BEGIN
    SELECT nazwisko, etat INTO vNazwisko, vEtat
    FROM pracownicy
    ORDER BY placa_pod DESC
    FETCH FIRST 1 ROWS ONLY;
    
    DBMS_OUTPUT.PUT_LINE('Najlepiej zarabia pracownik ' || vNazwisko);
    DBMS_OUTPUT.PUT_LINE('Pracuje on jako ' || vEtat);
END;

-- zad 6 #######################################################################
-- mo¿liwoœæ wyœwitlania komunikatów na konsoli
SET SERVEROUTPUT ON

DECLARE
    vPracownik Pracownicy%ROWTYPE;
BEGIN
    SELECT * INTO vPracownik
    FROM pracownicy
    ORDER BY placa_pod DESC
    FETCH FIRST 1 ROWS ONLY;
    
    DBMS_OUTPUT.PUT_LINE('Najlepiej zarabia pracownik ' || vPracownik.nazwisko);
    DBMS_OUTPUT.PUT_LINE('Pracuje on jako ' || vPracownik.etat);
END;


-- zad 7 #######################################################################
-- mo¿liwoœæ wyœwitlania komunikatów na konsoli
SET SERVEROUTPUT ON

DECLARE
    SUBTYPE tPieniadze IS NUMBER(10,2);
    vPlacaRoczna tPieniadze;
BEGIN
    SELECT placa_pod * 12 INTO vPlacaRoczna
    FROM pracownicy
    WHERE nazwisko LIKE '%SLOWINSKI%';
    
    DBMS_OUTPUT.PUT_LINE('Pracownik SLOWINSKI zarabia rocznie ' || vPlacaRoczna);
END;

-- zad 8 #######################################################################
-- mo¿liwoœæ wyœwitlania komunikatów na konsoli
SET SERVEROUTPUT ON

DECLARE
    vSekunda NUMBER(2);
BEGIN
    LOOP
        vSekunda := TO_CHAR(SYSDATE, 'ss');
        IF vSekunda = 25 THEN
            DBMS_OUTPUT.PUT_LINE('Mamy 25 s ');
            EXIT;
        END IF;
    END LOOP;
END;

-- zad 9 #######################################################################
-- mo¿liwoœæ wyœwitlania komunikatów na konsoli
SET SERVEROUTPUT ON

DECLARE
    vN INT := 5;
    vWynik INT := 1;
    
BEGIN
    FOR i in 2..vN LOOP
        vWynik := vWynik * i;
    END LOOP;
    
     DBMS_OUTPUT.PUT_LINE(vN);
     DBMS_OUTPUT.PUT_LINE(vWynik);
END;

-- zad 10 ######################################################################
-- mo¿liwoœæ wyœwitlania komunikatów na konsoli
SET SERVEROUTPUT ON

DECLARE
 vDfrom date;
 vDtill date;
 vDay date;
BEGIN
    vDfrom := TO_DATE('01.01.2001', 'dd.mm.yyyy');
    vDtill := TO_DATE('31.12.2100', 'dd.mm.yyyy');
    vDay := vDfrom;

WHILE vDay <= vDtill
LOOP
    IF TO_CHAR(vDay, 'd') = 5 AND TO_CHAR(vDay, 'dd') = 13 THEN
        DBMS_OUTPUT.PUT_LINE(vDay);
    END IF;
    vDay := vDay + 1;
END LOOP;
    
END;
