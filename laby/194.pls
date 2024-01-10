-- 194. Dla każdego roku wskazać ten przedmiot, z którego egzamin zdawało najwięcej osób.
-- W zbiorze wynikowym umieścić dane o numerze roku (4 cyfry), nazwie przedmiotu oraz
-- liczbie egzaminowanych osób. Uporządkować ten zbiór według roku i nazwy przedmiotu.

declare
    cursor c1 (p_year number) is
        WITH ExamCounts AS (SELECT EXTRACT(YEAR FROM E.DATA_EGZAMIN) AS year,
                                   E.ID_PRZEDMIOT,
                                   P.NAZWA_PRZEDMIOT,
                                   COUNT(distinct E.ID_STUDENT)      AS exam_count
                            FROM EGZAMINY E
                                     INNER JOIN LAB.PRZEDMIOTY P ON E.ID_PRZEDMIOT = P.ID_PRZEDMIOT
                            WHERE EXTRACT(YEAR FROM E.DATA_EGZAMIN) = p_year
                            GROUP BY EXTRACT(YEAR FROM E.DATA_EGZAMIN), E.ID_PRZEDMIOT, P.NAZWA_PRZEDMIOT)
        SELECT year, ID_PRZEDMIOT, NAZWA_PRZEDMIOT, exam_count
        FROM ExamCounts
        WHERE exam_count = (SELECT MAX(exam_count) FROM ExamCounts)
        ORDER BY year, NAZWA_PRZEDMIOT;
    cursor years is
        select distinct extract(year from DATA_EGZAMIN) as year
        from EGZAMINY
        order by year;
begin
    for year_row in years
        loop
            for c1_row in c1(year_row.year)
                loop
                    DBMS_OUTPUT.PUT_LINE(year_row.year || ' ' || c1_row.NAZWA_PRZEDMIOT || ' ' || c1_row.exam_count);
                end loop;
        end loop;
end;


DECLARE
    CURSOR c1 IS
        SELECT DISTINCT EXTRACT(YEAR FROM Data_egzamin) AS rok
        FROM egzaminy
        ORDER BY 1;
    CURSOR c2 (rokVal NUMBER) IS
        SELECT MAX(cnt)
        FROM (SELECT COUNT(DISTINCT Id_student) AS cnt
              FROM egzaminy
              WHERE EXTRACT(YEAR FROM Data_egzamin) = rokVal
              GROUP BY Id_przedmiot);
    vMaxNumOfStudents number;
    CURSOR c3 (pMaxNumOfStudents number, rokVal NUMBER) IS
        SELECT p.Id_przedmiot, p.nazwa_przedmiot, COUNT(DISTINCT e.Id_student) AS liczba_studentow
        FROM egzaminy e
                 JOIN przedmioty p ON p.Id_przedmiot = e.Id_przedmiot
        WHERE EXTRACT(YEAR FROM e.Data_egzamin) = rokVal
        GROUP BY p.Id_przedmiot, p.nazwa_przedmiot
        HAVING COUNT(DISTINCT e.Id_student) = pMaxNumOfStudents
        ORDER BY p.nazwa_przedmiot;

BEGIN
    FOR vc1 IN c1
        LOOP
            OPEN c2(vc1.rok);
            IF c2%isopen THEN
                FETCH c2 INTO vMaxNumOfStudents;
                FOR vc3 IN c3(vMaxNumOfStudents, vc1.rok)
                    LOOP
                        DBMS_OUTPUT.PUT_LINE(
                                    'Rok: ' || vc1.rok ||
                                    ', Nazwa przedmiotu: ' || vc3.nazwa_przedmiot ||
                                    ', Liczba studentów: ' || vc3.liczba_studentow
                        );
                    END LOOP;
                CLOSE c2;
            END IF;
        END LOOP;
END;