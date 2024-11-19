--KURSORY

--ZAD1 wywalic update
SET
    NOCOUNT ON;
DECLARE
    przejrzyj_produkty CURSOR FOR
    SELECT Nazwa, Cena
    FROM T_Produkt;

OPEN przejrzyj_produkty;
DECLARE
    @produkt Varchar(30), @price float;

FETCH NEXT FROM przejrzyj_produkty INTO @produkt, @price;
WHILE
    @@Fetch_status = 0
    BEGIN
        IF
            (@price > 2)
            BEGIN
                UPDATE T_PRODUKT
                SET Cena = Cena * 0.9;
                SET
                    @price = @price * 0.9;
                PRINT
                    ('Cena ' + @produkt + ' zostala zmieniona na: ' + CAST(ROUND(@price, 2) as Varchar(5)) + '.');
            END;
        ELSE
            IF (@price < 1)
                BEGIN
                    UPDATE T_PRODUKT
                    SET Cena = Cena * 1.05;
                    SET
                        @price = @price * 1.05;
                    PRINT
                        ('Cena ' + @produkt + ' zostala zmieniona na: ' + CAST(ROUND(@price, 2) as Varchar(5)) + '.');
                END;
        FETCH NEXT FROM przejrzyj_produkty INTO @produkt, @price;;
    END;
CLOSE przejrzyj_produkty;
DEALLOCATE
    przejrzyj_produkty;

--ZAD2

CREATE PROCEDURE zmiana_ceny @WartoscDolna money, @WartoscGorna money
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE
        moj_kursor CURSOR FOR
            SELECT nazwa,
                   CASE
                       WHEN cena < @WartoscDolna THEN ROUND(cena + (cena * 0.05), 2)
                       WHEN cena > @WartoscGorna THEN ROUND(cena - (cena * 0.1), 2)
                       ELSE cena
                       END
            FROM T_Produkt
            WHERE cena NOT BETWEEN @WartoscDolna AND @WartoscGorna;

    DECLARE
        @Nazwa Varchar(30), @Cena money;

    OPEN moj_kursor;
    FETCH NEXT FROM moj_kursor INTO @Nazwa, @Cena;
    WHILE
        @@Fetch_status = 0
        BEGIN
            UPDATE T_Produkt
            SET cena = @Cena
            WHERE nazwa = @Nazwa;
            PRINT
                ('Cena ' + @Nazwa + N' została zmieniona na: ' + CAST(@Cena AS Varchar(5)) + '$.')
            FETCH NEXT FROM moj_kursor INTO @Nazwa, @Cena;
        END;
    CLOSE moj_kursor;
    DEALLOCATE
        moj_kursor;
END;
    EXEC zmiana_ceny 1, 2;

--ZAD3
    SET NOCOUNT ON;
DECLARE
    zaopatrzenie CURSOR FOR
        SELECT produkt, sum(Ilosc)
        FROM T_ListaProduktow lp
                 JOIN T_Zakup z ON lp.zakup = z.id
        WHERE MONTH(z."Data") = 12
          AND YEAR(z."Data") = 2022
        GROUP BY produkt
        HAVING SUM(ilosc) > 10;

INSERT INTO T_Zaopatrzenie("Data")
VALUES (GETDATE());

DECLARE @IdProdukt int, @Ilosc int, @ZaopatrzId int = @@Identity;
    OPEN zaopatrzenie;
    FETCH NEXT FROM zaopatrzenie INTO @IdProdukt, @Ilosc;
    WHILE @@fetch_status = 0
        BEGIN
            INSERT INTO T_ZaopatrzenieProdukt VALUES (@ZaopatrzId, @IdProdukt, @Ilosc * 2);
            PRINT (N'Zamówiono produkt o ID= ' + CAST(@IdProdukt AS Varchar(5)) + N' w ilości=' + CAST(@Ilosc * 2 AS Varchar(5)));
            FETCH NEXT FROM zaopatrzenie INTO @IdProdukt, @Ilosc;
        end;
CLOSE zaopatrzenie;
DEALLOCATE zaopatrzenie;

--ZAD4
ALTER TABLE T_Pracownik
ADD Bonus money NULL;

CREATE VIEW StazPracownikow(Pracownik, Staz)
AS
SELECT pracownik, DATEDIFF(Month, min(Od), GETDATE())
FROM T_Zatrudnienie
WHERE pracownik in (select pracownik from T_Zatrudnienie where Do is null)
group by pracownik;

SET NOCOUNT ON;
DECLARE bonus_pracownik CURSOR FOR
SELECT pracownik,
CASE
WHEN Staz < 5 then null
WHEN Staz > 30 then 30
ELSE Staz
END AS bonus
FROM StazPracownikow;

DECLARE @IdPracownika int, @Bonus int;
OPEN bonus_pracownik;
FETCH NEXT FROM bonus_pracownik INTO @IdPracownika, @Bonus;
WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE T_Pracownik
    SET Bonus = ROUND(Pensja * @Bonus/100,2)
    WHERE id = @IdPracownika AND @Bonus is not null;
    PRINT('Pracownik od id= ' + CAST(@IdPracownika AS Varchar(5)) + N' ma przypisany
bonus w wysokości= ' + CAST(@Bonus AS Varchar(5)) + ' % pensji');
FETCH NEXT FROM bonus_pracownik INTO @IdPracownika, @Bonus;
END;
CLOSE bonus_pracownik;
DEALLOCATE bonus_pracownik;

--ZAD5
ALTER TABLE T_Osoba
ADD Ulubiony_produkt int null,
CONSTRAINT FK_Osoba_Produkt FOREIGN KEY (Ulubiony_produkt)
REFERENCES T_Produkt (Id);

DECLARE ulub_produkt CURSOR FOR
SELECT o.id, p.id
FROM T_Osoba o JOIN T_Zakup z ON o.id = z.klient
JOIN T_ListaProduktow lp ON lp.zakup = z.id
JOIN T_Produkt p ON lp.produkt = p.id
WHERE p.id = (SELECT TOP(1) lp2.produkt
              from T_Zakup z2 join T_ListaProduktow lp2 on z2.id = lp2.Zakup
                WHERE o.Id = z2.Klient
                group by lp2.produkt
                order by sum(lp2.Ilosc) desc)
group by  o.id, p.id;

SET NOCOUNT ON;
DECLARE @IdOsoby int, @IdProduktu int;
OPEN ulub_produkt;
FETCH NEXT FROM ulub_produkt INTO @IdOsoby, @IdProduktu;
WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE T_Osoba
    SET Ulubiony_produkt = @IdProduktu
    WHERE Id = @IdOsoby;
    PRINT('Dodano ulubiony produkt o id= ' + CAST(@IdProduktu AS Varchar(5)) + '
dla osoby o id= ' + CAST(@IdOsoby AS Varchar(5)));
    FETCH NEXT FROM ulub_produkt INTO @IdOsoby, @IdProduktu;
END;
CLOSE ulub_produkt;
DEALLOCATE ulub_produkt;