--PROCEDURA1
--Procedura ma na celu zaktualizowanie wyniku pracownika w danym trwajacym szkoleniu
--Wynik nie moze byc niz ten, ktory byl do tej pory wpisany

--sekcja testowa pod procedura

CREATE OR REPLACE PROCEDURE UpdateEmployeeScore
    (v_IdPracownika WYNIKPRACOWNIKA.IDPRACOWNIK%type, v_IdSzkolenie WYNIKPRACOWNIKA.IDSZKOLENIE%type, v_Wynik WYNIKPRACOWNIKA.WYNIK%type)
IS
    v_ctPracownik int;
    v_ctSzkolenie int;
    v_ctSzkolenieTrwa int;
    v_aktWynik int;
BEGIN
    SELECT COUNT(*) INTO v_ctPracownik FROM PRACOWNIKKLIENTA WHERE IDPRACOWNIK=v_IdPracownika;
    IF v_ctPracownik < 1 THEN
        DBMS_OUTPUT.PUT_LINE('Pracownik o podanym id nie istnieje!');
        RETURN;
    end if;

    SELECT COUNT(*) INTO v_ctSzkolenie FROM SZKOLENIE WHERE IDSZKOLENIE=v_IdSzkolenie;
    IF v_ctSzkolenie < 1 THEN
        DBMS_OUTPUT.PUT_LINE('Szkolenie o podanym id nie istnieje!');
        RETURN;
    end if;

    SELECT COUNT(*) INTO v_ctSzkolenieTrwa
    FROM SZKOLENIE
    WHERE IDSZKOLENIE=v_IdSzkolenie AND DATAZAKONCZENIA IS NOT NULL; --NOT
    IF v_ctSzkolenieTrwa > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Dane szkolenie juz sie zakonczylo! Nie mozna zaktualizowac wynikow dla tego szkolenia!');
        RETURN;
    end if;

    SELECT COALESCE(WYNIK, 0)
    INTO v_aktWynik
    FROM WYNIKPRACOWNIKA
    WHERE IDSZKOLENIE = v_IdSzkolenie AND IDPRACOWNIK = v_IdPracownika;

    IF v_aktWynik > v_Wynik THEN
        DBMS_OUTPUT.PUT_LINE('Nie mozna wprowadzic wyniku wiekszego niz 100, poniewaz operujemy na skali 0-100%!');
        RETURN;
    end if;


    IF v_Wynik > 100 THEN
        DBMS_OUTPUT.PUT_LINE('Nie mozna wprowadzic wyniku wiekszego niz 100, poniewaz operujemy na skali 0-100%!');
        RETURN;
    end if;

    --generalnie wszystko idzie chyba wykonac w jednym update i warunkami w WHERE, ale ogranicza to nam ilosc precyzyjnych komunikatow dla blednych inputow
    UPDATE WYNIKPRACOWNIKA
    SET WYNIK = v_Wynik
    WHERE IDPRACOWNIK = v_IdPracownika AND IDSZKOLENIE=v_IdSzkolenie;

EXCEPTION
--RAISE_APPLICATION_ERROR(error_code, error_message) --> SQLERRM -> zwraca nam bardziej szczegolowy komunikat uzyskanego bledu;
    WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(-20003, 'Naruszono wiezy spójności!');
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak danych dla podanych warunków. Prawdopodobnie dany pracownik nie bierze udzialu w tym szkoleniu');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20004, 'Nieznany błąd: ' || SQLERRM);
END;
/

----TEST----
DECLARE
    v_IdPracownika_test WYNIKPRACOWNIKA.IDPRACOWNIK%type;
    v_IdSzkolenie_test WYNIKPRACOWNIKA.IDSZKOLENIE%type;
    v_Wynik_test WYNIKPRACOWNIKA.WYNIK%type;
BEGIN
    -- 1. Pracownik o podanym id nie ist
    --v_IdPracownika_test := 0;
    --v_IdSzkolenie_test := 0;
    --v_Wynik_test := 0;
    -- 2. Szkolenie o podanym id nie ist
    --v_IdPracownika_test := 1;
    --v_IdSzkolenie_test := 0;
    --v_Wynik_test := 0;
    --3. Dane szkolenie sie zakonczylo
    --v_IdPracownika_test := 1;
    --v_IdSzkolenie_test := 2;
    --v_Wynik_test := 0;
    --4. Nie bierze udzialu w danym szkoleniu
    --v_IdPracownika_test := 1;
    --v_IdSzkolenie_test := 3;
    --v_Wynik_test := 1;
    --5. Nie mozna wprowadzic wyn mniejszego niz jest wprowadzony
    --v_IdPracownika_test := 3;
    --v_IdSzkolenie_test := 3;
    --v_Wynik_test := 0;
    --6. nie mozna wyniku > 100
    --v_IdPracownika_test := 3;
    --v_IdSzkolenie_test := 3;
    --v_Wynik_test := 101;
    --7. poprawne
    --v_IdPracownika_test := 3;
    --v_IdSzkolenie_test := 3;
    --v_Wynik_test := 99;
    UpdateEmployeeScore(v_IdPracownika_test, v_IdSzkolenie_test, v_Wynik_test);
END;
/
------------------


--PROCEDURA2
--Procedura ma na celu obsluzyc wszystkie procesy zwiazane ze zwolnieniem trenera
--tzn. Zakonczyc wszystkie szkolenia w ktorych ten trener bierze udzial
--W przypadku zwolnienia: DataZakonczeniaWspolpracy na date dzisiejsza
--i wszystkie daty zakonczen szkolen, ktory dany trener aktualnie prowadzi rowniez maja miec date dzisiejsza

--EXEC:
--w sekcji testowej pod procedura

CREATE OR REPLACE PROCEDURE ObslugaZwolnieniaTrenera
    (v_IdTrenera Trener.IDTRENER%type)
IS
    CURSOR SzkoleniaTreneraCur IS
        SELECT IDSZKOLENIE
        FROM SZKOLENIE
        WHERE IDTRENER = v_IdTrenera AND DataZakonczenia IS NULL;
    v_cntTrener int;
    v_dataZak date;
    v_IdSzkolenia SZKOLENIE.IDSZKOLENIE%TYPE;
BEGIN
    SELECT COUNT(*) INTO v_cntTrener FROM TRENER WHERE IDTRENER = v_IdTrenera;
    IF v_cntTrener < 1 THEN
        DBMS_OUTPUT.PUT_LINE('Trener o podanym id nie istnieje!');
        RETURN;
    end if;

    SELECT DATAZAKONCZENIAWSPOLPRACY INTO v_dataZak FROM TRENER WHERE IDTRENER = v_IdTrenera;
    IF v_dataZak IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Trener o podanym id juz nie jest zatrudniony!');
        RETURN;
    end if;

    UPDATE Trener
    SET DataZakonczeniaWspolpracy = SYSDATE --TO_DATE(SYSDATE, 'YYYY-MM-DD)
    WHERE IDTRENER = v_IdTrenera;

    FOR SzkolenieRec IN SzkoleniaTreneraCur
    LOOP
        v_IdSzkolenia := SzkolenieRec.IDSZKOLENIE;

        UPDATE SZKOLENIE
        SET DataZakonczenia = SYSDATE
        WHERE IDSZKOLENIE = v_IdSzkolenia;
    END LOOP;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20005, 'Błąd podczas obsługi zwolnienia trenera: ' || SQLERRM);
END;
/
----TEST----
--TEST
DECLARE
    v_IdTrenera_test Trener.IDTRENER%TYPE;
BEGIN
    --1. nie istnieje
    --v_IdTrenera_test := 123;
    --2. nie jest zatrudniony
    --v_IdTrenera_test := 2;
    --3.poprawne
    --v_IdTrenera_test := 3;

    ObslugaZwolnieniaTrenera(v_IdTrenera_test);
END;
/
------------------

--PROCEDURA3
--Aktualizuje wyniki o bonusowe pkt dla pracownikow danej firmy w konkretnym szkoleniu
--w zaleznosci od ich dotychczasowego postepu i danych wejsciowych (tzn. w arg beda podane 2 progi pkt
--Jesli wynik < 50, to 0 pkt bonusowych, jezeli 50 <= wynik < 75, to dostaje 5 pkt,
--Jezeli wynik >= 75, to dostaje 10 pkt
--Punkty bonusowe moga byc przyznane tylko w przypadku zakonczenia danego szkolenia i moga one miec wyn > 100 po dodaniu

CREATE OR REPLACE PROCEDURE AktualizujBonusowePunkty
    (v_IdFirmy PRACOWNIKKLIENTA.IDFIRMA%type, v_IdSzkolenie WYNIKPRACOWNIKA.IDSZKOLENIE%type, v_Prog1 int, v_Prog2 int)
IS
    v_ctSzkolenie int;
    v_ctSzkolenieZak int;
    v_checkFirma int;

    CURSOR WynPrac IS
    SELECT IDSZKOLENIE, WYNIKPRACOWNIKA.IDPRACOWNIK,
           CASE
               WHEN WYNIK < v_Prog1 THEN NULL
               WHEN WYNIK >= v_Prog1 AND WYNIK < v_Prog2 THEN 5
               ELSE 10
           END
    FROM WYNIKPRACOWNIKA
    INNER JOIN PRACOWNIKKLIENTA ON WYNIKPRACOWNIKA.IDPRACOWNIK = PRACOWNIKKLIENTA.IDPRACOWNIK
    WHERE IDFIRMA = v_IdFirmy AND IDSZKOLENIE = v_IdSzkolenie;

    v_IdPracownika WYNIKPRACOWNIKA.IDPRACOWNIK%TYPE;
    v_IdSzkolenia WYNIKPRACOWNIKA.IDSZKOLENIE%TYPE;
    v_BonusowePunkty WYNIKPRACOWNIKA.WYNIK%TYPE;
    v_aktWynik WYNIKPRACOWNIKA.WYNIK%TYPE;
BEGIN
    SELECT COUNT(*) INTO v_checkFirma FROM FIRMA WHERE IDFIRMA = v_IdFirmy;
    IF v_checkFirma < 1 THEN
        DBMS_OUTPUT.PUT_LINE('Firma o podanym id nie istnieje!');
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_ctSzkolenie FROM SZKOLENIE WHERE IDSZKOLENIE = v_IdSzkolenie;
    IF v_ctSzkolenie < 1 THEN
        DBMS_OUTPUT.PUT_LINE('Szkolenie o podanym id nie istnieje!');
        RETURN;
    END IF;

    IF v_Prog1 = 0 OR  v_Prog2 = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Progi musza byc rozne od 0!');
        RETURN;
    end if;

    IF v_Prog1 = v_Prog2 THEN
        DBMS_OUTPUT.PUT_LINE('Progi musza byc roznej wartosci!');
        RETURN;
    end if;


    SELECT COUNT(*) INTO v_ctSzkolenieZak
    FROM SZKOLENIE
    WHERE IDSZKOLENIE = v_IdSzkolenie AND DATAZAKONCZENIA IS NULL;
    IF v_ctSzkolenieZak > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Dane szkolenie jeszcze się nie zakończyło! Nie można zaktualizować wyników dla tego szkolenia!');
        RETURN;
    END IF;

    OPEN WynPrac;
    LOOP
        FETCH WynPrac INTO v_IdSzkolenia, v_IdPracownika, v_BonusowePunkty;
        EXIT WHEN WynPrac%NotFound;

        SELECT WYNIK INTO v_aktWynik FROM WYNIKPRACOWNIKA WHERE IDPRACOWNIK = v_IdPracownika AND IDSZKOLENIE = v_IdSzkolenia;
        v_aktWynik := v_aktWynik + NVL(v_BonusowePunkty, 0);

        UPDATE WYNIKPRACOWNIKA
        SET WYNIK = v_aktWynik
        WHERE IDSZKOLENIE = v_IdSzkolenia AND IDPRACOWNIK = v_IdPracownika;

        DBMS_OUTPUT.PUT_LINE('Wynik pracownika o id: ' || v_IdPracownika || ' został zmieniony na: ' || v_aktWynik);
    END LOOP;
    CLOSE WynPrac;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20006, 'Błąd podczas aktualizacji bonusowych punktów: ' || SQLERRM);
END;
/

----TEST----
DECLARE
    v_IdFirmy_test PRACOWNIKKLIENTA.IDFIRMA%type;
    v_IdSzkolenie_test WYNIKPRACOWNIKA.IDSZKOLENIE%type;
    v_Prog1_test int;
    v_Prog2_test int;
BEGIN
    --1. firma o tym id nie ist
    --v_IdFirmy_test := 0;
    --v_IdSzkolenie_test := 0;
    --v_Prog1_test := 0;
    --v_Prog2_test := 0;
    --2. szkolenie o podanym id nie istnieje
    --v_IdFirmy_test := 1;
    --v_IdSzkolenie_test := 0;
    --v_Prog1_test := 0;
    --v_Prog2_test := 0;
    --3. progi != od 0 i rozne od siebie dla v_Prog1_test := 1; v_Prog2_test := 1; (4 punkt w domysle)
    --v_IdFirmy_test := 1;
    --v_IdSzkolenie_test := 1;
    --v_Prog1_test := 0;
    --v_Prog2_test := 0;
    --4. szkolenie o id 3 dac na null -> dane szkolenie sie jeszcze nie skonczylo
    --v_IdFirmy_test := 1;
    --v_IdSzkolenie_test := 3;
    --v_Prog1_test := 2;
    --v_Prog2_test := 4;
    --5.poprawne:
    --v_IdFirmy_test := 1;
    --v_IdSzkolenie_test := 1;
    --v_Prog1_test := 2;
    --v_Prog2_test := 4;
    AktualizujBonusowePunkty(v_IdFirmy_test, v_IdSzkolenie_test, v_Prog1_test, v_Prog2_test);
END;
/


-----------------WYZWALACZE-----------------

--WYZWALACZ1 - DO POPRAWY
--sprawdza czy updatowane/insertowane NIP lub Nazwa firmy istnieja juz w tabeli
--jesli ktores z tych istnieje to podnosi blad o tym, ze juz takie dane sa wprowadzone

--sekcja testowa pod wyzwalaczem

CREATE OR REPLACE TRIGGER before_insert_update_firma_trigger
BEFORE INSERT OR UPDATE ON Firma
FOR EACH ROW
DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO v_count
  FROM Firma
  WHERE NIP = :NEW.NIP AND :NEW.IdFirma IS NULL;

  IF v_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20003, 'Firma o podanym NIP już istnieje!');
  END IF;

  SELECT COUNT(*)
  INTO v_count
  FROM Firma
  WHERE UPPER(Nazwa) = UPPER(:NEW.Nazwa) AND :NEW.IdFirma IS NULL;

  IF v_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20004, 'Firma o podanej nazwie już istnieje!');
  END IF;
END;
/


----TEST----
--1. firma o podanym NIP juz istnieje
INSERT INTO Firma (IdFirma, Nazwa, NIP, Adres) VALUES (7, 'Firma Testowa 1', '1111111111', 'ul. Testowa 1');

-- Aktualizuj firmę o ID=1
UPDATE Firma SET NAZWA = 'Firma A' WHERE IdFirma = 1;
------------------


--WYZWALACZ2
--wyzwalacz wypisuje PO dodaniu/usunieciu pracownika dla danej firmy
--ogolna liczbe zatrudnionych przez nich pracownikow

CREATE OR REPLACE TRIGGER wypisz_liczbe_pracownikow_firmy
AFTER INSERT ON PracownikKlienta
FOR EACH ROW
DECLARE
    liczba_pracownikow NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO liczba_pracownikow
    FROM PracownikKlienta
    WHERE IdFirma = :NEW.IdFirma;

    -- Wypisz liczbę pracowników
    DBMS_OUTPUT.PUT_LINE('Liczba pracowników dla firmy o IdFirma = ' || :NEW.IdFirma || ': ' || liczba_pracownikow);
END;
/

----TEST----
-- dodawanie uczestnika
-- dodanie nowej osoby / dla przykladu
INSERT INTO Osoba (IdOsoba, PESEL, Imie, Nazwisko, NrTelefonu, KrajPochodzenia)
VALUES (6, '34567890123', 'Maria', 'Nowak', '555-123-456', 'Polska');

--Dodanie jej i polaczenie z dana firma
INSERT INTO PracownikKlienta (IdPracownik, IdFirma)
VALUES (6, 1);
--Usuniecie tej osoby
DELETE FROM PRACOWNIKKLIENTA WHERE IDPRACOWNIK = 6;

------------------
