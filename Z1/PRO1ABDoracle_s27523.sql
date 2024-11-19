--ORACLE--s27523--

--z1
DECLARE
    CURSOR Ferdynand_Rezerwacje IS
        SELECT IDREZERWACJA
        FROM REZERWACJA
                 INNER JOIN GOSC on REZERWACJA.IDGOSC = GOSC.IDGOSC
        WHERE IMIE = 'Ferdynand'
          AND NAZWISKO = 'Kiepski';
    v_IdRezerwacji int;
BEGIN
    OPEN Ferdynand_Rezerwacje;
    LOOP
        FETCH Ferdynand_Rezerwacje INTO v_IdRezerwacji;
        EXIT WHEN Ferdynand_Rezerwacje%NotFound;
        DBMS_OUTPUT.PUT_LINE('Id rezerwacji: ' || v_IdRezerwacji);
    END LOOP;
    CLOSE Ferdynand_Rezerwacje;
END;

--z2
DECLARE
    CURSOR Goscie_Rezerwacje IS
        SELECT GOSC.IMIE, Gosc.NAZWISKO, R2.IDREZERWACJA
        FROM Gosc
                 LEFT JOIN Rezerwacja R2 on Gosc.IdGosc = R2.IdGosc;
    v_Imie         GOSC.Imie%type;
    v_Nazwisko     GOSC.Imie%type;
    v_IdRezerwacji REZERWACJA.IdRezerwacja%type;
BEGIN
    OPEN Goscie_Rezerwacje;
    LOOP
        FETCH Goscie_Rezerwacje INTO v_Imie,v_Nazwisko,v_IdRezerwacji;
        EXIT WHEN Goscie_Rezerwacje%NotFound;
        DBMS_OUTPUT.PUT_LINE('Id rezerwacji: ' || NVL(TO_CHAR(v_IdRezerwacji), 'Brak rezerwacji') || ' Imię: ' ||
                             v_Imie || ' Nazwisko: ' || v_Nazwisko);
    END LOOP;

end;

--z3
DECLARE
    CURSOR Goscie_NoRabat IS
        SELECT GOSC.IMIE, Gosc.NAZWISKO, GOSC.PROCENT_RABATU
        FROM Gosc
        WHERE PROCENT_RABATU IS NULL
        ORDER BY NAZWISKO;
    v_Imie     GOSC.Imie%type;
    v_Nazwisko GOSC.Imie%type;
    v_Rabat    GOSC.PROCENT_RABATU%TYPE;
BEGIN
    OPEN Goscie_NoRabat;
    LOOP
        FETCH Goscie_NoRabat INTO v_Imie,v_Nazwisko,v_Rabat;
        EXIT WHEN Goscie_NoRabat%NotFound;
        DBMS_OUTPUT.PUT_LINE('RABAT WARTOSC: ' || NVL(TO_CHAR(v_Rabat), 'nie ma rabatu') || ' Imię: ' || v_Imie ||
                             ' Nazwisko: ' || v_Nazwisko);
    END LOOP;

end;

--z4
DECLARE
    CURSOR Goscie_NoRabat IS
        SELECT Imie, NAZWISKO
        FROM Gosc
                 INNER JOIN s27523.Rezerwacja R on Gosc.IdGosc = R.IdGosc
                 INNER JOIN s27523.Pokoj P on R.NrPokoju = P.NrPokoju
                 INNER JOIN s27523.Kategoria K on K.IdKategoria = P.IdKategoria
        WHERE K.Nazwa = 'Luksusowy';
    v_Imie     GOSC.Imie%type;
    v_Nazwisko GOSC.Imie%type;
    v_Rabat    GOSC.PROCENT_RABATU%TYPE;
BEGIN
    OPEN Goscie_NoRabat;
    LOOP
        FETCH Goscie_NoRabat INTO v_Imie,v_Nazwisko;
        EXIT WHEN Goscie_NoRabat%NotFound;
        DBMS_OUTPUT.PUT_LINE('RABAT WARTOSC: ' || NVL(TO_CHAR(v_Rabat), 'Brak rezerwacji') || ' Imię: ' || v_Imie ||
                             ' Nazwisko: ' || v_Nazwisko);
    END LOOP;
end;

--z5
DECLARE
    CURSOR Goscie_NoRabat IS
        SELECT R.NrPokoju
        FROM Gosc
                 INNER JOIN s27523.Rezerwacja R on Gosc.IdGosc = R.IdGosc
        WHERE Gosc.Imie = 'Andrzej'
          AND Gosc.Nazwisko = 'Nowak';
    v_NrPokoju int;
BEGIN
    OPEN Goscie_NoRabat;
    LOOP
        FETCH Goscie_NoRabat INTO v_NrPokoju;
        EXIT WHEN Goscie_NoRabat%NotFound;
        DBMS_OUTPUT.PUT_LINE('Nr Pokoju: ' || v_NrPokoju);
    END LOOP;
end;

--z6
DECLARE
    v_nrPokoju POKOJ.NrPokoju%type;
BEGIN
    SELECT POKOJ.NrPokoju
    INTO v_nrPokoju
    FROM POKOJ
    WHERE Liczba_miejsc = (SELECT MAX(Liczba_miejsc) FROM POKOJ);

    DBMS_OUTPUT.PUT_LINE('Numer pokoju z największą liczbą miejsc: ' || v_nrPokoju);

--z7
    DECLARE
        CURSOR Goscie_Rezerwacje_3 IS
            SELECT Gosc.Imie, Gosc.Nazwisko, COUNT(R.IdRezerwacja) as l_p
            FROM Gosc
                     INNER JOIN Rezerwacja R on Gosc.IdGosc = R.IdGosc
            GROUP BY Gosc.Imie, Gosc.Nazwisko
            HAVING COUNT(R.IdRezerwacja) >= 3;
        v_Imie             GOSC.Imie%type;
        v_Nazwisko         GOSC.Imie%type;
        v_LiczbaRezerwacji GOSC.PROCENT_RABATU%TYPE;
    BEGIN
        OPEN Goscie_Rezerwacje_3;
        LOOP
            FETCH Goscie_Rezerwacje_3 INTO v_Imie, v_Nazwisko, v_LiczbaRezerwacji;
            EXIT WHEN Goscie_Rezerwacje_3%NotFound;

            DBMS_OUTPUT.PUT_LINE('Imię: ' || v_Imie || ', Nazwisko: ' || v_Nazwisko || ', Nr Pokoju: ' ||
                                 v_LiczbaRezerwacji);
        END LOOP;
    END;
end;

--z8
DECLARE
    v_najdlRezerw POKOJ.NrPokoju%type;
    v_Imie        GOSC.Imie%type;
    v_Nazwisko    GOSC.Nazwisko%type;
    v_max_diff    NUMBER;
BEGIN
    SELECT MAX(R.DataDo - R.DataOd)
    INTO v_max_diff
    FROM Rezerwacja R;

    SELECT G.Imie, G.Nazwisko, R.IDREZERWACJA
    INTO v_Imie, v_Nazwisko, v_najdlRezerw
    FROM Rezerwacja R
             INNER JOIN s27523.Gosc G ON R.IdGosc = G.IdGosc
    WHERE (R.DataDo - R.DataOd) = v_max_diff;

    DBMS_OUTPUT.PUT_LINE('Najdl rezerwacja: ' || v_najdlRezerw || ', Imię: ' || v_Imie || ', Nazwisko: ' || v_Nazwisko);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono żadnych rezerwacji.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił błąd');
END;

--z9
DECLARE
    v_maxOs int;
BEGIN
    SELECT SUM(Pokoj.Liczba_miejsc)
    INTO v_maxOs
    FROM Pokoj
             INNER JOIN Kategoria ON Pokoj.IdKategoria = Kategoria.IdKategoria
    WHERE Kategoria.Nazwa = 'Luksusowy';

    DBMS_OUTPUT.PUT_LINE('Max os jednoczesnie: ' || v_maxOs);
end;

--z10
DECLARE
    CURSOR Pokoje_Kategoria IS
        SELECT K.Nazwa, COUNT(P.NrPokoju)
        FROM Kategoria K
                 INNER JOIN s27523.Pokoj P on K.IdKategoria = P.IdKategoria
        GROUP BY K.Nazwa;
    v_kat  KATEGORIA.Nazwa%type;
    v_lPok int;
BEGIN
    OPEN Pokoje_Kategoria;
    LOOP
        FETCH Pokoje_Kategoria INTO v_kat,v_lPok;
        EXIT WHEN Pokoje_Kategoria%NotFound;
        DBMS_OUTPUT.PUT_LINE('kat: ' || v_kat || ' v_lPok: ' || v_lPok);
    END LOOP;
end;

--z11
DECLARE
    CURSOR wolne_pokoje IS
        SELECT P.NrPokoju
        FROM Pokoj P
        WHERE P.NrPokoju NOT IN (SELECT R.NrPokoju
                                 FROM s27523.Rezerwacja R);
    v_nrPok int;
BEGIN
    OPEN wolne_pokoje;
    LOOP
        FETCH wolne_pokoje INTO v_nrPok;
        EXIT WHEN wolne_pokoje%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Wolny pokój: ' || v_nrPok);
    END LOOP;

    CLOSE wolne_pokoje;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił błąd');
END;

--z12
DECLARE
    CURSOR wynajmowali_raz IS
        SELECT G.IdGosc, G.Imie, G.Nazwisko, COUNT(IdRezerwacja)
        FROM Gosc G
                 INNER JOIN s27523.Rezerwacja R on G.IdGosc = R.IdGosc
        GROUP BY G.IdGosc, G.Imie, G.Nazwisko
        HAVING COUNT(IdRezerwacja) = 1;
    v_IdGosc           GOSC.IdGosc%TYPE;
    v_Imie             GOSC.Imie%TYPE;
    v_Nazwisko         GOSC.Nazwisko%TYPE;
    v_LiczbaRezerwacji NUMBER;
BEGIN
    OPEN wynajmowali_raz;
    LOOP
        FETCH wynajmowali_raz INTO v_IdGosc,v_Imie,v_Nazwisko,v_LiczbaRezerwacji;
        EXIT WHEN wynajmowali_raz%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ID Gościa: ' || v_IdGosc || ', Imię: ' || v_Imie || ', Nazwisko: ' || v_Nazwisko ||
                             ', Liczba Rezerwacji: ' || v_LiczbaRezerwacji);
    END LOOP;

    CLOSE wynajmowali_raz;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił błąd');
END;


