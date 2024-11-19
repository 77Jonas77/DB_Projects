RETURN; --> nic nie zwraca /konczymy sobie nim procedury itd.
wszystkie sprawdzenia czy istnieje za pomoca COUNT... INTO

Do = to_char(sysdate,'YYYY-MM-DD'); --> data do porownania
to_date(current_date,'DD-MM-YYYY');
SELECT Max(id) + 1 INTO V_NewId FROM T_Osoba --> id max

EXCEPTION -> piszemy pod jakimis wyrazeniami,
przyklady bledow: WHEN blad THEN
no_data_found,too_many_rows,dup_val_on_index,WHEN OTHERS THEN

v_zmienne OUT T_Pracownik.id%type; --> RETURNING id INTO v_idzakupu (po insert czy cos na koncu)

--ABS(TRUNC(MONTHS_BETWEEN(MIN(Od), current_date))
CASE WHEN zmienna < x then ... cos tam ELSE np zmienna END AS BONUS

ROUND(liczba,po_przecinku);
FETCH FIRST 1 ROW ONLY -> zwraca tylko 1 rekord (np order by desc i wtedy najwieksza z zapytan)
WHERE p.id = podzapytanie (cos tam i np order by sum desc i fetch first...)
EXTRACT(YEAR FROM data) = 2022;
dec cursor m_k is ; open ; loop ; fetch m_k into; EXIT WHEN m_k%NotFound;

raise_application_error(-20001,''); FER WHEN(NEW.pensja>1000) BEGIN...END
REFERENCING AS

IF INSERTING/UPDATING('pracownik')
BEFORE UPDATE OF cena ON...
do trigger mamy declare po stworzeniu nie IS