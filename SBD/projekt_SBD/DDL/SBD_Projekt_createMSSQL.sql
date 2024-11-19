-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2023-12-28 21:14:57.145

-- tables
-- Table: Firma
CREATE TABLE Firma (
    IdFirma int  NOT NULL,
    Nazwa varchar(50)  NOT NULL,
    NIP char(10)  NOT NULL,
    Adres varchar(60)  NOT NULL,
    CONSTRAINT Firma_pk PRIMARY KEY  (IdFirma)
);

-- Table: Osoba
CREATE TABLE Osoba (
    IdOsoba int  NOT NULL,
    PESEL char(11)  NOT NULL,
    Imie varchar(30)  NOT NULL,
    Nazwisko varchar(30)  NOT NULL,
    NrTelefonu varchar(20)  NOT NULL,
    KrajPochodzenia varchar(30)  NOT NULL,
    CONSTRAINT Osoba_pk PRIMARY KEY  (IdOsoba)
);

-- Table: PracownikKlienta
CREATE TABLE PracownikKlienta (
    IdPracownik int  NOT NULL,
    IdFirma int  NOT NULL,
    CONSTRAINT PracownikKlienta_pk PRIMARY KEY  (IdPracownik)
);

-- Table: RodzajSzkolenia
CREATE TABLE RodzajSzkolenia (
    IdRodzaj int  NOT NULL,
    Nazwa varchar(50)  NOT NULL,
    CONSTRAINT RodzajSzkolenia_pk PRIMARY KEY  (IdRodzaj)
);

-- Table: Specjalizacja
CREATE TABLE Specjalizacja (
    IdSpecjalizacji int  NOT NULL,
    Nazwa varchar(30)  NOT NULL,
    CONSTRAINT Specjalizacja_pk PRIMARY KEY  (IdSpecjalizacji)
);

-- Table: SpecjalizacjaTrenera
CREATE TABLE SpecjalizacjaTrenera (
    IdSpecjalizacji int  NOT NULL,
    IdTrener int  NOT NULL,
    CONSTRAINT SpecjalizacjaTrenera_pk PRIMARY KEY  (IdSpecjalizacji,IdTrener)
);

-- Table: Szkolenie
CREATE TABLE Szkolenie (
    IdSzkolenie int  NOT NULL,
    IdRodzaj int  NOT NULL,
    IdTrener int  NOT NULL,
    DataRozpoczecia date  NOT NULL,
    DataZakonczenia date  NULL,
    CONSTRAINT Szkolenie_pk PRIMARY KEY  (IdSzkolenie)
);

-- Table: Trener
CREATE TABLE Trener (
    IdTrener int  NOT NULL,
    Wynagrodzenie numeric(8,2)  NOT NULL,
    IdUmowa int  NOT NULL,
    DataZatrudnienia date  NOT NULL,
    DataZakonczeniaWspolpracy date  NULL,
    CONSTRAINT Trener_pk PRIMARY KEY  (IdTrener)
);

-- Table: TypUmowy
CREATE TABLE TypUmowy (
    IdUmowa int  NOT NULL,
    Nazwa varchar(30)  NOT NULL,
    CONSTRAINT TypUmowy_pk PRIMARY KEY  (IdUmowa)
);

-- Table: WynikPracownika
CREATE TABLE WynikPracownika (
    IdSzkolenie int  NOT NULL,
    IdPracownik int  NOT NULL,
    Wynik int  NULL,
    CONSTRAINT WynikPracownika_pk PRIMARY KEY  (IdSzkolenie,IdPracownik)
);

-- foreign keys
-- Reference: PracownikKlienta_Firma (table: PracownikKlienta)
ALTER TABLE PracownikKlienta ADD CONSTRAINT PracownikKlienta_Firma
    FOREIGN KEY (IdFirma)
    REFERENCES Firma (IdFirma);

-- Reference: PracownikKlienta_Osoba (table: PracownikKlienta)
ALTER TABLE PracownikKlienta ADD CONSTRAINT PracownikKlienta_Osoba
    FOREIGN KEY (IdPracownik)
    REFERENCES Osoba (IdOsoba);

-- Reference: SpecjalizacjaTrenera_Specjalizacja (table: SpecjalizacjaTrenera)
ALTER TABLE SpecjalizacjaTrenera ADD CONSTRAINT SpecjalizacjaTrenera_Specjalizacja
    FOREIGN KEY (IdSpecjalizacji)
    REFERENCES Specjalizacja (IdSpecjalizacji);

-- Reference: SpecjalizacjaTrenera_Trener (table: SpecjalizacjaTrenera)
ALTER TABLE SpecjalizacjaTrenera ADD CONSTRAINT SpecjalizacjaTrenera_Trener
    FOREIGN KEY (IdTrener)
    REFERENCES Trener (IdTrener);

-- Reference: Szkolenie_RodzajSzkolenia (table: Szkolenie)
ALTER TABLE Szkolenie ADD CONSTRAINT Szkolenie_RodzajSzkolenia
    FOREIGN KEY (IdRodzaj)
    REFERENCES RodzajSzkolenia (IdRodzaj);

-- Reference: Szkolenie_Trener (table: Szkolenie)
ALTER TABLE Szkolenie ADD CONSTRAINT Szkolenie_Trener
    FOREIGN KEY (IdTrener)
    REFERENCES Trener (IdTrener);

-- Reference: Trener_Osoba (table: Trener)
ALTER TABLE Trener ADD CONSTRAINT Trener_Osoba
    FOREIGN KEY (IdTrener)
    REFERENCES Osoba (IdOsoba);

-- Reference: Trener_TypUmowy (table: Trener)
ALTER TABLE Trener ADD CONSTRAINT Trener_TypUmowy
    FOREIGN KEY (IdUmowa)
    REFERENCES TypUmowy (IdUmowa);

-- Reference: WynikPracownika_PracownikKlienta (table: WynikPracownika)
ALTER TABLE WynikPracownika ADD CONSTRAINT WynikPracownika_PracownikKlienta
    FOREIGN KEY (IdPracownik)
    REFERENCES PracownikKlienta (IdPracownik);

-- Reference: WynikPracownika_Szkolenie (table: WynikPracownika)
ALTER TABLE WynikPracownika ADD CONSTRAINT WynikPracownika_Szkolenie
    FOREIGN KEY (IdSzkolenie)
    REFERENCES Szkolenie (IdSzkolenie);

-- End of file.

