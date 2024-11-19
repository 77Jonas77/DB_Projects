--PROCEDURA1
--Procedura ma na celu przypisanie podanego w arugmencie pracownika klienta do
--rowniez podanego w arg szkolenia

--EXEC:
--1. Pracownik o podanym id nie istnieje (id: 9 nie ist)
--2. Szkolenie o podanym id nie istnieje (id: 8 nie ist)
--3. Szkolenie o podanym id juz sie zakonczylo (data not null)
--4. Pracownik o podanym id jest juz przypisany do podanego Szkolenia
--5. Pomyslnie przypisano Pracownika do Szkolenia

CREATE PROCEDURE assignPracownikToSzkolenie @IdPracownika int, @IdSzkolenia int
    AS
        BEGIN
            IF @IdPracownika NOT IN (SELECT IdPracownik FROM PracownikKlienta)
                PRINT 'Pracownik o podanym id nie istnieje';
            ELSE IF @IdSzkolenia NOT IN (SELECT IdSzkolenie FROM Szkolenie)
                PRINT 'Szkolenie o podanym id nie istnieje';
            ELSE IF(SELECT DataZakonczenia FROM Szkolenie WHERE IdSzkolenie = @IdSzkolenia) IS NOT NULL
                PRINT 'Szkolenie o podanym id juz sie zakonczylo!';
            ELSE IF @IdSzkolenia IN (SELECT WynikPracownika.IdSzkolenie FROM WynikPracownika INNER JOIN Szkolenie ON WynikPracownika.IdSzkolenie = Szkolenie.IdSzkolenie
                                     WHERE IdPracownik = @IdPracownika AND DataZakonczenia IS NULL)
                PRINT 'Pracownik jest juz przypisany do podanego szkolenia!';
            ELSE
                BEGIN
                    INSERT INTO WynikPracownika(IdSzkolenie, IdPracownik, Wynik) VALUES (@IdPracownika,@IdSzkolenia,NULL);
                    PRINT 'Pracownik o id: ' + CAST(@IdPracownika AS VARCHAR(5)) + ' zostal pomyslnie przypisany do szkolenia o id: ' + CAST(@IdSzkolenia AS VARCHAR(5));
                END;
        END;

EXEC assignPracownikToSzkolenie 9,1;
EXEC assignPracownikToSzkolenie 1,8;
EXEC assignPracownikToSzkolenie 1,1;
EXEC assignPracownikToSzkolenie 2,2;
EXEC assignPracownikToSzkolenie 1,2;


--PROCEDURA2
--Procedura ma na celu stworzenie szkolenia z podanym w argumencie Trenerem i Rodzaju
--Sprawdza czy podane jako argument dane istnieja (i wypisuje komunikat, jesli nie)

--EXEC:
--1. Podany rodzaj szkolenia nie istnieje
--2. Trener o tym id nie istnieje
--3. Trener o tym id nie jest juz zatrudniony
--4. Szkolenie zostalo utworzone dla podanego IdTrenera i IdRodzaju

CREATE PROCEDURE createSzkolenie @IdTrener int, @NazwaRodzaj Varchar(50)
    AS
    BEGIN
    SET NOCOUNT ON;
    IF @NazwaRodzaj NOT IN (SELECT Nazwa FROM RodzajSzkolenia)
        PRINT 'Rodzaj o nazwie: ' + CAST(@NazwaRodzaj AS Varchar(50)) + ' nie istnieje, szkolenie nie zostalo utworzone';
    ELSE IF @IdTrener NOT IN (SELECT IdTrener FROM Trener)
        PRINT 'Trener o id: ' + CAST(@IdTrener AS VARCHAR(5)) + ' nie istnieje, szkolenie nie zostalo utworzone';
    ELSE IF (SELECT DataZakonczeniaWspolpracy FROM Trener WHERE IdTrener = @IdTrener) IS NOT NULL
        PRINT 'Trener o id: ' + CAST(@IdTrener AS VARCHAR(5)) + ' nie jest juz zatrudniony w naszej firmie';
    ELSE
        BEGIN
        DECLARE @IdSzkolenia int, @IdRodzaj int;
        SELECT @IdSzkolenia = MAX(IdSzkolenie) + 1 FROM Szkolenie;
        SELECT @IdRodzaj = IdRodzaj from RodzajSzkolenia WHERE Nazwa = @NazwaRodzaj;
        BEGIN TRY
            INSERT INTO Szkolenie(idszkolenie, idrodzaj, idtrener, datarozpoczecia, datazakonczenia)
            VALUES (@IdSzkolenia, @IdRodzaj,@IdTrener,GETDATE(),NULL);
            PRINT 'Szkolenie o id: ' + CAST(@IdSzkolenia AS VARCHAR(5)) + ' zostalo utworzone';
        END TRY
        BEGIN CATCH
            RAISERROR ('Cos poszlo nie tak... Nie udalo sie utworzyc szkolenia!',16,1);
            ROLLBACK;
        end catch;
        END;
    END;

EXEC createSzkolenie 1,'blednyRodzaj';
EXEC createSzkolenie 8,'Szkolenie A';
EXEC createSzkolenie 2,'Szkolenie A';
EXEC createSzkolenie 4,'Szkolenie A';


--PROCEDURA3
--Procedura ma na celu podac na konsoli nalezna premie dla wszystkich obecnie zatrudnionych trenerow trenerow, ktorzy pracuja wiecej miesiecy
--niz podajemy jako argument. straz = ilosc miesiecy przepracowanych
--bonus wynosi (Wynagrodzenie/100)*@Staz+@IloscSzkolen*100 dla zatrudnionych pracownikow (DataZakonczeniaWspolpracy == NULL)

--EXEC:
--1. Tylko o id 1 otrzyma premie bo ma przepracowane powyzej 22 mies
--2. wszyscy dostana premie (im mniejszy staz tym wieksze zarobki - oliwia niesprawiedliwa ;\)

CREATE PROCEDURE displayPremia @IloscMiesiecy int
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdTrenera int, @Staz int, @Premia numeric(8,2), @IloscSzkolen int;

    DECLARE premia_trenera CURSOR FOR
    SELECT IdTrener, DATEDIFF(MONTH, MIN(DataZatrudnienia), GETDATE()) AS Staz
    FROM Trener
    WHERE DataZakonczeniaWspolpracy IS NULL
    GROUP BY IdTrener;

    OPEN premia_trenera;
    FETCH NEXT FROM premia_trenera INTO @IdTrenera, @Staz;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @Staz < @IloscMiesiecy
            PRINT 'Trener o id: ' + CAST(@IdTrenera AS VARCHAR(5)) + ' nie otrzymuje premii';
        ELSE
        BEGIN
            SELECT @IloscSzkolen = COUNT(IdSzkolenie)
            FROM Szkolenie
            INNER JOIN Trener ON Szkolenie.IdTrener = Trener.IdTrener
            WHERE Trener.IdTrener = @IdTrenera AND DataZakonczenia IS NOT NULL;

            SELECT @Premia = ROUND((Wynagrodzenie/100)*@Staz+@IloscSzkolen*100,2)
            FROM Trener
            WHERE IdTrener = @IdTrenera;
            PRINT 'Trener o id: ' + CAST(@IdTrenera AS VARCHAR(5)) + N' otrzymuje premie w wysokości: ' + CAST(@Premia AS VARCHAR(10));
        END;

        FETCH NEXT FROM premia_trenera INTO @IdTrenera, @Staz;
    END;

    CLOSE premia_trenera;
    DEALLOCATE premia_trenera;
END;

EXEC displayPremia 22;
EXEC displayPremia 5;


----------------WYZWALACZE----------------
--WYZWALACZ1
--Wyzwalacz nie pozwala:
-- 1. na reczne przypisanie wart do kolumny wynik
-- 2. nie pozwala na przypisanie pracownika do szkolenia na ktore jest juz aktualnie zapisany

--DML:
--1. Wypisany zostanie blad o wpisaniu wyniku w INSERT
--2. Rekord zostanie dodany pomyslnie

CREATE TRIGGER TR_WynikPracownika
    ON WynikPracownika
    FOR INSERT
        AS
            BEGIN
                DECLARE @Wynik int, @IdSzkolenia int, @IdPracownika int;
                SELECT @Wynik = Wynik, @IdSzkolenia = IdSzkolenie, @IdPracownika = IdPracownik from inserted;
                IF @Wynik IS NOT NULL
                    BEGIN
                        RAISERROR('Nie mozna recznie wpisac wartosci dla "Wynik", rekord nie zostal dodany',16,1);
                        ROLLBACK;
                    end
                ELSE
                    PRINT 'Pomyslnie dodano pracownika o id: ' + CAST(@IdPracownika AS VARCHAR(5)) + ' do szkolenia o id: ' + CAST(@IdSzkolenia AS VARCHAR(5));
            END;

INSERT INTO WynikPracownika (IdSzkolenie, IdPracownik, Wynik) VALUES (1, 3, 23);
INSERT INTO WynikPracownika (IdSzkolenie, IdPracownik, Wynik) VALUES (1, 5, NULL);


--WYZWALACZ2
--Nie pozwoli na:
--1. dodanie osoby, ktorej PESEL juz istnieje
--2. --||--  NrTelefonu juz istnieje
--DML:
--1. Nie doda, bo osoba o takim nr PESEL juz istnieje
--2. Nie doda, bo osoba o takim nr telefonu juz istnieje
--3. Pomyslnie doda taka osobe

CREATE TRIGGER TR_Osoba_Insert
    ON Osoba
    INSTEAD OF INSERT
    AS
        BEGIN
            DECLARE @Id int, @Pesel char(11), @NrTel varchar(20), @Imie varchar(30), @Nazwisko varchar(30), @KrajPochodzenia varchar(30);
            SELECT @Id = IdOsoba, @Pesel = Pesel, @NrTel = NrTelefonu, @Imie = Imie, @Nazwisko = Nazwisko, @KrajPochodzenia = KrajPochodzenia FROM inserted;
            IF @Pesel IN (SELECT PESEL FROM Osoba)
                BEGIN
                    RAISERROR ('Osoba o takim nr PESEL juz istnieje! Rekord nie zostal dodany!',16,1);
                end
            ELSE IF @NrTel IN (SELECT NrTelefonu FROM Osoba)
                BEGIN
                    RAISERROR ('Osoba o takim nr telefonu juz istnieje! Rekord nie zostal dodany!',16,1);
                end
            ELSE
            BEGIN
                INSERT INTO Osoba(IdOsoba,PESEL,Imie, Nazwisko,NrTelefonu,KrajPochodzenia) VALUES (@Id,@Pesel,@NrTel,@Imie,@Nazwisko,@KrajPochodzenia);
                PRINT 'Pomyslnie dodano osobe o PESELu: ' + @Pesel + ' i nr telefonu: ' + @NrTel;
            end;
        end;

INSERT INTO Osoba (IdOsoba, PESEL, Imie, Nazwisko, NrTelefonu, KrajPochodzenia) VALUES (7, '11111111111', 'Jan', 'Nowak', '111-222-333', 'Polska')
INSERT INTO Osoba (IdOsoba, PESEL, Imie, Nazwisko, NrTelefonu, KrajPochodzenia) VALUES (7, '11111111113', 'Jan', 'Nowak', '111-222-333', 'Polska')
INSERT INTO Osoba (IdOsoba, PESEL, Imie, Nazwisko, NrTelefonu, KrajPochodzenia) VALUES (7, '11111111112', 'Jan', 'Nowak', '211-222-333', 'Polska')

--WYZWALACZ3
--Wyzwalacz ma nie pozwolic na wprowadzenie daty rozpoczynajacej wczesniejszej od innych rozpoczynajacych
--oraz nie pozwolic wstawic/zmodyfikowac DatyZakonczenia tak, aby byla wczesniejsza od DatyRozpoczecia

--DML:
--pod trigerem


CREATE TRIGGER TR_Szkolenie_Update
    ON Szkolenie
    FOR UPDATE, INSERT
    AS
    BEGIN
        DECLARE @IdSzkolenie int, @IdRodzaj int, @IdTrener int, @DataRoz date, @DataZak date;
        SELECT @IdSzkolenie = IdSzkolenie, @IdRodzaj=IdRodzaj, @IdTrener=IdTrener, @DataRoz=DataRozpoczecia, @DataZak=DataZakonczenia FROM inserted;
        IF(@DataRoz>@DataZak)
            BEGIN
                RAISERROR('DataZakonczenia nie moze byc mniejsza niz DataRozpoczecia! Zmiany nie zostaly zapisane!',16,1);
                ROLLBACK;
            end
        ELSE IF @DataRoz < ANY(SELECT DataRozpoczecia FROM Szkolenie WHERE IdTrener=@IdTrener)
            BEGIN
                RAISERROR('Nie mozna wprowadzic daty rozpoczynajacej wczesniejszej od innych rozpoczynajacych! Zmiany nie zostaly zapisane!',16,1);
                ROLLBACK;
            end
    end;

--poprawne
UPDATE Szkolenie SET DataRozpoczecia = '2023-01-15', DataZakonczenia = '2023-01-20' WHERE IdSzkolenie = 1;
INSERT INTO Szkolenie (IdSzkolenie, IdRodzaj, IdTrener, DataRozpoczecia, DataZakonczenia)
VALUES (6, 1, 1, '2025-01-05', '2025-01-15');
--dataRoz>dataZak
UPDATE Szkolenie SET DataRozpoczecia = '2023-01-25', DataZakonczenia = '2023-01-24' WHERE IdSzkolenie = 1;
INSERT INTO Szkolenie (IdSzkolenie, IdRodzaj, IdTrener, DataRozpoczecia, DataZakonczenia)
VALUES (7, 1, 1, '2025-01-05', '2025-01-04');
--dataRoz wczesniejsza
INSERT INTO Szkolenie (IdSzkolenie, IdRodzaj, IdTrener, DataRozpoczecia, DataZakonczenia)
VALUES (8, 1, 1, '2023-01-05', '2023-01-15');
UPDATE Szkolenie SET DataRozpoczecia = '2022-01-05', DataZakonczenia = '2023-01-10' WHERE IdSzkolenie = 6 and IdTrener=1;
