SET SERVEROUTPUT ON;
SET AUTOCOMMIT OFF;

CREATE TRIGGER PoPoleceniu
    AFTER UPDATE ON PRACOWNICY
BEGIN
    DBMS_OUTPUT.PUT_LINE('Zmieniono dane tabeli Pracownicy!');
END;
/
CREATE OR REPLACE TRIGGER PoPoleceniu
    AFTER INSERT OR DELETE OR UPDATE ON Pracownicy
DECLARE
    vKomunikat VARCHAR(50);
BEGIN
    CASE
    WHEN INSERTING THEN
    vKomunikat := 'Wstawiono dane do tabeli Pracownicy!';
    WHEN DELETING THEN
    vKomunikat := 'Usunięto dane z tabeli Pracownicy!';
    WHEN UPDATING THEN
    vKomunikat := 'Zmieniono dane tabeli Pracownicy!';
    END CASE;
    DBMS_OUTPUT.PUT_LINE(vKomunikat);
END;
/

--zad1
CREATE TABLE DziennikOperacji (
    DATA_OPERACJI DATE,
    TYP_OPERACJI VARCHAR2(6),
    NAZWA_TABELI VARCHAR(20),
    LICZBA_REKORDOW NUMBER
);
/
SELECT * FROM DziennikOperacji;
/
CREATE OR REPLACE TRIGGER LogujOperacje
    AFTER UPDATE OR INSERT OR DELETE ON ZESPOLY
DECLARE 
    vData DziennikOperacji.DATA_OPERACJI%TYPE;
    vTyp DziennikOperacji.TYP_OPERACJI%TYPE;
    vNazwa DziennikOperacji.NAZWA_TABELI%TYPE;
    vLiczba DziennikOperacji.LICZBA_REKORDOW%TYPE;
BEGIN
    vData := SYSDATE;
    vNazwa := 'ZESPOLY';
    SELECT COUNT(id_zesp) INTO vLiczba FROM ZESPOLY;
    CASE
        WHEN INSERTING THEN
            vTyp := 'INSERT';
        WHEN DELETING THEN
            vTYP := 'DELETE';
        WHEN UPDATING THEN
            vTYP := 'UPDATE';
    END CASE;

    INSERT INTO DZIENNIKOPERACJI(DATA_OPERACJI, TYP_OPERACJI, NAZWA_TABELI, LICZBA_REKORDOW)
    VALUES(vData, vTyp, vNazwa, vLiczba);
END;
/
BEGIN
    INSERT INTO ZESPOLY(id_zesp, nazwa, adres)
    VALUES(120, 'TEST', 'TEST');
END;
/
SELECT * FROM DZIENNIKOPERACJI;
/

--zad2
CREATE OR REPLACE TRIGGER PokazPlace
    BEFORE UPDATE OF placa_pod ON Pracownicy
    FOR EACH ROW
    WHEN (OLD.placa_pod <> NEW.placa_pod OR OLD.placa_pod IS NULL OR NEW.placa_pod IS NULL)
BEGIN
    DBMS_OUTPUT.PUT_LINE('Pracownik ' || :OLD.nazwisko);
    IF (:OLD.placa_pod IS NULL) THEN
        DBMS_OUTPUT.PUT_LINE('Płaca przed modyfikacją: NULL');
    ELSE 
        DBMS_OUTPUT.PUT_LINE('Płaca przed modyfikacją: ' || :OLD.placa_pod);
    END IF;
    
    IF (:NEW.placa_pod IS NULL) THEN
        DBMS_OUTPUT.PUT_LINE('Płaca po modyfikacji: NULL');
    ELSE     
        DBMS_OUTPUT.PUT_LINE('Płaca po modyfikacji: ' || :NEW.placa_pod);
    END IF;
END;
/
CREATE TRIGGER WymuszajPlace
    BEFORE INSERT OR UPDATE OF placa_pod ON Pracownicy
    FOR EACH ROW
    WHEN (NEW.etat IS NOT NULL)
DECLARE
    vPlacaMin Etaty.placa_min%TYPE;
    vPlacaMax Etaty.placa_max%TYPE;
BEGIN
    SELECT placa_min, placa_max
    INTO vPlacaMin, vPlacaMax
    FROM Etaty WHERE nazwa = :NEW.etat;
    IF :NEW.placa_pod NOT BETWEEN vPlacaMin AND vPlacaMax THEN
    RAISE_APPLICATION_ERROR(-20001, 'Płaca poza zakresem dla etatu!');
    END IF;
END;
/

--zad3
CREATE OR REPLACE TRIGGER UzupelnijPlace
    BEFORE INSERT ON Pracownicy
    FOR EACH ROW
    WHEN ((NEW.etat IS NOT NULL AND NEW.PLACA_POD IS NULL) OR NEW.PLACA_DOD IS NULL) 
DECLARE
    vPlacaMin Etaty.placa_min%TYPE;
BEGIN
    SELECT placa_min
    INTO vPlacaMin
    FROM Etaty WHERE nazwa = :NEW.etat;

    IF :NEW.etat IS NOT NULL AND :NEW.placa_pod IS NULL THEN
        :NEW.placa_pod := vPlacaMin;
    END IF;

    IF :NEW.placa_dod IS NULL THEN
        :NEW.placa_dod := 0;
    END IF;
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
END;
/

--zad4
SELECT MAX(ID_ZESP) FROM ZESPOLY;

CREATE SEQUENCE SEQ_Zespoly
START WITH 51
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER UzupelnijID
    BEFORE INSERT ON ZESPOLY
    FOR EACH ROW
    WHEN (NEW.ID_ZESP IS NULL)
BEGIN
    :NEW.ID_ZESP := SEQ_Zespoly.nextval;
END;
/
INSERT INTO ZESPOLY(nazwa, adres) VALUES('NOWY', 'brak');

/
CREATE OR REPLACE VIEW StatystykiZespolow(id_zesp, nazwa, liczba_pracownikow) AS
SELECT id_zesp, nazwa, COUNT(id_prac)
FROM ZESPOLY LEFT JOIN PRACOWNICY USING(ID_ZESP)
GROUP BY id_zesp, nazwa
/
CREATE TRIGGER ZamiastInsert
    INSTEAD OF INSERT ON StatystykiZespolow
BEGIN
    INSERT INTO ZESPOLY(id_zesp, nazwa)
    VALUES(:NEW.id_zesp, :NEW.nazwa);
END;
/
INSERT INTO StatystykiZespolow(id_zesp, nazwa,liczba_pracownikow)
VALUES(99, 'NOWY ZESPÓŁ', 0);
/

--zad5
CREATE OR REPLACE VIEW Szefowie(szef, pracownicy) AS
SELECT s.nazwisko, COUNT(p.id_prac)
FROM PRACOWNICY s INNER JOIN PRACOWNICY p ON s.id_prac = p.id_szefa
GROUP BY s.nazwisko;
/
SELECT * FROM Szefowie;
/
CREATE OR REPLACE TRIGGER UsunSzefa
INSTEAD OF DELETE ON Szefowie
DECLARE
    vIdSzefa PRACOWNICY.ID_PRAC%TYPE;
    CURSOR cPodwladniSzefa(pIdSzefa PRACOWNICY.ID_PRAC%TYPE) IS
        SELECT id_prac FROM PRACOWNICY
        WHERE ID_SZEFA = pIdSzefa;
    vLiczbaPodwladnych NUMBER;
BEGIN
    SELECT ID_PRAC INTO vIdSzefa
    FROM PRACOWNICY WHERE NAZWISKO = :OLD.szef;

    FOR vPodwladny IN cPodwladniSzefa(vIdSzefa) LOOP
        SELECT COUNT(*) INTO vLiczbaPodwladnych
        FROM PRACOWNICY WHERE ID_SZEFA = vPodwladny.id_prac;

        IF vLiczbaPodwladnych > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Jeden z podwładnych usuwanego pracownika jest szefem innnych pracowników. Usuwanie anulowane!');
        ELSE
            DELETE FROM PRACOWNICY WHERE ID_PRAC = vPodwladny.id_prac;
        END IF;
    END LOOP;
    DELETE FROM PRACOWNICY WHERE NAZWISKO = :OLD.szef;
END;
/

SELECT * FROM szefowie;
DELETE FROM SZEFOWIE WHERE szef = 'MORZY';
ROLLBACK;



