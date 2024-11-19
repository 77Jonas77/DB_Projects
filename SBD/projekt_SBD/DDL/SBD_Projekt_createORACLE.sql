-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2023-12-28 21:18:15.962

-- tables
-- Table: Firma
CREATE TABLE Firma (
    IdFirma integer  NOT NULL,
    Nazwa varchar2(50)  NOT NULL,
    NIP char(10)  NOT NULL,
    Adres varchar2(60)  NOT NULL,
    CONSTRAINT Firma_pk PRIMARY KEY (IdFirma)
) ;

-- Table: Osoba
CREATE TABLE Osoba (
    IdOsoba integer  NOT NULL,
    PESEL char(11)  NOT NULL,
    Imie varchar2(30)  NOT NULL,
    Nazwisko varchar2(30)  NOT NULL,
    NrTelefonu varchar2(20)  NOT NULL,
    KrajPochodzenia varchar2(30)  NOT NULL,
    CONSTRAINT Osoba_pk PRIMARY KEY (IdOsoba)
) ;

-- Table: PracownikKlienta
CREATE TABLE PracownikKlienta (
    IdPracownik integer  NOT NULL,
    IdFirma integer  NOT NULL,
    CONSTRAINT PracownikKlienta_pk PRIMARY KEY (IdPracownik)
) ;

-- Table: RodzajSzkolenia
CREATE TABLE RodzajSzkolenia (
    IdRodzaj integer  NOT NULL,
    Nazwa varchar2(50)  NOT NULL,
    CONSTRAINT RodzajSzkolenia_pk PRIMARY KEY (IdRodzaj)
) ;

-- Table: Specjalizacja
CREATE TABLE Specjalizacja (
    IdSpecjalizacji integer  NOT NULL,
    Nazwa varchar2(30)  NOT NULL,
    CONSTRAINT Specjalizacja_pk PRIMARY KEY (IdSpecjalizacji)
) ;

-- Table: SpecjalizacjaTrenera
CREATE TABLE SpecjalizacjaTrenera (
    IdSpecjalizacji integer  NOT NULL,
    IdTrener integer  NOT NULL,
    CONSTRAINT SpecjalizacjaTrenera_pk PRIMARY KEY (IdSpecjalizacji,IdTrener)
) ;

-- Table: Szkolenie
CREATE TABLE Szkolenie (
    IdSzkolenie integer  NOT NULL,
    IdRodzaj integer  NOT NULL,
    IdTrener integer  NOT NULL,
    DataRozpoczecia date  NOT NULL,
    DataZakonczenia date  NULL,
    CONSTRAINT Szkolenie_pk PRIMARY KEY (IdSzkolenie)
) ;

-- Table: Trener
CREATE TABLE Trener (
    IdTrener integer  NOT NULL,
    Wynagrodzenie number(8,2)  NOT NULL,
    IdUmowa integer  NOT NULL,
    DataZatrudnienia date  NOT NULL,
    DataZakonczeniaWspolpracy date  NULL,
    CONSTRAINT Trener_pk PRIMARY KEY (IdTrener)
) ;

-- Table: TypUmowy
CREATE TABLE TypUmowy (
    IdUmowa integer  NOT NULL,
    Nazwa varchar2(30)  NOT NULL,
    CONSTRAINT TypUmowy_pk PRIMARY KEY (IdUmowa)
) ;

-- Table: WynikPracownika
CREATE TABLE WynikPracownika (
    IdSzkolenie integer  NOT NULL,
    IdPracownik integer  NOT NULL,
    Wynik integer  NULL,
    CONSTRAINT WynikPracownika_pk PRIMARY KEY (IdSzkolenie,IdPracownik)
) ;

-- foreign keys
-- Reference: PracownikKlienta_Firma (table: PracownikKlienta)
ALTER TABLE PracownikKlienta ADD CONSTRAINT PracownikKlienta_Firma
    FOREIGN KEY (IdFirma)
    REFERENCES Firma (IdFirma);

-- Reference: PracownikKlienta_Osoba (table: PracownikKlienta)
ALTER TABLE PracownikKlienta ADD CONSTRAINT PracownikKlienta_Osoba
    FOREIGN KEY (IdPracownik)
    REFERENCES Osoba (IdOsoba);

-- Reference: Pracownik_Osoba (table: Trener)
ALTER TABLE Trener ADD CONSTRAINT Pracownik_Osoba
    FOREIGN KEY (IdTrener)
    REFERENCES Osoba (IdOsoba);

-- Reference: SpecTrenera_Spec (table: SpecjalizacjaTrenera)
ALTER TABLE SpecjalizacjaTrenera ADD CONSTRAINT SpecTrenera_Spec
    FOREIGN KEY (IdSpecjalizacji)
    REFERENCES Specjalizacja (IdSpecjalizacji);

-- Reference: SpecjalizacjaTrenera_Pracownik (table: SpecjalizacjaTrenera)
ALTER TABLE SpecjalizacjaTrenera ADD CONSTRAINT SpecjalizacjaTrenera_Pracownik
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

-- Reference: Trener_TypUmowy (table: Trener)
ALTER TABLE Trener ADD CONSTRAINT Trener_TypUmowy
    FOREIGN KEY (IdUmowa)
    REFERENCES TypUmowy (IdUmowa);

-- Reference: WynikPrac_PracKlienta (table: WynikPracownika)
ALTER TABLE WynikPracownika ADD CONSTRAINT WynikPrac_PracKlienta
    FOREIGN KEY (IdPracownik)
    REFERENCES PracownikKlienta (IdPracownik);

-- Reference: WynikPracownika_Szkolenie (table: WynikPracownika)
ALTER TABLE WynikPracownika ADD CONSTRAINT WynikPracownika_Szkolenie
    FOREIGN KEY (IdSzkolenie)
    REFERENCES Szkolenie (IdSzkolenie);

-- End of file.

