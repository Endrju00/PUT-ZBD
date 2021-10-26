SET SERVEROUTPUT ON;

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
CREATE TABLE DzienikOperacji (
    DATA_OPERACJI DATE,
    TYP_OPERACJI VARCHAR2(6),
    NAZWA_TABELI VARCHAR(20),
    LICZBA_REKORDOW NUMBER
);
/
SELECT * FROM DzienikOperacji;
/
CREATE OR REPLACE TRIGGER LogujOperacje
    AFTER UPDATE OR INSERT OR DELETE ON ZESPOLY
DECLARE 
    vData DzienikOperacji.DATA_OPERACJI%TYPE;
    vTyp DzienikOperacji.TYP_OPERACJI%TYPE;
    vNazwa DzienikOperacji.NAZWA_TABELI%TYPE;
    vLiczba DzienikOperacji.LICZBA_REKORDOW%TYPE;
BEGIN
    vData := SYSDATE;
    vNazwa := 'PRACOWNICY';
    SELECT COUNT(id_zesp) INTO vLiczba FROM ZESPOLY;
    CASE
        WHEN INSERTING THEN
            vTyp := 'INSERT';
        WHEN DELETING THEN
            vTYP := 'DELETE';
        WHEN UPDATING THEN
            vTYP := 'UPDATE';
    END CASE;
END;
/
BEGIN
    INSERT INTO ZESPOLY(id_zesp, nazwa, adres)
    VALUES(120, 'TEST', 'TEST');
END;