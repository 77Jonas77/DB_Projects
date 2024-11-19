-- Wstawianie nowych danych do tabeli Firma
INSERT INTO Firma (IdFirma, Nazwa, NIP, Adres)
VALUES (1, 'Firma A', '1111111111', 'ul. 1 Maja 1');
INSERT INTO Firma (IdFirma, Nazwa, NIP, Adres)
VALUES (2, 'Firma B', '2222222222', 'ul. 3 Maja 2');
INSERT INTO Firma (IdFirma, Nazwa, NIP, Adres)
VALUES (3, 'Firma C', '3333333333', 'ul. 10 Lutego 3');
INSERT INTO Firma (IdFirma, Nazwa, NIP, Adres)
VALUES (4, 'Firma D', '4444444444', 'ul. Jagiellońska 4');
INSERT INTO Firma (IdFirma, Nazwa, NIP, Adres)
VALUES (5, 'Firma E', '5555555555', 'ul. Mickiewicza 5');

-- Wstawianie nowych danych do tabeli Osoba
INSERT INTO Osoba (IdOsoba, PESEL, Imie, Nazwisko, NrTelefonu, KrajPochodzenia)
VALUES (1, '11111111111', 'Jan', 'Nowak', '111-222-333', 'Polska');
INSERT INTO Osoba (IdOsoba, PESEL, Imie, Nazwisko, NrTelefonu, KrajPochodzenia)
VALUES (2, '22222222222', 'Anna', 'Kowalska', '444-555-666', 'Polska');
INSERT INTO Osoba (IdOsoba, PESEL, Imie, Nazwisko, NrTelefonu, KrajPochodzenia)
VALUES (3, '33333333333', 'Adam', 'Nowakowski', '777-888-999', 'Polska');
INSERT INTO Osoba (IdOsoba, PESEL, Imie, Nazwisko, NrTelefonu, KrajPochodzenia)
VALUES (4, '44444444444', 'Ewa', 'Kowalczyk', '111-222-333', 'Polska');
INSERT INTO Osoba (IdOsoba, PESEL, Imie, Nazwisko, NrTelefonu, KrajPochodzenia)
VALUES (5, '55555555555', 'Tomasz', 'Lis', '444-555-666', 'Polska');

-- Wstawianie nowych danych do tabeli TypUmowy
INSERT INTO TypUmowy (IdUmowa, Nazwa)
VALUES (1, 'Umowa A');

INSERT INTO TypUmowy (IdUmowa, Nazwa)
VALUES (2, 'Umowa B');

INSERT INTO TypUmowy (IdUmowa, Nazwa)
VALUES (3, 'Umowa C');

INSERT INTO TypUmowy (IdUmowa, Nazwa)
VALUES (4, 'Umowa D');

INSERT INTO TypUmowy (IdUmowa, Nazwa)
VALUES (5, 'Umowa E');

-- Wstawianie nowych danych do tabeli PracownikKlienta
INSERT INTO PracownikKlienta (IdPracownik, IdFirma)
VALUES (1, 1);
INSERT INTO PracownikKlienta (IdPracownik, IdFirma)
VALUES (2, 2);
INSERT INTO PracownikKlienta (IdPracownik, IdFirma)
VALUES (3, 3);
INSERT INTO PracownikKlienta (IdPracownik, IdFirma)
VALUES (4, 4);
INSERT INTO PracownikKlienta (IdPracownik, IdFirma)
VALUES (5, 5);

-- Wstawianie nowych danych do tabeli RodzajSzkolenia
INSERT INTO RodzajSzkolenia (IdRodzaj, Nazwa)
VALUES (1, 'Szkolenie A');
INSERT INTO RodzajSzkolenia (IdRodzaj, Nazwa)
VALUES (2, 'Szkolenie B');
INSERT INTO RodzajSzkolenia (IdRodzaj, Nazwa)
VALUES (3, 'Szkolenie C');
INSERT INTO RodzajSzkolenia (IdRodzaj, Nazwa)
VALUES (4, 'Szkolenie D');
INSERT INTO RodzajSzkolenia (IdRodzaj, Nazwa)
VALUES (5, 'Szkolenie E');

-- Wstawianie nowych danych do tabeli Specjalizacja
INSERT INTO Specjalizacja (IdSpecjalizacji, Nazwa)
VALUES (1, 'Specjalizacja A');
INSERT INTO Specjalizacja (IdSpecjalizacji, Nazwa)
VALUES (2, 'Specjalizacja B');
INSERT INTO Specjalizacja (IdSpecjalizacji, Nazwa)
VALUES (3, 'Specjalizacja C');
INSERT INTO Specjalizacja (IdSpecjalizacji, Nazwa)
VALUES (4, 'Specjalizacja D');
INSERT INTO Specjalizacja (IdSpecjalizacji, Nazwa)
VALUES (5, 'Specjalizacja E');

-- Wstawianie nowych danych do tabeli Trener
INSERT INTO Trener (IdTrener, Wynagrodzenie, IdUmowa, DataZatrudnienia, DataZakonczeniaWspolpracy)
VALUES (1, 7000.00, 1, TO_DATE('2023-01-01', 'YYYY-MM-DD'), NULL);
INSERT INTO Trener (IdTrener, Wynagrodzenie, IdUmowa, DataZatrudnienia, DataZakonczeniaWspolpracy)
VALUES (2, 8000.00, 2, TO_DATE('2023-02-01', 'YYYY-MM-DD'), TO_DATE('2023-03-01', 'YYYY-MM-DD'));
INSERT INTO Trener (IdTrener, Wynagrodzenie, IdUmowa, DataZatrudnienia, DataZakonczeniaWspolpracy)
VALUES (3, 9000.00, 3, TO_DATE('2023-03-01', 'YYYY-MM-DD'), NULL);
INSERT INTO Trener (IdTrener, Wynagrodzenie, IdUmowa, DataZatrudnienia, DataZakonczeniaWspolpracy)
VALUES (4, 10000.00, 4, TO_DATE('2023-04-01', 'YYYY-MM-DD'), NULL);
INSERT INTO Trener (IdTrener, Wynagrodzenie, IdUmowa, DataZatrudnienia, DataZakonczeniaWspolpracy)
VALUES (5, 11000.00, 5, TO_DATE('2023-05-01', 'YYYY-MM-DD'), NULL);

-- Wstawianie nowych danych do tabeli SpecjalizacjaTrenera
INSERT INTO SpecjalizacjaTrenera (IdSpecjalizacji, IdTrener)
VALUES (1, 1);
INSERT INTO SpecjalizacjaTrenera (IdSpecjalizacji, IdTrener)
VALUES (2, 2);
INSERT INTO SpecjalizacjaTrenera (IdSpecjalizacji, IdTrener)
VALUES (3, 3);
INSERT INTO SpecjalizacjaTrenera (IdSpecjalizacji, IdTrener)
VALUES (4, 4);
INSERT INTO SpecjalizacjaTrenera (IdSpecjalizacji, IdTrener)
VALUES (5, 5);

-- Wstawianie nowych danych do tabeli Szkolenie
INSERT INTO Szkolenie (IdSzkolenie, IdRodzaj, IdTrener, DataRozpoczecia, DataZakonczenia)
VALUES (1, 1, 1, TO_DATE('2023-03-01', 'YYYY-MM-DD'), TO_DATE('2023-03-05', 'YYYY-MM-DD'));
INSERT INTO Szkolenie (IdSzkolenie, IdRodzaj, IdTrener, DataRozpoczecia, DataZakonczenia)
VALUES (2, 2, 2, TO_DATE('2023-04-01', 'YYYY-MM-DD'), TO_DATE('2023-04-10', 'YYYY-MM-DD'));
INSERT INTO Szkolenie (IdSzkolenie, IdRodzaj, IdTrener, DataRozpoczecia, DataZakonczenia)
VALUES (3, 3, 3, TO_DATE('2023-05-01', 'YYYY-MM-DD'), NULL);
INSERT INTO Szkolenie (IdSzkolenie, IdRodzaj, IdTrener, DataRozpoczecia, DataZakonczenia)
VALUES (4, 4, 4, TO_DATE('2023-06-01', 'YYYY-MM-DD'), TO_DATE('2023-06-08', 'YYYY-MM-DD'));
INSERT INTO Szkolenie (IdSzkolenie, IdRodzaj, IdTrener, DataRozpoczecia, DataZakonczenia)
VALUES (5, 5, 5, TO_DATE('2023-07-01', 'YYYY-MM-DD'), TO_DATE('2023-07-12', 'YYYY-MM-DD'));

-- Wstawianie nowych danych do tabeli WynikPracownika
INSERT INTO WynikPracownika (IdSzkolenie, IdPracownik, Wynik)
VALUES (1, 1, 85);
INSERT INTO WynikPracownika (IdSzkolenie, IdPracownik, Wynik)
VALUES (2, 2, 92);
INSERT INTO WynikPracownika (IdSzkolenie, IdPracownik, Wynik)
VALUES (3, 3, 78);
INSERT INTO WynikPracownika (IdSzkolenie, IdPracownik, Wynik)
VALUES (4, 4, 95);
INSERT INTO WynikPracownika (IdSzkolenie, IdPracownik, Wynik)
VALUES (5, 5, 88);
