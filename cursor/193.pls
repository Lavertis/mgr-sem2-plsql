-- 193. Dla poszczególnych lat wskazać tego studenta, który w danym roku zdawał najwięcej
-- egzaminów. W zbiorze wynikowym należy umieścić dane o roku, studencie i liczbie
-- egzaminów. Do opisu roku proszę użyć 4 cyfr. Studenta należy opisać jego
-- identyfikatorem, nazwiskiem i imieniem. Uporządkować dane wynikowe wg roku i
-- nazwiska studenta.

declare
    cursor c1 (p_year number) is
        WITH ExamCounts AS (SELECT EXTRACT(YEAR FROM E.DATA_EGZAMIN) AS year,
                                   E.ID_STUDENT,
                                   S.IMIE,
                                   S.NAZWISKO,
                                   COUNT(E.ID_STUDENT)               AS exam_count
                            FROM STUDENCI S
                                     INNER JOIN LAB.EGZAMINY E ON S.ID_STUDENT = E.ID_STUDENT
                            WHERE EXTRACT(YEAR FROM E.DATA_EGZAMIN) = p_year
                            GROUP BY EXTRACT(YEAR FROM E.DATA_EGZAMIN), E.ID_STUDENT, S.NAZWISKO, S.IMIE)
        SELECT year, ID_STUDENT, NAZWISKO, IMIE, exam_count
        FROM ExamCounts
        WHERE exam_count = (SELECT MAX(exam_count) FROM ExamCounts)
        ORDER BY year, NAZWISKO;
    cursor years is
        select distinct extract(year from DATA_EGZAMIN) as year
        from EGZAMINY
        order by year;
begin
    for year_row in years
        loop
            for c1_row in c1(year_row.year)
                loop
                    DBMS_OUTPUT.PUT_LINE(
                                year_row.year || ' ' ||
                                c1_row.ID_STUDENT || ' ' ||
                                c1_row.NAZWISKO || ' ' ||
                                c1_row.IMIE || ' ' ||
                                c1_row.exam_count
                    );
                end loop;
        end loop;
end;