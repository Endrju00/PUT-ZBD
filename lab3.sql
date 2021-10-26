SET SERVEROUTPUT ON;
--zad1
DECLARE 
    CURSOR cPraca IS
    SELECT NAZWISKO, ZATRUDNIONY
    FROM PRACOWNICY
    WHERE ETAT = 'ASYSTENT'
    ORDER BY zatrudniony, nazwisko;
BEGIN
    FOR vPracownik in cPraca LOOP
        DBMS_OUTPUT.PUT_LINE(vPracownik.nazwisko || ' pracuje od ' || vPracownik.zatrudniony);
    END LOOP;
END;
/

--zad2
DECLARE
    CURSOR cZarobki IS
        SELECT nazwisko
        FROM PRACOWNICY
        ORDER BY placa_pod + COALESCE(placa_dod, 0) DESC; 
    vPracownik PRACOWNICY.nazwisko%TYPE;
BEGIN
    OPEN cZarobki;
    LOOP
        FETCH cZarobki INTO vPracownik;
        EXIT WHEN cZarobki%ROWCOUNT = 4;
        DBMS_OUTPUT.PUT_LINE(cZarobki%ROWCOUNT || ' : ' || vPracownik);
    END LOOP;
    CLOSE cZarobki;
END;
/

--zad3
DECLARE
    CURSOR cPoniedzialkowi IS
        SELECT nazwisko, zatrudniony, placa_pod
        FROM PRACOWNICY
        WHERE TO_CHAR(zatrudniony, 'DAY') = 'PONIEDZIAŁEK'
        FOR UPDATE;        
BEGIN
    FOR vPracownik IN cPoniedzialkowi LOOP
        UPDATE PRACOWNICY
        SET placa_pod = placa_pod * 1.2
        WHERE CURRENT OF cPoniedzialkowi;
    END LOOP;
END;
/

--zad4
DECLARE
    CURSOR cPodwyzkaUsunStazystow IS
        SELECT nazwisko, etat, placa_dod, nazwa
        FROM Pracownicy JOIN Zespoly USING(id_zesp)
        FOR UPDATE OF placa_dod;
BEGIN
    FOR vPracownik IN cPodwyzkaUsunStazystow LOOP
        IF vPracownik.nazwa = 'ALGORYTMY' THEN
            UPDATE PRACOWNICy
            SET placa_dod = COALESCE(placa_dod, 0) + 100
            WHERE CURRENT OF cPodwyzkaUsunStazystow;
        
        ELSIF vPracownik.nazwa = 'ADMINISTRACJA' THEN
            UPDATE PRACOWNICy
            SET placa_dod = COALESCE(placa_dod, 0) + 150
            WHERE CURRENT OF cPodwyzkaUsunStazystow;

        ELSIF vPracownik.etat = 'STAZYSTA' THEN
            DELETE FROM PRACOWNICY
            WHERE CURRENT OF cPodwyzkaUsunStazystow;
        END IF;

    END LOOP;
END;
/

--zad5
CREATE OR REPLACE PROCEDURE PokazPracownikowEtatu
    (pEtat PRACOWNICY.ETAT%TYPE) IS
    CURSOR cPokazEtat IS
        SELECT nazwisko FROM PRACOWNICY
        WHERE etat = pEtat
        ORDER BY nazwisko;
BEGIN
    FOR vPracownik IN cPokazEtat LOOP
        DBMS_OUTPUT.PUT_LINE(vPracownik.nazwisko);
    END LOOP;
END PokazPracownikowEtatu;
/
BEGIN
    PokazPracownikowEtatu('PROFESOR');
END;
/

--zad6
CREATE OR REPLACE PROCEDURE RaportKadrowy IS
    CURSOR cPokazEtaty IS
        SELECT NAZWA 
        FROM ETATY
        ORDER BY NAZWA;
    
    CURSOR cPokazPracownikowEtatu(pEtat PRACOWNICY.ETAT%TYPE) IS
        SELECT nazwisko, placa_pod + COALESCE(placa_dod, 0) as pensja
        FROM PRACOWNICY
        WHERE etat = pEtat
        ORDER BY NAZWISKO;
    
    vCounter NUMBER;
    vAvg NUMBER DEFAULT 0;
        
BEGIN
    FOR vEtat IN cPokazEtaty LOOP
        vCounter := 0;
        vAvg := 0;
        DBMS_OUTPUT.PUT_LINE('Etat: ' || vEtat.nazwa);
        DBMS_OUTPUT.PUT_LINE('----------------------');
        FOR vPracownik IN cPokazPracownikowEtatu(vEtat.nazwa) LOOP
            DBMS_OUTPUT.PUT_LINE(cPokazPracownikowEtatu%ROWCOUNT || '. ' || vPracownik.nazwisko || ', pensja: ' || vPracownik.pensja);
            vCounter := vCounter + 1;
            vAvg := vAvg + vPracownik.pensja;
        END LOOP;
        vAvg := ROUND(vAvg/vCounter, 2);
        DBMS_OUTPUT.PUT_LINE('Liczba pracownikow: ' || vCounter);
        DBMS_OUTPUT.PUT_LINE('Średnia płaca na etacie: ' || vAvg);
        DBMS_OUTPUT.PUT_LINE(' ');
    END LOOP;
END RaportKadrowy;
/
BEGIN
    RaportKadrowy;
END;
/

--zad7
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
        IF SQL%FOUND THEN
            DBMS_OUTPUT.PUT_LINE ('Dodanych rekordów: '|| SQL%ROWCOUNT);
        ELSE
            DBMS_OUTPUT.PUT_LINE ('Nie wstawiono żadnego rekordu!');
        END IF;
    END AddTeam;
    
    PROCEDURE DeleteTeamById
        (pId ZESPOLY.ID_ZESP%TYPE) IS
    BEGIN
        DELETE FROM ZESPOLY WHERE id_zesp = pId;
        IF SQL%FOUND THEN
            DBMS_OUTPUT.PUT_LINE ('Usuniętych rekordów: '|| SQL%ROWCOUNT);
        ELSE
            DBMS_OUTPUT.PUT_LINE ('Usunięcie rekordu zakończyło się niepowodzeniem.');
        END IF;
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
        IF SQL%FOUND THEN
            DBMS_OUTPUT.PUT_LINE ('Zmienionych rekordów: '|| SQL%ROWCOUNT);
        ELSE
            DBMS_OUTPUT.PUT_LINE ('Nie udało się zmienić żadnego rekordu!');
        END IF;
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

--przykłady w skrypcie
CREATE OR REPLACE PROCEDURE Kara(pNazwisko IN VARCHAR, pKwotaKary IN NUMBER) IS
 vPlacaPod Pracownicy.placa_pod%TYPE;
 vRowid ROWID;
BEGIN
    SELECT placa_pod, ROWID INTO vPlacaPod, vRowid
    FROM Pracownicy
    WHERE nazwisko = pNazwisko;

    IF vPlacaPod - pKwotaKary <= 100 THEN
        RAISE_APPLICATION_ERROR(-20001,
        'Zarobki pracownika muszą przekraczać 100. Operacja anulowana.');
    ELSE
        UPDATE Pracownicy
        SET placa_pod = placa_pod - pKwotaKary
        WHERE ROWID = vRowid;
END IF;
END Kara;
/
BEGIN
    Kara('MAREK', 500);
END;
/
CREATE OR REPLACE PROCEDURE UsunZespol(pIdZesp IN NUMBER) IS
    vIluPracownikow NUMBER;
    exPracownicyWZespole EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO vIluPracownikow
    FROM Pracownicy WHERE id_zesp = pIdZesp;
    IF (vIluPracownikow > 0) THEN
        RAISE exPracownicyWZespole;
    END IF;
    DELETE FROM zespoly
    WHERE id_zesp = pIdZesp;
    DBMS_OUTPUT.PUT_LINE('Zespół został usunięty!');
EXCEPTION
    WHEN exPracownicyWZespole THEN
        DBMS_OUTPUT.PUT_LINE('Do zespołu są przypisani pracownicy. ' ||
        'Usunięcie anulowane!');
END UsunZespol;
/
BEGIN
    UsunZespol(10);
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

    exNiepoprawnyZespol EXCEPTION;
    exNiepoprawnyIdentyfikator EXCEPTION;
    exPowielenieIdentyfikatora EXCEPTION;

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
        IF SQL%FOUND THEN
            DBMS_OUTPUT.PUT_LINE ('Dodanych rekordów: '|| SQL%ROWCOUNT);
        ELSE
            DBMS_OUTPUT.PUT_LINE ('Nie wstawiono żadnego rekordu!');
        END IF;
    END AddTeam;
    
    PROCEDURE DeleteTeamById
        (pId ZESPOLY.ID_ZESP%TYPE) IS
        vId ZESPOLY.ID_ZESP%TYPE;
    BEGIN
        SELECT id_zesp INTO vId
        FROM ZESPOLY WHERE id_zesp = vId;

        DELETE FROM ZESPOLY WHERE id_zesp = vId;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE exNiepoprawnyIdentyfikator;

    END DeleteTeamById;

    PROCEDURE DeleteTeamByName
        (pName ZESPOLY.NAZWA%TYPE) IS
        vNazwa ZESPOLY.NAZWA%TYPE;
    BEGIN
        SELECT nazwa INTO vNazwa
        FROM ZESPOLY WHERE nazwa = pName;

        DELETE FROM ZESPOLY WHERE nazwa = vNazwa;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE exNiepoprawnyZespol;

    END DeleteTeamByName;
    
    PROCEDURE ModifyTeamData
        (pId ZESPOLY.ID_ZESP%TYPE,
            pName ZESPOLY.NAZWA%TYPE,
            pAddress ZESPOLY.ADRES%TYPE) IS
        vId ZESPOLY.ID_ZESP%TYPE;
    BEGIN
        SELECT id_zesp INTO vId
        FROM ZESPOLY WHERE id_zesp = vId;

        UPDATE ZESPOLY
        SET nazwa = pName, adres = pAddress
        WHERE id_zesp = vId;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE exNiepoprawnyIdentyfikator;
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

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE exNiepoprawnyZespol;

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

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE exNiepoprawnyIdentyfikator;

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

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE exNiepoprawnyIdentyfikator;

        RETURN vAddress;
    END GetTeamAddress;
END IntZespoly;
/
DECLARE
    vId PRACOWNICY.ID_PRAC%TYPE;
BEGIN
    INTZESPOLY.MODIFYTEAMDATA(PID  => 123 /*IN NUMBER(4)*/,
                              PNAME  => 'test' /*IN VARCHAR2*/,
                              PADDRESS  => 'test'/*IN VARCHAR2*/);

    EXCEPTION
        WHEN INTZESPOLY.exNiepoprawnyZespol THEN
            RAISE_APPLICATION_ERROR(-20001, 'Podano nazwe nieistniejącego zespołu!');
        
        WHEN INTZESPOLY.exNiepoprawnyIdentyfikator THEN
            RAISE_APPLICATION_ERROR(-20000, 'Podano nazwe nieistniejącego zespołu!');
END;