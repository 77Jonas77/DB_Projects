USE [2019SBD]

--DECLARE @NaszaZmienna int; /SET @NaszaZmienna = 5; PRINT @NaszaZmienna;
--SELECT @NaszaZmienna = id FROM T_Osoba WHERE nazwisko = 'Paches' /wczesniej zadeklarowac i PRINT
--PRINT - jednolity typ danych CAST(@NaszaZmienna AS Varchar(5))

--PROCEDURY
--CREATE/ALTER | CREATE OR ALTER (Nie w 13 wersji) PROCEDURE NaszaProcedura @Liczba1 int = 999 (domyslna wartosc, inaczej null), @Liczba2 int;
--AS
--BEGIN
--PRINT 'Liczba 1 = ' + CAST(@Liczba1 as Varchar(5)) + ', Liczba 2 = ' + CAST(@Liczba2 as Varchar(5));
--PRINT 'Cos jeszcze';
--END;

--EXEC NaszaProcedura DEFAULT(to 999), 22;

--CREATE/ALTER | CREATE OR ALTER (Nie w 13 wersji) PROCEDURE NaszaProcedura @Liczba1 int = 999 (domyslna wartosc, inaczej null), @Liczba2 int, @Info Varchar(50); OUTPUT /OUTPUT - Pozwala zapisywac poza procedura
--AS
--BEGIN
--SET @Info = 'Liczba 1 = ' + CAST(@Liczba1 as Varchar(5)) + ', Liczba 2 = ' + CAST(@Liczba2 as Varchar(5))
--END;

--DECLARE @Informacja Varchar(50)
--EXEC NaszaProcedura DEFAULT(to 999), 22, @Informacja OUTPUT;
--PRINT @Informacja;

--IF-y (odpowiednikiem klamer sa BEGIN i END
--DECLARE @Liczba int = 3;

--IF @Liczba > 0
--PRINT 'Jest wieksza niz 0'
--ELSE
--PRINT 'Jest mniejsza niz 0';

--SET NOCOUNT ON; /wylacza te powiadomienia na dole  --> lepsza wydajnosc
--UPDATE T_PRODUKT SET cena = cena - 0.01;

--PRINT 'Ilosc wierszy zmodyfikowana: ' + CAST(@@ROWCOUNT AS Varchar(5));

--INSERT INTO T_ZAKUP ("Data", Klient) VALUES (GETDATE(),1);
--@@IDENTITY

--DELETE FROM T_ZAKUP WHERE id > 11;

--ZADANIA SBD_LAB04_TSQL_PODSTAWY

--ZAD1
DECLARE @CountRowsOsoba int;
SELECT @CountRowsOsoba = COUNT(*)
FROM T_Osoba;
PRINT 'W tabeli jest ' + CAST(@CountRowsOsoba AS Varchar(5)) + ' osob';

--ZAD2
DECLARE @CountPersonOsoba int;
SELECT @CountPersonOsoba = COUNT(*)
FROM T_Osoba;
IF @CountPersonOsoba < 7
    BEGIN
        INSERT INTO T_OSOBA(Id, Imie, Nazwisko) VALUES (@CountPersonOsoba + 1, 'Thomas', 'Theramenes');
        PRINT 'Dodano nowa osobe';
    END
ELSE
    PRINT 'Nie wstawiono danych';

--ZAD3
ALTER PROCEDURE ProduktyTanszeNiz @MaxPrice int
AS
BEGIN
    SELECT p.Nazwa, p.Cena
    FROM T_PRODUKT p
    WHERE Cena < @MaxPrice;
END
    EXEC ProduktyTanszeNiz 2;

    --ZAD4
    CREATE PROCEDURE AktualizacjaCeny @PlusPrice float = 0.01
    AS
    BEGIN
        SET NOCOUNT ON;
        UPDATE T_PRODUKT SET cena = cena + @PlusPrice;
        PRINT 'Liczba zaktualizowanych rekordow: ' + CAST(@@ROWCOUNT AS Varchar(5));
    END
        EXEC AktualizacjaCeny DEFAULT;

        --ZAD5 /?OUTPUT?
        ALTER PROCEDURE NowyZakup @IdKlient int, @Zakup int OUTPUT
        AS
        BEGIN
            INSERT INTO T_ZAKUP (Data, Klient) VALUES (GETDATE(), @IdKlient);
            SET @Zakup = @@IDENTITY;
            PRINT 'Zarejestrowano nowy zakup o id : ' + CAST(@Zakup AS Varchar(5));
        END

        DECLARE @Zakup int;
            EXEC NowyZakup 2, @Zakup
            PRINT 'Zarejestrowano nowy zakup o id : ' + CAST(@Zakup AS Varchar(5));

            --ZAD6
            CREATE PROCEDURE DodajProduktDoZakupu @Produkt int, @Ilosc int, @Zakup int OUTPUT
            AS
            BEGIN
                IF @PRODUKT NOT IN (SELECT ID FROM T_PRODUKT) OR @Zakup NOT IN (SELECT ID FROM T_ZAKUP) or @Ilosc <= 0
                    PRINT 'Nieprawidlowe dane';
                ELSE
                    BEGIN
                        INSERT INTO T_ListaProduktow(Zakup, Produkt, Ilosc) values (@Zakup, @Produkt, @Zakup);
                        PRINT 'Do zakupu ' + CAST(@Zakup AS VARCHAR(5))
                            + ' dodano produkt ' + CAST(@Produkt AS VARCHAR(5))
                            + N', w ilości: ' + CAST(@Ilosc AS VARCHAR(5));
                    END
            END

            DECLARE @Zakup int;
                EXEC DodajProduktDoZakupu 4, 2, @Zakup = 1;

                --ZAD7
                alter PROCEDURE DanePracownika @IdPracownik int, @Imie VARCHAR(30) OUTPUT, @Nazwisko VARCHAR(30) OUTPUT
                AS
                BEGIN
                    IF @IdPracownik not in (select T_Pracownik.Id from T_Pracownik)
                        PRINT 'Pracownik o podanym id nie istnieje';
                    ELSE
                        BEGIN
                            SET @Imie = (SELECT Imie FROM T_Osoba WHERE Id = @IdPracownik);
                            SET @Nazwisko = (SELECT Nazwisko FROM T_Osoba WHERE Id = @IdPracownik);
                            PRINT 'Dane: ' + @Imie + '_' + @Nazwisko;
                        END
                end

                DECLARE @Imie varchar(50), @Nazwisko varchar(50);
                    EXEC DanePracownika 1, @Imie, @Nazwisko;
                    PRINT 'Dane: ' + @Imie + '_' + @Nazwisko;

                    --ZAD8
                    CREATE PROCEDURE DodajProdukt @Nazwa VARCHAR(50), @Cena MONEY, @Kategoria INT
                    AS
                    BEGIN
                        IF @Nazwa IN (SELECT Nazwa FROM T_Produkt)
                            PRINT N'Produkt o takiej nazwie już istnieje. Nie wprowadzono żadnych zmian do tabeli.';
                        ELSE
                            IF @Kategoria NOT IN (SELECT Id FROM T_Kategoria)
                                PRINT N'Podana kategoria nie istnieje, produkt nie został dodany';
                            ELSE
                                BEGIN
                                    INSERT INTO T_Produkt
                                    VALUES ((SELECT MAX(Id) + 1 FROM T_Produkt), @Nazwa, @Cena, @Kategoria);
                                    PRINT N'Pomyślnie dodano nowy produkt'
                                END
                    END

                        --ZAD9
                        CREATE PROCEDURE ZaktualizujStanowiskoPracownika @IdPracownika int, @IdStanowiska int
                        AS
                        BEGIN
                            SET NOCOUNT ON;
                            IF (@IdPracownika) NOT IN (SELECT T_Pracownik.ID FROM T_Pracownik) OR
                               (@IdStanowiska) NOT IN (SELECT T_Stanowisko.Id FROM T_Stanowisko)
                                PRINT 'Podano nieprawidlowe dane';
                            ELSE
                                IF @IdStanowiska IN (SELECT z.Stanowisko
                                                     FROM T_Zatrudnienie z
                                                     WHERE z.Pracownik = @IdPracownika
                                                       AND z.Do IS NULL)
                                    PRINT N'Pracownik jest już przypisany na to stanowisko';
                                ELSE
                                    IF (CAST(GETDATE() AS DATE) IN (SELECT T_Zatrudnienie.DO
                                                                    FROM T_Zatrudnienie
                                                                    WHERE Pracownik = @IdPracownika
                                                                      AND T_Zatrudnienie.DO is not null
                                                                      AND T_Zatrudnienie.Stanowisko = @IdStanowiska))
                                        PRINT N'Zmiany nie zostały zapisane, stanowisko można aktualizować tylko raz dziennie';
                                    ELSE
                                        BEGIN
                                            UPDATE T_Zatrudnienie
                                            SET Do = GETDATE()
                                            WHERE Pracownik = @IdPracownika
                                              AND Do IS NULL;
                                            INSERT INTO T_Zatrudnienie
                                            VALUES (@IdPracownika, @IdStanowiska, GETDATE(), NULL);
                                            PRINT N'Pomyślnie zaktualizowano stanowisko pracownika';
                                        end
                        end




