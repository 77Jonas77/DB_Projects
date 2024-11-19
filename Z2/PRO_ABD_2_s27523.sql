--3 ZADANIA - Oracle

--zad 1
SELECT e.ENAME,
    CASE d.deptno
     WHEN 30 THEN 'sprzedaż'
     WHEN 10 THEN 'księgowość'
     ELSE 'pozostali'
     END AS Nazwa_Dzialu
from EMP e
INNER JOIN DEPT d on e.DEPTNO = d.DEPTNO;

--zad 5
CREATE OR REPLACE FUNCTION srednia_dzialu (deptno_in IN INT)
    RETURN NUMBER
IS
    salary_avg NUMBER(10,2);
BEGIN
    SELECT AVG(SAL) INTO salary_avg
    FROM EMP
    WHERE DEPTNO = deptno_in;

    RETURN salary_avg;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
end;

SELECT ENAME FROM EMP
WHERE SAL > srednia_dzialu(10);

--zad 10 -> brak uprawnien, ale mam nadzieje, ze o to chodzilo
CREATE OR REPLACE TRIGGER block_deleting
BEFORE DROP ON DATABASE
BEGIN
    IF ORA_DICT_OBJ_TYPE = 'TABLE' THEN
        IF USER != 'ADMIN_USER' THEN
            RAISE_APPLICATION_ERROR(-20001, 'Only ADMIN_USER can delete tables.');
        END IF;
    end if;
end;
