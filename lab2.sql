SET SERVEROUTPUT ON;

--zad1
CREATE OR REPLACE PROCEDURE NowyPracownik
    (pNazwisko CHAR,
     pNazwaZespolu CHAR,
     pNazwiskoSzefa CHAR,
     pPlacaPod NUMBER,
     pData DATE DEFAULT CURRENT_DATE,
     pStanowisko CHAR DEFAULT 'STAZYSTA') IS
BEGIN
    INSERT INTO Pracownicy
    (id_prac, nazwisko, etat, id_szefa, zatrudniony, placa_pod, placa_dod, id_zesp)
    VALUES(
        (SELECT MAX(id_prac) + 10 FROM Pracownicy),
        pNazwisko,
        pStanowisko,
        (SELECT id_prac FROM Pracownicy WHERE nazwisko = pNazwiskoSzefa),
        pData,
        pPlacaPod,
        0,
        (SELECT id_zesp FROM Zespoly WHERE nazwa = pNazwaZespolu)
    );
END NowyPracownik;
/
BEGIN
    NowyPracownik('DYNDALSKI', 'ALGORYTMY', 'BLAZEWICZ', 250, TO_DATE('21/10/11'), 'PROFESOR');
END;
/
SELECT * FROM Pracownicy WHERE nazwisko = 'DYNDALSKI';
/

--zad2
CREATE OR REPLACE FUNCTION PlacaNetto
    (pPlacaBrutto NUMBER, pProcent NUMBER DEFAULT 25)
    RETURN NUMBER IS
    vPlacaNetto NUMBER;
BEGIN
    vPlacaNetto := ROUND(pPlacaBrutto - (pPlacaBrutto * (pProcent/100)), 2);
    RETURN vPlacaNetto;
END;
/
SELECT nazwisko, placa_pod AS BRUTTO, PlacaNetto(placa_pod, 35) AS NETTO
FROM Pracownicy
WHERE etat = 'PROFESOR' ORDER BY nazwisko;
/

--zad3
CREATE OR REPLACE FUNCTION Silnia
    (pN NATURAL)
    RETURN NATURAL IS
    vWynik NATURAL DEFAULT 1;
BEGIN
    FOR vIndeks IN 1..pN LOOP
        vWynik := vWynik * vIndeks;
    END LOOP;
    RETURN vWynik;
END;
/
SELECT Silnia(10) FROM dual;

--zad4
CREATE OR REPLACE FUNCTION SilniaRek
    (pN NATURAL)
    RETURN NATURAL IS
    vWynik NATURAL DEFAULT 1;
BEGIN
    IF pN = 0 THEN
        vWynik := 1;
        RETURN vWynik;
    END IF;
    
    RETURN pN * SilniaRek(pN-1);
END;
/
SELECT SilniaRek(3) FROM dual;

--zad5
CREATE OR REPLACE FUNCTION IleLat
    (pData DATE)
    RETURN NUMBER IS
    vIleLat NUMBER;
BEGIN
    vIleLat := FLOOR((SYSDATE - pData)/365);
    RETURN vileLat;
END;
/
SELECT nazwisko, zatrudniony, IleLat(zatrudniony) as STAZ
FROM Pracownicy WHERE placa_pod > 1000
ORDER BY nazwisko;
/

--zad6
CREATE OR REPLACE PACKAGE Konwersja IS
    FUNCTION Cels_To_Fahr
        (pCels NUMBER)
        RETURN NUMBER;

    FUNCTION Fahr_To_Cels
        (pFahr NUMBER)
        RETURN NUMBER;
END Konwersja;
/
CREATE OR REPLACE PACKAGE BODY Konwersja IS
    FUNCTION Cels_To_Fahr
        (pCels NUMBER)
        RETURN NUMBER IS
        vFahrs NUMBER;
    BEGIN
        vFahrs := 9/5 * pCels + 32;
        RETURN vFahrs;
    END Cels_To_Fahr;

    FUNCTION Fahr_To_Cels
        (pFahr NUMBER)
        RETURN NUMBER IS
        vCels NUMBER;
    BEGIN
        vCels := 5/9 * (pFahr - 32);
        RETURN vCels;
    END Fahr_To_Cels;    
END Konwersja;
/
SELECT Konwersja.Fahr_To_Cels(212) AS CELSJUSZ FROM Dual;
SELECT Konwersja.Cels_To_Fahr(0) AS FAHRENHEIT FROM Dual;
/

--zad7
CREATE OR REPLACE PACKAGE Zmienne IS
    --Zmienne pakietowe
    vLicznik NUMBER DEFAULT 0;

    -- Procedury pakietowe
    PROCEDURE ZwiekszLicznik;
    PROCEDURE ZmniejszLicznik;

    --Funkcje pakietowe
    FUNCTION PokazLicznik
        RETURN NUMBER;
END Zmienne;
/

CREATE OR REPLACE PACKAGE BODY Zmienne IS
    PROCEDURE ZwiekszLicznik IS
    BEGIN
        vLicznik := vLicznik + 1;
    END ZwiekszLicznik;

    PROCEDURE ZmniejszLicznik IS
    BEGIN
        vLicznik := vLicznik - 1;
    END ZmniejszLicznik;

    FUNCTION PokazLicznik
        RETURN NUMBER IS
    BEGIN
        RETURN vLicznik;
    END PokazLicznik;
END Zmienne;
/
BEGIN
    dbms_output.put_line(Zmienne.PokazLicznik);
END;
/
BEGIN
    Zmienne.ZwiekszLicznik;
    DBMS_OUTPUT.PUT_LINE(Zmienne.PokazLicznik);
    Zmienne.ZwiekszLicznik;
    DBMS_OUTPUT.PUT_LINE (Zmienne.PokazLicznik);
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE (Zmienne.PokazLicznik);
    Zmienne.ZmniejszLicznik;
    DBMS_OUTPUT.PUT_LINE (Zmienne.PokazLicznik);
END;
/

--zad8
CREATE OR REPLACE PACKAGE IntZespoly IS
    -- Package procedures
    PROCEDURE AddTeam
        (pName ZESPOLY.NAZWA%TYPE,
            pAddress ZESPOLY.ADRES%TYPE);
    
    PROCEDURE DeleteTeamById
        (pId ZESPOLY.ID_ZESP%TYPE);

    PROCEDURE DeleteTeamByName
        (pName ZESPOLY.NAZWA%TYPE);
    
    PROCEDURE ModifyTeamData
        (pId ZESPOLY.ID_ZESP%TYPE,
            pName ZESPOLY.NAZWA%TYPE,
            pAddress ZESPOLY.ADRES%TYPE);

    -- Package functions
    FUNCTION GetTeamId
        (pName ZESPOLY.NAZWA%TYPE)
        RETURN ZESPOLY.ID_ZESP%TYPE;
    
    FUNCTION GetTeamName
        (pId ZESPOLY.ID_ZESP%TYPE)
        RETURN ZESPOLY.NAZWA%TYPE;
    
    FUNCTION GetTeamAddress
        (pId ZESPOLY.ID_ZESP%TYPE)
        RETURN ZESPOLY.ADRES%TYPE;

END IntZespoly;
/
CREATE OR REPLACE PACKAGE BODY IntZespoly IS
    -- Package procedures
    PROCEDURE AddTeam
        (pName ZESPOLY.NAZWA%TYPE,
            pAddress ZESPOLY.ADRES%TYPE) IS
    BEGIN
        INSERT INTO ZESPOLY(id_zesp, nazwa, adres)
        VALUES(
            (SELECT MAX(id_zesp) + 10 FROM zespoly),
            pName,
            pAddress
        );
    END AddTeam;
    
    PROCEDURE DeleteTeamById
        (pId ZESPOLY.ID_ZESP%TYPE) IS
    BEGIN
        DELETE FROM ZESPOLY WHERE id_zesp = pId;
    END DeleteTeamById;

    PROCEDURE DeleteTeamByName
        (pName ZESPOLY.NAZWA%TYPE) IS
    BEGIN
        DELETE FROM ZESPOLY WHERE nazwa = pName;
    END DeleteTeamByName;
    
    PROCEDURE ModifyTeamData
        (pId ZESPOLY.ID_ZESP%TYPE,
            pName ZESPOLY.NAZWA%TYPE,
            pAddress ZESPOLY.ADRES%TYPE) IS
    BEGIN
        UPDATE ZESPOLY
        SET nazwa = pName, adres = pAddress
        WHERE id_zesp = pId;
    END ModifyTeamData;

    -- Package functions
    FUNCTION GetTeamId
        (pName ZESPOLY.NAZWA%TYPE)
        RETURN ZESPOLY.ID_ZESP%TYPE IS
        vId ZESPOLY.ID_ZESP%TYPE;
    BEGIN
        SELECT id_zesp 
        INTO vId
        FROM ZESPOLY
        WHERE nazwa = pName;
        RETURN vId;
    END GetTeamId;
    
    FUNCTION GetTeamName
        (pId ZESPOLY.ID_ZESP%TYPE)
        RETURN ZESPOLY.NAZWA%TYPE IS
        vName ZESPOLY.NAZWA%TYPE;
    BEGIN
        SELECT nazwa
        INTO vName
        FROM ZESPOLY
        WHERE id_zesp = pId;
        RETURN vName;
    END GetTeamName;
    
    FUNCTION GetTeamAddress
        (pId ZESPOLY.ID_ZESP%TYPE)
        RETURN ZESPOLY.ADRES%TYPE IS
        vAddress ZESPOLY.ADRES%TYPE;
    BEGIN
        SELECT adres
        INTO vAddress
        FROM ZESPOLY
        WHERE id_zesp = pId;
        RETURN vAddress;
    END GetTeamAddress;
END IntZespoly;
/
BEGIN
    INTZESPOLY.ADDTEAM(PNAME  => 'TESTOWA NAZWA' /*IN VARCHAR2*/,
                       PADDRESS  => 'TESTOWY ADRES' /*IN VARCHAR2*/);
    -- INTZESPOLY.DELETETEAMBYID(PID  => 60 /*IN NUMBER(4)*/);
    -- INTZESPOLY.MODIFYTEAMDATA(PID  => 60 /*IN NUMBER(4)*/,
    --                           PNAME  => 'TEST2' /*IN VARCHAR2*/,
    --                           PADDRESS  => 'TEST2' /*IN VARCHAR2*/);
END;
/
SELECT * from ZESPOLY;

SELECT INTZESPOLY.GETTEAMID(PNAME  => 'ADMINISTRACJA' /*IN VARCHAR2*/) AS NAZWA,
    INTZESPOLY.GETTEAMADDRESS(PID  => 10 /*IN NUMBER(4)*/) AS ADRES,
    INTZESPOLY.GETTEAMNAME(PID  => 10 /*IN NUMBER(4)*/) AS NAZWA
FROM dual;

--zad9
SELECT object_name, status, object_type
FROM User_Objects
WHERE object_type IN ('PROCEDURE', 'FUNCTION', 'PACKAGE', 'PACKAGE BODY')
ORDER BY object_type;

SELECT text
FROM User_Source
WHERE type IN ('PROCEDURE', 'FUNCTION', 'PACKAGE', 'PACKAGE BODY')
ORDER BY line;

--zad10
DROP FUNCTION SILNIA;
DROP FUNCTION SILNIAREK;
DROP FUNCTION ILELAT;

--zad11
DROP PACKAGE KONWERSJA;