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
