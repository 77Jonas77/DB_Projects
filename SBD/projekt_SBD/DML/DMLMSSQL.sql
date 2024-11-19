-- Wstawianie nowych danych do tabeli Firma
INSERT INTO Firma (IdFirma, Nazwa, NIP, Adres)
VALUES (1, 'Firma A', '1111111111', 'ul. 1 Maja 1'),
       (2, 'Firma B', '2222222222', 'ul. 3 Maja 2'),
       (3, 'Firma C', '3333333333', 'ul. 10 Lutego 3'),
       (4, 'Firma D', '4444444444', 'ul. Jagiellońska 4'),
       (5, 'Firma E', '5555555555', 'ul. Mickiewicza 5');

-- Wstawianie nowych danych do tabeli Osoba
INSERT INTO Osoba (IdOsoba, PESEL, Imie, Nazwisko, NrTelefonu, KrajPochodzenia)
VALUES (1, '11111111111', 'Jan', 'Nowak', '111-222-333', 'Polska'),
       (2, '22222222222', 'Anna', 'Kowalska', '444-555-666', 'Polska'),
       (3, '33333333333', 'Adam', 'Nowakowski', '777-888-999', 'Polska'),
       (4, '44444444444', 'Ewa', 'Kowalczyk', '111-222-333', 'Polska'),
       (5, '55555555555', 'Tomasz', 'Lis', '444-555-666', 'Polska');

-- Wstawianie nowych danych do tabeli PracownikKlienta
INSERT INTO PracownikKlienta (IdPracownik, IdFirma)
VALUES (1, 1),
       (2, 2),
       (3, 3),
       (4, 4),
       (5, 5);

-- Wstawianie nowych danych do tabeli RodzajSzkolenia
INSERT INTO RodzajSzkolenia (IdRodzaj, Nazwa)
VALUES (1, 'Szkolenie A'),
       (2, 'Szkolenie B'),
       (3, 'Szkolenie C'),
       (4, 'Szkolenie D'),
       (5, 'Szkolenie E');

-- Wstawianie nowych danych do tabeli Specjalizacja
INSERT INTO Specjalizacja (IdSpecjalizacji, Nazwa)
VALUES (1, 'Specjalizacja A'),
       (2, 'Specjalizacja B'),
       (3, 'Specjalizacja C'),
       (4, 'Specjalizacja D'),
       (5, 'Specjalizacja E');

-- Wstawianie nowych danych do tabeli TypUmowy
INSERT INTO TypUmowy (IdUmowa, Nazwa)
VALUES (1, 'Umowa A'),
       (2, 'Umowa B'),
       (3, 'Umowa C'),
       (4, 'Umowa D'),
       (5, 'Umowa E');

-- Wstawianie nowych danych do tabeli Trener
INSERT INTO Trener (IdTrener, Wynagrodzenie, IdUmowa, DataZatrudnienia, DataZakonczeniaWspolpracy)
VALUES (1, 7000.00, 1, '2022-01-01', NULL),
       (2, 8000.00, 2, '2022-02-01', '2022-12-31'), -- Data zakończenia współpracy dla trenera o IdTrener=2
       (3, 9000.00, 3, '2022-03-01', NULL),
       (4, 10000.00, 4, '2022-04-01', NULL),
       (5, 11000.00, 5, '2022-05-01', NULL);

-- Wstawianie nowych danych do tabeli SpecjalizacjaTrenera
INSERT INTO SpecjalizacjaTrenera (IdSpecjalizacji, IdTrener)
VALUES (1, 1),
       (2, 2),
       (3, 3),
       (4, 4),
       (5, 5);

-- Wstawianie nowych danych do tabeli Szkolenie
INSERT INTO Szkolenie (IdSzkolenie, IdRodzaj, IdTrener, DataRozpoczecia, DataZakonczenia)
VALUES (1, 1, 1, '2023-03-01', '2023-03-05'),
       (2, 2, 2, '2023-04-01', NULL),
       (3, 3, 3, '2023-05-01', '2023-05-15'),
       (4, 4, 4, '2023-06-01', '2023-06-08'),
       (5, 5, 5, '2023-07-01', '2023-07-12');

-- Wstawianie nowych danych do tabeli WynikPracownika
INSERT INTO WynikPracownika (IdSzkolenie, IdPracownik, Wynik)
VALUES (1, 1, 85),
       (2, 2, 92),
       (3, 3, 78),
       (4, 4, 95),
       (5, 5, 88);
