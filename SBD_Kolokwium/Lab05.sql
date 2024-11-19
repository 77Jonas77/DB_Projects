--ZAD1
SET NOCOUNT ON;
DECLARE moj_cursor CURSOR FOR SELECT nazwa, cena
                              FROM T_Produkt
                              WHERE Cena NOT BETWEEN 1 AND 2;
DECLARE @Cena money, @Nazwa varchar(50);
OPEN moj_cursor;
FETCH NEXT FROM moj_cursor INTO @Cena, @Nazwa;
WHILE @@FETCH_STATUS != -1
    BEGIN
        IF (@Cena > 2)
            SET @Cena = ROUND(@Cena * 0.9, 2); --SET @Cena += ROUND(@Cena*0.1,2)
        ELSE
            IF (@Cena < 1)
                SET @Cena = ROUND(@Cena * 0.95, 2);
        UPDATE T_Produkt
        SET Cena = @Cena
        WHERE Nazwa = @Nazwa;
        Print 'co sie staloo...';
    end

--ZAD2
CREATE PROCEDURE zmiana_ceny @WartoscDolna money, @WartoscGorna money
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE moj_kursor CURSOR FOR
        SELECT nazwa,
               CASE
                   WHEN cena < @WartoscDolna THEN ROUND(cena + (cena * 0.05), 2)
                   WHEN cena > @WartoscGorna THEN ROUND(cena - (cena * 0.1), 2)
                   ELSE cena
                   END
        FROM T_Produkt
        WHERE cena NOT BETWEEN @WartoscDolna AND @WartoscGorna;
    DECLARE @Nazwa Varchar(30), @Cena money;
    OPEN moj_kursor;
    FETCH NEXT FROM moj_kursor INTO @Nazwa, @Cena;
    WHILE @@Fetch_status = 0
        BEGIN
            UPDATE T_Produkt
            SET cena = @Cena
            WHERE nazwa = @Nazwa;
            PRINT ('Cena ' + @Nazwa + ' została zmieniona na: ' + CAST(@Cena AS Varchar(5)) +
                   '$.')
            FETCH NEXT FROM moj_kursor INTO @Nazwa, @Cena;
        END;
    CLOSE moj_kursor;
    DEALLOCATE moj_kursor;
END;
    EXEC zmiana_ceny 1, 2;

--ZAD3
INSERT INTO T_Zaopatrzenie (Data)
values (getdate());
DECLARE
    prodwiekod10 CURSOR FOR
        SELECT T_Produkt.Id, SUM(T_ListaProduktow.Ilosc)
        FROM T_Produkt
                 INNER JOIN T_ListaProduktow ON T_Produkt.Id = T_ListaProduktow.Produkt
                 INNER JOIN T_Zakup ON T_ListaProduktow.Zakup = T_Zakup.Id
        WHERE MONTH(T_Zakup.Data) = 12
          and YEAR(T_Zakup.Data) = 2022
        GROUP BY T_Produkt.Id
        HAVING SUM(T_ListaProduktow.Ilosc) > 10;
DECLARE @ProdId int, @LacznaIlosc int;
    OPEN prodwiekod10;
    FETCH NEXT FROM prodwiekod10 INTO @ProdId,@LacznaIlosc
    WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO T_ZaopatrzenieProdukt(Zaopatrzenie, Produkt, Ilosc)
            VALUES (@@IDENTITY, @ProdId, @LacznaIlosc * 2);
            FETCH NEXT FROM prodwiekod10 INTO @ProdId, @LacznaIlosc;
        end
    CLOSE prodwiekod10;

--ZAD4
    ALTER TABLE T_Pracownik
        ADD Bonus money NULL;

    CREATE VIEW StazPrac(IdPrac, Staz)
    AS
    SELECT Pracownik, datediff(Month, min(od), getdate())
    FROM T_Zatrudnienie
    WHERE Pracownik in (select Pracownik from T_Zatrudnienie WHERE Do is null)
    GROUP BY Pracownik;

    SET NOCOUNT ON;
DECLARE
    bonus_pracownika CURSOR FOR
        SELECT IdPrac,
               CASE
                   WHEN Staz < 5 THEN NULL
                   WHEN Staz > 30 THEN 30
                   ELSE Staz
                   END AS BONUS
        FROM StazPrac;

--wyplata to bonus
DECLARE @IdPracownika int, @Wyplata money;
    OPEN bonus_pracownika;
    FETCH NEXT FROM bonus_pracownika INTO @IdPracownika, @Wyplata
    WHILE @@FETCH_STATUS = 0
        BEGIN
            UPDATE T_Pracownik
            SET Bonus = ROUND(Pensja * @Wyplata / 100, 2)
            WHERE Id = @IdPracownika
              and @Wyplata is not null;
            FETCH NEXT FROM bonus_pracownika INTO @IdPracownika, @Wyplata
        end;
    CLOSE bonus_pracownika;
    deallocate bonus_pracownika;

--ZAD5
    ALTER TABLE T_Osoba
        ADD Ulubiony_produkt int null,
            CONSTRAINT FK_Osoba_Produkt FOREIGN KEY (Ulubiony_produkt)
                REFERENCES T_Produkt (Id);

DECLARE
    ulubiony_produkt CURSOR FOR
        SELECT o.id, p.id
        FROM T_Osoba o
                 JOIN T_Zakup z ON o.id = z.klient
                 JOIN T_ListaProduktow lp ON lp.zakup = z.id
                 JOIN T_Produkt p ON lp.produkt = p.id
        WHERE p.id = (SELECT TOP (1) lp2.produkt
                      FROM T_Zakup z2
                               JOIN T_ListaProduktow lp2 ON z2.id =
                                                            lp2.zakup
                      WHERE o.id = z2.klient
                      GROUP BY lp2.produkt
                      ORDER BY SUM(lp2.ilosc) DESC)
        GROUP BY o.id, p.id;

OPEN ulubiony_produkt;
DECLARE @FavProd int, @OsId int;
FETCH NEXT FROM ulubiony_produkt INTO @OsId,@FavProd;
WHILE @@FETCH_STATUS = 0
    begin
        UPDATE T_Osoba
        SET Ulubiony_produkt = @FavProd
        WHERE T_Osoba.Id = @OsId;
        FETCH NEXT FROM ulubiony_produkt into @FavProd, @OsId;
    end

