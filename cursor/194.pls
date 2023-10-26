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
