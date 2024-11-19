--ZAD1
DECLARE @IloscOsob int;
SELECT @IloscOsob = COUNT(*)
FROM T_OSOBA;
PRINT 'W tabeli jest ' + CAST(@IloscOsob as Varchar(5)) + ' osob';

--ZAD2
DECLARE @IloscOs int, @Id int;
SELECT @IloscOs = COUNT(*), @Id = MAX(T_Osoba.Id) + 1
FROM T_OSOBA;
IF (@IloscOs < 7)
    BEGIN
        INSERT INTO T_Osoba(Id, Imie, Nazwisko) VALUES (@Id, 'Thomas', 'Theramenes');
        PRINT 'Nowy lepek zostal dodany';
    end
ELSE
    PRINT 'Nikogo nie wstawiono';


--ZAD3
CREATE PROCEDURE ProduktyTanszeNiz @Cena money
AS
begin
    SELECT Nazwa, Cena
    FROM T_Produkt
    where Cena < @Cena;

    EXEC ProduktyTanszeNiz 1.55

    --ZAD4
    CREATE PROCEDURE AktCeny @IncreaseValue money = 0.01
    AS
    BEGIN
        SET NOCOUNT ON;
        UPDATE T_Produkt
        SET Cena = Cena + @IncreaseValue;
        PRINT 'Ilosc zakt rekordow: ' + @@ROWCOUNT;
    end;
end;
    --EXEC AktCeny DEFAULT;

    --ZAD5
    CREATE PROCEDURE NewPurcharse @IdKlienta int, @IdZakup int OUTPUT --OUTPUT po prostu nam zwraca dana wartosc (cos jak funkcj)
    AS
    BEGIN
        INSERT INTO T_Zakup (Data, Klient) VALUES (GETDATE(), @IdKlienta);
        SET @IdZakup = @@identity;
        PRINT 'Zarejstrowano zakup o id: ' + CAST(@IdZakup AS VARCHAR(5));
    end;

    DECLARE @ZakupId int;

        EXEC NewPurcharse 2, @ZakupId OUTPUT;

        --ZAD6
        CREATE PROCEDURE AddProductToPurchase @IdProduktu int, @Ilosc int, @Zakup int
        AS
        BEGIN
            IF @IdProduktu NOT IN (SELECT 1 FROM T_Produkt)
                PRINT 'Nie ma takiego produktu';
            ELSE
                IF (@Ilosc <= 0)
                    PRINT 'Ilosc <= 0';
                ELSE
                    IF (@Zakup NOT IN (SELECT 1 FROM T_Zakup))
                        PRINT 'Nie znaleziono takiego zakupu';
                    ELSE
                        BEGIN
                            INSERT INTO T_ListaProduktow(Zakup, Produkt, Ilosc)
                            VALUES (@Zakup, @IdProduktu, @Ilosc);
                            PRINT 'Pomyslnie dodano produkt do zakupu';
                        end
        end

            --ZAD7
            CREATE PROCEDURE EmployeeData @IdPracownika int, @EmployeeInfo Varchar(50) OUTPUT
            AS
            BEGIN
                DECLARE @Name varchar(30), @Surname varchar(30)
                IF (@IdPracownika NOT IN (SELECT 1 FROM T_Pracownik))
                    PRINT 'Nie ma pracownika o takim id';
                SELECT @Name = Imie, @Surname = Nazwisko
                FROM T_Pracownik
                         INNER JOIN T_OSOBA ON T_Pracownik.Id = T_OSOBA.Id
                WHERE T_Pracownik.Id = @IdPracownika;
                IF (@Name is not null and @Surname is not null)
                    begin
                        SET @EmployeeInfo = 'castowanie itd'
                    end
            END;

                --ZAD8
                CREATE PROCEDURE InsertNewProduct @Name varchar(50), @Cost money, @Category varchar(30)
                AS
                BEGIN
                    SET NOCOUNT ON;
                    IF (@Name IN (SELECT T_Produkt.Nazwa FROM T_Produkt))
                        PRINT 'Taki produkt juz istnieje, nie dod prod';
                    ELSE
                        IF (@Category NOT IN (SELECT TK.Nazwa
                                              from T_Produkt
                                                       inner join s27523.T_Kategoria TK on TK.Id = T_Produkt.Kategoria))
                            PRINT 'Taka kategoria nie istnieje, nie dod prod';
                        ELSE
                            BEGIN
                                DECLARE @NewProductId int;
                                SELECT @NewProductId = MAX(T_Produkt.Id) + 1 FROM T_Produkt;
                                INSERT INTO T_Produkt(Id, Nazwa, Cena, Kategoria)
                                VALUES (@NewProductId, @Name, @Cost,
                                        (SELECT id FROM T_Kategoria WHERE T_Kategoria.Nazwa = @Category));
                                PRINT 'Produkt: ' + @Name + ' zostal dodany';
                            END
                end

                    --ZAD9
                    CREATE PROCEDURE UpdateEmployeeData @IdPracownika int, @IdStanowiska int
                    AS
                    BEGIN
                        SET NOCOUNT ON;
                        IF @IdPracownika NOT IN (SELECT id FROM T_Pracownik)
                            PRINT 'Pracownik o podanym id nie istnieje';
                        ELSE
                            IF @IdStanowiska NOT IN (SELECT id FROM T_Stanowisko)
                                PRINT 'Stanowisko o podanym id nie istnieje';
                            ELSE
                                IF (@IdStanowiska IN (SELECT T_Stanowisko.Id
                                                      FROM T_Stanowisko
                                                               INNER JOIN s27523.T_Zatrudnienie TZ on T_Stanowisko.Id = TZ.Stanowisko
                                                      WHERE TZ.Pracownik = @IdPracownika
                                                        AND Do IS NULL))
                                    BEGIN
                                        PRINT 'Pracownik jest juz przypisany na to stanowisko';
                                    END
                        DECLARE @Data date = GETDATE();
                        IF (@Data IN (SELECT Do FROM T_Zatrudnienie WHERE Pracownik = @IdPracownika))
                            PRINT 'Mozna zmieniac tylko raz dziennie';
                        ELSE
                            BEGIN
                                UPDATE T_Zatrudnienie
                                SET Do = @Data
                                WHERE Pracownik = @IdPracownika
                                and do is null;
                                INSERT INTO T_Zatrudnienie(PRACOWNIK, STANOWISKO, OD, DO)
                                VALUES (@IdPracownika, @IdStanowiska, @Data, NULL);
                                PRINT 'Przypisano na nowe stanowisko';
                            end
                    end




