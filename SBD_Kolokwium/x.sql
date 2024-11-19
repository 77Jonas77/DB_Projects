--zad4
CREATE OR REPLACE PROCEDURE AktCeny(v_podw T_Produkt.cena%type default 0.01)
    IS
BEGIN
    UPDATE T_Produkt
    SET Cena = Cena + (Cena * v_podw);
    DBMS_OUTPUT.PUT_LINE('Zmodyfikowano nast liczbe rekordow: ' || sql%rowcount);
end;

--zad5
CREATE OR REPLACE PROCEDURE DanePrac(v_idPrac T_Pracownik.Id%type, v_imiePrac OUT T_Osoba.Imie%type,
                                     v_NazPrac OUT T_Osoba.Nazwisko%type)
    IS
    v_cntPrac int;
BEGIN
    --SELECT COUNT(Id) INTO v_cntPrac FROM T_PRACOWNIK WHERE Id=v_idPrac;
    SELECT imie, nazwisko INTO v_imiePrac,v_NazPrac FROM T_OSOBA WHERE id = v_idPrac;
EXCEPTION
    WHEN no_data_found then
        DBMS_OUTPUT.PUT_LINE('Pracownik o podanym id nie istnieje')
end;

DECLARE
    v_imieOut T_OSOBA.Imie%type;
    v_nazOut  T_OSOBA.Nazwisko%type;
BEGIN
    DanePrac(10, v_imieOut, v_nazOut);
    IF v_imieOut is not null THEN
        DBMS_OUTPUT.PUT_LINE('Imie: ' || v_imieOut || ' Nazwisko: ' || v_nazOut);
    end if;
end;

--zad6
CREATE OR REPLACE PROCEDURE NowyZakup(v_idKlienta T_OSOBA.id%type, v_newZakId OUT T_ZAKUP.id%type)
    IS
    v_cntKlient int;
BEGIN
    SELECT count(id) INTO v_cntKlient FROM T_OSOBA WHERE Id = v_idKlienta;
    IF v_cntKlient < 1 THEN
        DBMS_OUTPUT.PUT_LINE('Nie ma takiego klienta');
    ELSE
        INSERT INTO T_ZAKUP(data, klient)
        VALUES (to_data(current_date, 'DD-MM-YYYY'), v_idKlienta)
        RETURNING id INTO v_newZakId;
        DBMS_OUTPUT.PUT_LINE('BLE BLE')
    END IF;
end;

DECLARE
    v_id int;
BEGIN
    NowyZakup(1, v_id);
    DBMS_OUTPUT.PUT_LINE('Id zakupu zwrócone przez parametr OUT: ' || v_id);
END;

--zad7
CREATE OR REPLACE PROCEDURE DodajProduktDoZakupu(v_idproduktu T_Produkt.id%type, v_ilosc int,
                                                 v_idzakupu T_Zakup.id%type)
    IS
    v_ctnProdukt         int;
    v_ctnZakup           int;
    v_ctnProduktWZakupie int;
BEGIN
    SELECT Count(*)
    INTO v_ctnZakup
    FROM T_Zakup
    WHERE id = v_idzakupu;

    SELECT Count(*)
    INTO v_ctnProdukt
    FROM T_Produkt
    WHERE id = v_idproduktu;

    SELECT Count(*)
    INTO v_ctnProduktWZakupie
    FROM T_LISTAPRODUKTOW
    WHERE zakup = v_idzakupu
      and produkt = v_idproduktu;

    IF v_ilosc <= 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ilosc musi byc wieksza od 0');
    ELSIF v_ctnProdukt <= 0 THEN
        DBMS_OUTPUT.PUT_LINE('Podany produkt nie istnieje');
    ELSIF v_ctnzakup <= 0 THEN
        DBMS_OUTPUT.PUT_LINE('Podany zakup nie istnieje');
    ELSIF v_ctnProduktWZakupie > 0 THEN
        UPDATE T_ListaProduktow
        SET ilosc = ilosc + v_ilosc
        WHERE zakup = v_idzakupu
          AND produkt = v_idproduktu;
        DBMS_OUTPUT.PUT_LINE('Zwiększono ilość produktu: ' || v_idproduktu
            || ' w zakupie: ' || v_idzakupu || ' o ' || v_ilosc);
    ELSE
        INSERT INTO T_LISTAPRODUKTOW(zakup, produkt, ilosc)
        VALUES (v_idzakupu, v_idproduktu, v_ilosc);
    END IF;
end;

--zad8
CREATE OR REPLACE PROCEDURE AktualizacjaStanowiska(v_IdPracownika T_Pracownik.id%type,
                                                   v_IdStanowiska T_Stanowisko.id%type)
    IS
    v_ctnPracownik           int;
    v_ctnStanowisko          int;
    v_ctnPracownikStanowisko int;
    v_ctnAktualizacjeDzisiaj int;
BEGIN
    --sprawdzamy czy pracownik o podanym id istnieje
    SELECT COUNT(*) INTO v_ctnPracownik FROM T_Pracownik WHERE id = v_IdPracownika;
    IF v_ctnPracownik < 1 THEN
        DBMS_OUTPUT.PUT_LINE('Pracownik o podanym id nie istnieje');
        RETURN;
    END IF;
    --sprawdzamy czy stanowisko o podanym id istnieje
    SELECT COUNT(*)
    INTO v_ctnStanowisko
    FROM T_Stanowisko
    WHERE id =
          v_IdStanowiska;
    IF v_ctnStanowisko < 1 THEN
        DBMS_OUTPUT.PUT_LINE('Stanowisko o podanym id nie istnieje');
        RETURN;
    END IF;
    --sprawdzamy czy pracownik jest przypisany na dane stanowisko
    SELECT COUNT(*)
    INTO v_ctnPracownikStanowisko
    FROM T_Zatrudnienie
    WHERE stanowisko = v_IdStanowiska
      AND pracownik = v_IdPracownika
      AND do IS NULL;
    IF v_ctnPracownikStanowisko > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Pracownik jest już przypisany na to stanowisko');
        RETURN;
    END IF;
    --sprawdzamy czy dany pracownik miał już dzisiaj aktualizowane stanowisko
    SELECT COUNT(*)
    INTO v_ctnAktualizacjeDzisiaj
    FROM T_zatrudnienie
    WHERE pracownik = v_IdPracownika
      AND Do = to_char(sysdate, 'YYYY-MM-DD');
    IF v_ctnAktualizacjeDzisiaj >= 1 THEN
        DBMS_OUTPUT.PUT_LINE('Zmiany nie zostały zapisane, stanowisko można
aktualizować tylko raz dziennie dla danego pracownika');
        RETURN;
    END IF;
    --wypisanie ze starego stanowiska
    UPDATE T_Zatrudnienie
    SET Do = to_char(sysdate, 'YYYY-MM-DD')
    WHERE pracownik = v_IdPracownika
      AND Do IS NULL;
    --przypisanie na nowe stanowisko
    INSERT INTO T_ZATRUDNIENIE
    VALUES (v_IdPracownika, v_IdStanowiska,
            to_char(sysdate, 'YYYY-MM-DD'), NULL);
    DBMS_OUTPUT.PUT_LINE('Pracownik o id= ' || v_IdPracownika || ' został
przypisany na stanowisko o id= ' || v_IdStanowiska);
END;
-- to_char(sysdate, 'YYYY-MM-DD');


--================================================================

--zad1
--ROUND(liczba,ile_po_przecinku);

DECLARE
    CURSOR moj_kursor IS
        SELECT nazwa, cena
        FROM T_Produkt
        WHERE cena NOT BETWEEN 1 AND 2;
    v_NazwProd T_Produkt.nazwa%type;
    v_CenaProd T_Produkt.cena%type;
BEGIN
    open moj_kursor;
    LOOP
        FETCH moj_kursor INTO v_NazwProd, v_CenaProd;
        EXIT WHEN moj_kursor%NotFound;
        IF v_CenaProd > 2 THEN
            v_CenaProd := ROUND(v_CenaProd * 0.9, 2);
        ELSE
            v_CenaProd := ROUND(v_CenaProd * 1.05, 2);
        end if;
        UPDATE T_Produkt
        SET cena = v_CenaProd
        WHERE nazwa = v_NazwProd;
    end loop;
    close moj_kursor;
end;

--zad2
CREATE OR REPLACE PROCEDURE ZmianaCeny(v_WartoscDolna T_Produkt.cena%type,
                                       v_WartoscGorna T_Produkt.cena%type)
    IS
    CURSOR moj_kursor IS
        SELECT nazwa,
               CASE
                   WHEN cena < v_WartoscDolna THEN ROUND(cena * 1.05, 2)
                   WHEN cena > v_WartoscGorna THEN ROUND(cena * 0.9, 2)
                   ELSE cena
                   END
        FROM T_Produkt
        WHERE cena NOT BETWEEN v_WartoscDolna AND v_WartoscGorna;
    v_NazwaProduktu T_Produkt.nazwa%type;
    v_CenaProduktu  T_Produkt.cena%type;
BEGIN
    OPEN moj_kursor;
    LOOP
        FETCH moj_kursor INTO v_NazwaProduktu, v_CenaProduktu;
        EXIT WHEN moj_kursor%NotFound;
        UPDATE T_Produkt
        SET cena = v_CenaProduktu
        WHERE nazwa = v_NazwaProduktu;
        DBMS_OUTPUT.PUT_LINE('Cena ' || v_NazwaProduktu
            || ' została zmieniona na: ' || v_CenaProduktu || '$');
    END LOOP;
    CLOSE moj_kursor;
END;
CALL ZmianaCeny(1, 2);

--zad3
DECLARE
    CURSOR c_produkty IS
        SELECT produkt, SUM(Ilosc) * 2
        FROM T_ListaProdukotw
                 JOIN T_ZAKUP ON T_ListaProduktow.zakup = T_Zakup.id
        WHERE EXTRACT(YEAR FROM data) = 2022
          and extract(MONTH FROM data) = 12
        GROUP BY produkt
        having sum(ilosc) > 10;
    v_IdZaopatrzenia integer;
    v_IdProduktu     T_Produkt.id%type;
    v_IloscProduktu  T_ListaProduktow.ilosc%type;

BEGIN
    INSERT INTO T_Zaopatrzenie (data)
    VALUES (to_date(current_date, 'DD-MM-YYYY'))
    RETURNING id INTO v_IdZaopatrzenia;

    OPEN c_produkty;
    LOOP
        FETCH c_produkty INTO v_IdProduktu, v_IloscProduktu;
        EXIT WHEN c_produkty%notfound;
        INSERT INTO T_ZaopatrzenieProdukt VALUES (v_IdZaopatrzenia, v_IdProduktu, v_IloscProduktu);
        --dmbs
    end loop;
    close c_produkty;
end;

--zad4
--TRUNC() zaokragla do dolu (do calkowitej)
CREATE VIEW StazPracownikow(Pracownik, Staz)
AS
SELECT pracownik, ABS(TRUNC(MONTHS_BETWEEN(MIN(Od), current_date)))
FROM T_Zatrudnienie
WHERE pracownik IN (SELECT pracownik
                    FROM T_Zatrudnienie
                    WHERE Do IS NULL)
GROUP BY pracownik;

--FETCH FIRST 1 ROW ONLY -> tylko 1 wiersz wyciagamy
DECLARE CURSOR c_UlubionyProdukt IS
    SELECT o.id, p.id
    FROM T_Osoba o
             JOIN T_Zakup z ON o.id = z.klient
             JOIN T_ListaProduktow lp ON lp.zakup = z.id
             JOIN T_Produkt p ON lp.produkt = p.id
    WHERE p.id = (SELECT lp2.produkt
                  FROM T_Zakup z2
                           JOIN T_ListaProduktow lp2 ON z2.id = lp2.zakup
                  WHERE o.id = z2.klient
                  GROUP BY lp2.produkt
                  ORDER BY SUM(lp2.ilosc) DESC
                      FETCH FIRST 1 ROW ONLY)
    GROUP BY o.id, p.id;

--==========================================================================
CREATE OR REPLACE TRIGGER TR_ListaProduktow_Delete
    BEFORE DELETE
    ON T_ListaProduktow
    FOR EACH ROW
BEGIN
    raise_application_error(-20001, 'Nie można usuwać rekordów z tabeli
T_ListaProduktow. ' || 'Usuwanie rekordu dla zakupu= ' || :OLD.zakup || ' i produktu= ' ||
                                    :OLD.produkt || ' nie powiodło się');
END;

-------------------
CREATE OR REPLACE TRIGGER T_Zakup_ADR
    AFTER DELETE
    ON T_Zakup
    FOR EACH ROW
BEGIN
    DELETE FROM T_LISTAPRODUKTOW WHERE zakup = :OLD.id;
    DBMS_OUTPUT.PUT_LINE('Usunięto zakup o id= ' || :OLD.id);
END;

----------------------
CREATE OR REPLACE TRIGGER T_Pracownik_BIUR
    BEFORE INSERT OR UPDATE
    ON T_Pracownik
    FOR EACH ROW
    WHEN (NEW.pensja > 10000)
BEGIN
    raise_application_error(-20001, 'Pensja za duża, operacja DML nie
powiodła się');
END;

CREATE OR REPLACE TRIGGER TR_Produkt_BUR
    BEFORE UPDATE OF cena
    ON T_Produkt
    REFERENCING OLD AS o NEW AS n
    FOR EACH ROW
    WHEN (n.cena < o.cena)
BEGIN
    raise_application_error(-20001, 'Nie można zmniejszać ceny');
END;

CREATE OR REPLACE TRIGGER TR_Produkt_BIUDR
    BEFORE INSERT OR UPDATE OR DELETE
    ON T_Produkt
    FOR EACH ROW
BEGIN
    IF INSERTING THEN
        IF :NEW.cena > 100 THEN
            raise_application_error(-20001, 'Cena nie może byc większa niż
100');
        END IF;
    ELSIF UPDATING THEN
        IF :NEW.cena > :OLD.cena THEN
            raise_application_error(-20001, 'Nie można zwiekszać ceny
produktów');
        END IF;
    ELSE --moglibyśmy też zrobić tutaj: ELSIF DELETING THEN
        DELETE
        FROM T_LISTAPRODUKTOW
        WHERE produkt = :OLD.id;
        DBMS_OUTPUT.PUT_LINE('Usunięto wszystkie rekordy dla produktu z id=
'
            || :OLD.id || ' z tabeli
T_ListaProduktow');
    END IF;
END;

--uzywamy for each row ze wzgl na dostep do :NEW. i :OLD. (czyli okreslamy dla poszczegl wierszy, a nie ogl przy DML)
CREATE OR REPLACE TRIGGER TR_Osoba_BIR
    BEFORE INSERT
    ON T_Osoba
    FOR EACH ROW
DECLARE
    v_cntOsoby integer;
BEGIN
    SELECT COUNT(*)
    INTO v_cntOsoby
    FROM T_Osoba
    WHERE nazwisko
              = :NEW.nazwisko;
    IF v_cntOsoby > 0 THEN
        raise_application_error(-20001, 'Osoba o podanym nazwisku już
istnieje');
    ELSE
        DBMS_OUTPUT.PUT_LINE(:NEW.NAZWISKO || ' został pomyślnie
dodany');
    END IF;
END;

CREATE OR REPLACE TRIGGER TR_VPracownik_IOI
    INSTEAD OF INSERT
    ON V_Pracownik
    FOR EACH ROW
DECLARE
    v_IdOsoby         integer;
    v_IdStanowiska    integer;
    v_cntPracownicy   integer;
    v_cntZatrudnienie integer;
    v_dzisiejszaData  date := to_date(to_char(current_date, 'YYYY-MMDD'));
BEGIN
    BEGIN
        SELECT id
        INTO v_IdOsoby
        FROM T_Osoba
        WHERE imie = :NEW.imie
          AND nazwisko = :NEW.nazwisko;
    EXCEPTION
        WHEN no_data_found THEN
            v_IdOsoby := NULL;
    END;
    --Osoba nie istnieje jeśli id jest nullem
    IF v_IdOsoby IS NULL THEN
        SELECT MAX(id) + 1 INTO v_IdOsoby FROM T_Osoba;
        --tutaj dodajemy nowego człowieka
        INSERT INTO T_Osoba (Id, Imie, Nazwisko)
        VALUES (v_IdOsoby, :New.imie, :NEW.nazwisko);
        DBMS_OUTPUT.PUT_LINE('Dodano nowego człowieka o id= ' ||
                             v_IdOsoby);
    END IF;
    SELECT COUNT(*)
    INTO v_cntPracownicy
    FROM T_Pracownik
    WHERE id =
          v_IdOsoby;
    --Sprawdzamy czy dana osoba jest pracownikiem
    IF v_cntPracownicy < 1 THEN
        --tutaj dodajemy go jako pracownika
        INSERT INTO T_Pracownik (Id, pensja, szef)
        VALUES (v_IdOsoby, :NEW.pensja, NULL);
        DBMS_OUTPUT.PUT_LINE('Dodano nowego pracownika o id= ' ||
                             v_IdOsoby);
    ELSE
        --jeśli pracownik istnieje to aktualizujemy jego pensję
        UPDATE T_Pracownik
        SET pensja = :New.pensja
        WHERE id = v_IdOsoby;
        DBMS_OUTPUT.PUT_LINE('Zaktualizowano pensję pracownika o id= '
            || v_IdOsoby);
    END IF;
    BEGIN
        SELECT id
        INTO v_IdStanowiska
        FROM T_Stanowisko
        WHERE nazwa
                  = :NEW.stanowisko;
    EXCEPTION
        WHEN no_data_found THEN
            v_IdStanowiska := NULL;
    END;
    --Sprawdzamy czy dane stanowisko istnieje
    IF v_IdStanowiska IS NULL THEN
        SELECT COUNT(*) + 1 INTO v_IdStanowiska FROM T_Stanowisko;
        --tutaj dodajemy nowe stanowisko
        INSERT INTO T_Stanowisko (Id, nazwa)
        VALUES (v_IdStanowiska, :NEW.stanowisko);
        DBMS_OUTPUT.PUT_LINE('Utworzono nowe stanowisko o nazwie= '
            || :NEW.Stanowisko);
    END IF;
    SELECT COUNT(*)
    INTO v_cntZatrudnienie
    FROM T_Zatrudnienie
    WHERE pracownik = v_IdOsoby
      AND stanowisko = v_IdStanowiska
      AND Do IS NULL;
    --Jeśli pracownik nie jest aktualnie zatrudniony na danym
    --stanowisku to przypisujemy mu je
    IF v_cntZatrudnienie < 1 THEN
        --najpierw wypisujemy danego pracownika ze starego stanowiska
        --(jeśli go nie ma to po prostu będzie 0 rows affected)
        UPDATE T_Zatrudnienie
        SET do = v_dzisiejszaData
        WHERE pracownik = v_IdOsoby
          and do is null;
        --przypisujemy nowe stanowisko z dzisiejszą datą dla kolumny Od i Nullem dla kolumny Do
        INSERT INTO T_Zatrudnienie (pracownik, stanowisko, od, do)
        VALUES (v_IdOsoby, v_IdStanowiska, v_dzisiejszaData, NULL);
        DBMS_OUTPUT.PUT_LINE('Zaktualizowano historie zatrudnienia
pracownika o id= ' || v_IdOsoby);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Dany pracownik jest już zatrudniony na
tym stanowisku');
    END IF;
END;


CREATE OR REPLACE TRIGGER TR_VPracownik_IOI
    INSTEAD OF INSERT
    ON V_Pracownik
    FOR EACH ROW
DECLARE
    v_IdOsoby         integer;
    v_IdStanowiska    integer;
    v_cntPracownicy   integer;
    v_cntZatrudnienie integer;
    v_dzisiejszaData  date := to_date(to_char(current_date, 'YYYY-MMDD'));
BEGIN
    BEGIN
        SELECT id
        INTO v_IdOsoby
        FROM T_Osoba
        WHERE imie = :NEW.imie
          AND nazwisko = :NEW.nazwisko;
    EXCEPTION
        WHEN no_data_found THEN
            v_IdOsoby := NULL;
    END;
    --Osoba nie istnieje jeśli id jest nullem
    IF v_IdOsoby IS NULL THEN
        SELECT MAX(id) + 1 INTO v_IdOsoby FROM T_Osoba;
        --tutaj dodajemy nowego człowieka
        INSERT INTO T_Osoba (Id, Imie, Nazwisko)
        VALUES (v_IdOsoby, :New.imie, :NEW.nazwisko);
        DBMS_OUTPUT.PUT_LINE('Dodano nowego człowieka o id= ' ||
                             v_IdOsoby);
    END IF;
    SELECT COUNT(*)
    INTO v_cntPracownicy
    FROM T_Pracownik
    WHERE id =
          v_IdOsoby;
    --Sprawdzamy czy dana osoba jest pracownikiem
    IF v_cntPracownicy < 1 THEN
        --tutaj dodajemy go jako pracownika
        INSERT INTO T_Pracownik (Id, pensja, szef)
        VALUES (v_IdOsoby, :NEW.pensja, NULL);
        DBMS_OUTPUT.PUT_LINE('Dodano nowego pracownika o id= ' ||
                             v_IdOsoby);
    ELSE
        --jeśli pracownik istnieje to aktualizujemy jego pensję
        UPDATE T_Pracownik
        SET pensja = :New.pensja
        WHERE id = v_IdOsoby;
        DBMS_OUTPUT.PUT_LINE('Zaktualizowano pensję pracownika o id= '
            || v_IdOsoby);
    END IF;
    BEGIN
        SELECT id
        INTO v_IdStanowiska
        FROM T_Stanowisko
        WHERE nazwa
                  = :NEW.stanowisko;
    EXCEPTION
        WHEN no_data_found THEN
            v_IdStanowiska := NULL;
    END;
    --Sprawdzamy czy dane stanowisko istnieje
    IF v_IdStanowiska IS NULL THEN
        SELECT COUNT(*) + 1 INTO v_IdStanowiska FROM T_Stanowisko;
        --tutaj dodajemy nowe stanowisko
        INSERT INTO T_Stanowisko (Id, nazwa)
        VALUES (v_IdStanowiska, :NEW.stanowisko);
        DBMS_OUTPUT.PUT_LINE('Utworzono nowe stanowisko o nazwie= '
            || :NEW.Stanowisko);
    END IF;
    SELECT COUNT(*)
    INTO v_cntZatrudnienie
    FROM T_Zatrudnienie
    WHERE pracownik = v_IdOsoby
      AND stanowisko = v_IdStanowiska
      AND Do IS NULL;
    --Jeśli pracownik nie jest aktualnie zatrudniony na danym
    stanowisku to przypisujemy mu je
    IF v_cntZatrudnienie < 1 THEN
        --najpierw wypisujemy danego pracownika ze starego stanowiska
        (jeśli go nie ma to po prostu będzie 0 rows affected)
        UPDATE T_Zatrudnienie
        SET do = v_dzisiejszaData
        WHERE pracownik = v_IdOsoby
          and do is null;
        --przypisujemy nowe stanowisko z dzisiejszą datą dla kolumny Od
        i Nullem dla kolumny Do
        INSERT INTO T_Zatrudnienie (pracownik, stanowisko, od, do)
        VALUES (v_IdOsoby, v_IdStanowiska, v_dzisiejszaData, NULL);
        DBMS_OUTPUT.PUT_LINE('Zaktualizowano historie zatrudnienia
pracownika o id= ' || v_IdOsoby);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Dany pracownik jest już zatrudniony na
tym stanowisku');
    END IF;
END