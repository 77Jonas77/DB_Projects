--MSSQL--s27523--

--z1
SELECT *
FROM Rezerwacja
         INNER JOIN Gosc G on G.IdGosc = Rezerwacja.IdGosc
WHERE G.Imie = 'Ferdynand'
  and G.Nazwisko = 'Kiepski';

--z2
SELECT *
FROM Gosc
         LEFT JOIN Rezerwacja R2 on Gosc.IdGosc = R2.IdGosc

--z3
SELECT *
FROM Gosc
WHERE Procent_rabatu is null
ORDER BY Nazwisko

--z4
SELECT *
FROM Gosc
         INNER JOIN s27523.Rezerwacja R on Gosc.IdGosc = R.IdGosc
         INNER JOIN s27523.Pokoj P on R.NrPokoju = P.NrPokoju
         INNER JOIN s27523.Kategoria K on K.IdKategoria = P.IdKategoria
WHERE K.Nazwa = 'Luksusowy'

--z5 -> wynajmowanych? ale, ze wciaz? -> wtedy bysmy dataDo is null zrobili (jesli chodzi o to, ze nadal wynajmuje)
SELECT R.NrPokoju
FROM Gosc
         INNER JOIN s27523.Rezerwacja R on Gosc.IdGosc = R.IdGosc
WHERE Gosc.Imie = 'Andrzej'
  AND Gosc.Nazwisko = 'Nowak';

--z6 w przypadku kilku IN
SELECT NrPokoju
FROM Pokoj
WHERE Liczba_miejsc = (SELECT MAX(Liczba_miejsc) FROM Pokoj);

--z7
SELECT Gosc.Imie, Gosc.Nazwisko, COUNT(R.IdRezerwacja) as l_p
FROM Gosc
         INNER JOIN Rezerwacja R on Gosc.IdGosc = R.IdGosc
GROUP BY Gosc.Imie, Gosc.Nazwisko
HAVING COUNT(R.IdRezerwacja) >= 3;

--z8
SELECT G.Imie, G.Nazwisko
FROM Rezerwacja R
         INNER JOIN s27523.Gosc G on R.IdGosc = G.IdGosc
WHERE DATEDIFF(SECOND, R.DataOd, R.DataDo) = (SELECT MAX(DATEDIFF(SECOND, R2.DataOd, R2.DataDo))
                                              FROM Rezerwacja R2);

--z9
SELECT SUM(Pokoj.Liczba_miejsc)
FROM Pokoj
         INNER JOIN Kategoria ON Pokoj.IdKategoria = Kategoria.IdKategoria
WHERE Kategoria.Nazwa = 'Luksusowy';

--z10
SELECT K.Nazwa, COUNT(P.NrPokoju)
FROM Kategoria K
         INNER JOIN s27523.Pokoj P on K.IdKategoria = P.IdKategoria
group by K.Nazwa;

--z11
SELECT P.NrPokoju
FROM Pokoj P
WHERE P.NrPokoju NOT IN (SELECT P.NrPokoju
                         FROM Pokoj P
                                  INNER JOIN s27523.Rezerwacja R ON P.NrPokoju = R.NrPokoju);

--z12
SELECT G.IdGosc, G.Imie, G.Nazwisko, COUNT(IdRezerwacja)
FROM Gosc G
INNER JOIN s27523.Rezerwacja R on G.IdGosc = R.IdGosc
GROUP BY G.IdGosc, G.Imie, G.Nazwisko
HAVING COUNT(IdRezerwacja) = 1;