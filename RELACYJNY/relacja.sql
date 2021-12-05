create table Pracownicy(
    id NUMERIC(10) primary key GENERATED ALWAYS AS IDENTITY,
    imie VARCHAR(100) not null,
    nazwisko VARCHAR(100) not null,
    nr_telefonu CHAR(9) not null,
    email VARCHAR(100),
    placa NUMERIC(10, 2) not null,
    ilosc_godzin_tyg NUMERIC(10) not null,
    nazwa_stanowiska VARCHAR(100) references Stanowiska(nazwa) not null 
);

create table Stanowiska(
    nazwa VARCHAR(100) primary key,
    placa_min NUMERIC(10, 2) not null,
    placa_max NUMERIC(10, 2) not null
);

create table Klienci(
    id NUMERIC(10) primary key GENERATED ALWAYS AS IDENTITY,
    imie VARCHAR(100) not null,
    nazwisko VARCHAR(100) not null,
    nr_telefonu CHAR(9) not null,
    email VARCHAR(100),
    kod_karty_rabatowej VARCHAR(100)
);

create table Adresy(
    miasto VARCHAR(100),
    ulica VARCHAR(100),
    nr_ulicy VARCHAR(100),
    kod_pocztowy CHAR(6),
    kraj VARCHAR(100),
    primary key(miasto, ulica, nr_ulicy, kod_pocztowy, kraj)
);

create table Zamowienia(
    numer NUMERIC(10) primary key GENERATED ALWAYS AS IDENTITY,
    data_zlozenia DATE not null,
    status VARCHAR(100) not null,
    komentarz VARCHAR(1000),
    id_pracownika NUMERIC(10) references Pracownicy(id) not null,
    id_klienta NUMERIC(10) references Klienci(id) not null,
    miasto VARCHAR(100) not null,
    ulica VARCHAR(100) not null,
    nr_ulicy VARCHAR(100) not null,
    kod_pocztowy CHAR(6) not null,
    kraj VARCHAR(100) not null,
    foreign key(miasto, ulica, nr_ulicy, kod_pocztowy, kraj) references Adresy(miasto, ulica, nr_ulicy, kod_pocztowy, kraj)
);

create table Platnosci(
    data DATE,
    kwota NUMERIC(10, 2) not null,
    numer_zamowienia NUMERIC(10) references Zamowienia(numer),
    primary key(data, numer_zamowienia)
);

create table Produkty(
    kod NUMERIC(10) primary key,
    nazwa VARCHAR(100) not null,
    opis VARCHAR(1000),
    producent VARCHAR(100) references Producenci(nazwa) not null,
    kategoria VARCHAR(100) references Kategorie(nazwa) not null
);

create table Producenci(
    nazwa VARCHAR(100) primary key,
    strona_www VARCHAR(100)
);

create table Kategorie(
    nazwa VARCHAR(100) primary key,
    nadkategoria VARCHAR(100) references Kategorie(nazwa) null
);

create table Hurtownie(
    nazwa VARCHAR(100) primary key
);

create table Dostarczone_towary(
    data DATE,
    ilosc NUMERIC(10) not null,
    cena_jednostkowa_zakupu NUMERIC(10, 2) not null,
    cena_jednostkowa_sprzedazy NUMERIC(10, 2) not null,
    kod_produktu NUMERIC(10) references Produkty(kod),
    hurtownia VARCHAR(100) references Hurtownie(nazwa),
    primary key(data, kod_produktu, hurtownia)
);

create table Pozycje_w_zamowieniach(
    ilosc_zamawiana NUMERIC(10) not null,
    data DATE,
    kod_produktu NUMERIC(10),
    hurtownia VARCHAR(100),
    numer_zamowienia NUMERIC(10) references Zamowienia(numer),
    foreign key(data, kod_produktu, hurtownia) references Dostarczone_towary(data, kod_produktu, hurtownia),
    primary key(numer_zamowienia, data, kod_produktu, hurtownia)
);

CREATE OR REPLACE FUNCTION CenaZamowienia(pNumerZamowienia IN NUMBER)
    RETURN NUMBER(10, 2) IS
    vCena NUMBER(10, 2)
BEGIN
    SELECT SUM(p.ilosc_zamawiana*d.cena_jednostkowa_sprzedazy) 
    INTO vCena 
    FROM Zamowienia z JOIN Pozycje_w_zamowieniach p ON z.numer=p.numer_zamowienia 
    JOIN Dostarczone_towary d ON p.kod_produktu=d.kod_produktu AND p.data=d.data AND p.hurtownia=d.hurtownia 
    WHERE z.numer=pNumerZamowienia 
    GROUP BY z.numer;
    RETURN vCena
END CenaZamowienia;

CREATE OR REPLACE PROCEDURE Podwyzka
    (pIdPrac IN NUMBER,
    pPodwyzka IN NUMBER) IS
BEGIN
    UPDATE Pracownicy
    SET placa = placa + pPodwyzka
    WHERE id = pIdPrac;
END Podwyzka;
