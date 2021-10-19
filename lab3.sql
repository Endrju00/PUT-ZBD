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
            SET placa_dod = placa_dod + 100
            WHERE CURRENT OF cPodwyzkaUsunStazystow;
        
        ELSIF vPracownik.nazwa = 'ADMINISTRACJA' THEN
            UPDATE PRACOWNICy
            SET placa_dod = placa_dod + 150
            WHERE CURRENT OF cPodwyzkaUsunStazystow;

        ELSIF vPracownik.etat = 'STAZYSTA' THEN
            DELETE FROM PRACOWNICY
            WHERE CURRENT OF cPodwyzkaUsunStazystow;
        END IF;

    END LOOP;
END;
/
SELECT nazwisko, placa_dod, nazwa 
from PRACOWNICY JOIN ZESPOLY using(id_zesp);
