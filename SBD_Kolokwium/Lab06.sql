--ZAD1
CREATE TRIGGER TR_ListaProd_Delete
ON T_ListaProduktow
INSTEAD OF DELETE
    AS
    RAISERROR ('Nie mozna usuwac rek z tab t_lista prod',16,1);

--ZAD2
ALTER TRIGGER TR_ListaProd_Delete
    ON T_ListaProduktow
    INSTEAD OF DELETE
    AS
    BEGIN
        DECLARE @IdZak int, @IdProd int, @Info varchar(130);
        select @IdZak = Zakup, @IdProd = produkt from deleted;
        SET @Info = 'ble ble z wykorz tego wyzej';
        RAISERROR (@Info,16,1);
    end

--ZAD3
CREATE TRIGGER zad3
    ON T_Produkt
    INSTEAD OF INSERT
    AS
    BEGIN
        DECLARE @ID int, @Nazwa varchar(50), @Kategoria int, @Cena money;
        select @ID = id, @Nazwa = nazwa, @Kategoria = Kategoria, @Cena = Cena from inserted;
        BEGIN TRY
            INSERT INTO T_Produkt(Id, Nazwa, Cena, Kategoria) values (@ID,@Nazwa,@Cena,@Kategoria);
            PRINT 'DODANO...'
        end try
        begin catch
            RAISERROR ('NARUSZONO...',16,1);
        end catch;
    end;

--ZAD4
CREATE TRIGGER TR_Osoba_Insert
    ON T_Osoba
        AFTER INSERT
        AS
        BEGIN
            DECLARE @Id int, @Nazwisko varchar(30);
            SELECT @Id = id, @Nazwisko = Nazwisko from inserted;
            IF @Nazwisko IN (SELECT Nazwisko from T_Osoba WHERE @Id<>T_Osoba.Id)
                BEGIN
                    Raiserror ('juz istnieje', 16,1);
                    ROLLBACK;
                end
            ELSE
                PRINT 'ZOSTAL POMYSLNIE DODANY';
        end

--ZAD5


--ZAD6
CREATE TRIGGER zad6
    ON T_Pracownik
    AFTER INSERT
    AS
    BEGIN
        DECLARE @szef int;
        SELECT @szef = szef from inserted;
        IF @szef is null
            update T_Pracownik
            set Szef=2
            from T_Pracownik join inserted
            on inserted.id=T_Pracownik.id;
    end

--ZAD7 czy dla update jest to samo co dla insert?
CREATE TRIGGER zad7
    ON T_Pracownik
    FOR INSERT,UPDATE
    AS
    BEGIN
        DECLARE @Zarobki money;
        SELECT @Zarobki = pensja from inserted;
        IF @Zarobki >= 10000
            begin
                RAISERROR ('Za duza',16,1);
                ROLLBACK;
            end
    end

--ZAD8
CREATE TRIGGER zad8
    ON T_Zatrudnienie
    FOR UPDATE
    AS
        BEGIN
            IF(Update(pracownik) or Update(Stanowisko) or update(od))
            BEGIN
                RAISERROR ('TYLKO DO',16,1);
                ROLLBACK;
            end
            ELSE IF(SELECT DO FROM deleted) is not null
                BEGIN
                    RAISERROR ('ASD',16,1);
                    ROLLBACK;
                end
            ELSE IF EXISTS(SELECT 1 FROM INSERTED WHERE DO < OD)
                BEGIN
                    RAISERROR ('COS',16,1);
                    ROLLBACK;
                end
        end

--ZAD9
CREATE TRIGGER zad9
    on T_zatrudnienie
    for insert
    as
    BEGIN
        DECLARE @Stanowisko int, @Pracownik int, @DataOd date, @DataDo date;
        SELECT @Pracownik = pracownik, @Stanowisko = stanowisko, @DataOd = Od, @DataDo = Do
        FROM Inserted;
        IF(@DataDo is not null)
            BEGIN
                RAISERROR ('REASON 1',16,1);
                ROLLBACK;
            end
        ELSE IF(@Stanowisko in (select 1 from T_zatrudnienie where do is null and id = @Pracownik and Od <> @DataOd))
            BEGIN
                RAISERROR ('R2',16,1);
                ROLLBACK;
            end
        ELSE IF(@DataOd < ANY(SELECT IIF(Do IS NULL, Od, Do) FROM T_zatrudnienie WHERE pracownik = @Pracownik))
            BEGIN
            RAISERROR('R3',16,1);
            ROLLBACK;
            END;
        ELSE
        BEGIN
            UPDATE T_Zatrudnienie
            SET Do = @DataOd
            WHERE pracownik = @Pracownik and stanowisko <> @Stanowisko AND Do is null;
        END
    end

--ZAD10
CREATE TRIGGER TR_SprzedaneProdukty
ON T_SprzedaneProdukty
AFTER INSERT, DELETE
AS
    BEGIN
        IF EXISTS (SELECT 1 FROM deleted)
        BEGIN
            RAISERROR ('NIE MOZNA USUWAC',16,1);
            ROLLBACK;
        end
        ELSE IF(SELECT COUNT(*) FROM T_SprzedaneProdukty) > 0 --1
            BEGIN
                RAISERROR ('Nie moze miec wiecej niz 1 rekord',16,1);
                ROLLBACK;
            end
    end

--PROCEDURA
CREATE PROCEDURE aktSprzedProd
    AS
    BEGIN
        DECLARE @Wartosc money;
        select @Wartosc = sum(T_ListaProduktow.ilosc*cena) from T_ListaProduktow Join T_Produkt ON T_ListaProduktow.Produkt = T_Produkt.Id;
        UPDATE T_SprzedaneProdukty
        SET wartosc = ISNULL(@Wartosc,0);
        PRINT 'ZOSTALA ZAKT';
    end

CREATE TRIGGER TR_ListaProduktow
ON T_ListaProduktow
AFTER INSERT, UPDATE, DELETE
AS
EXEC aktSprzedProd;