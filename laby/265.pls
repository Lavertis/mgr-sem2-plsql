-- 265. Wyświetlić informację o liczbie punktów uzyskanych z egzaminów przez każdego
-- studenta. W odpowiedzi należy uwzględnić również tych studentów, którzy jeszcze nie
-- zdawali egzaminów. Liczbę punktów należy wyznaczyć używając funkcji. Jeżeli student
-- nie zdawał egzaminu, należy wyświetlić odpowiedni komunikat. Zadanie należy
-- zrealizować, wykorzystując kod PL/SQL.

declare
    cursor studenci is SELECT ID_STUDENT, IMIE, NAZWISKO
                       FROM STUDENCI;

    function czyStudentZdawal(id_studenta NUMBER) return BOOLEAN is
    BEGIN
        for egzamin in (SELECT ID_EGZAMIN
                        FROM EGZAMINY
                        WHERE ID_STUDENT = id_studenta)
            loop
                return true;
            end loop;
        return false;
    end;

    function punktyZEgzaminowStudenta(id_studenta NUMBER) return NUMBER is
        punkty NUMBER;
    begin
        SELECT SUM(PUNKTY)
        INTO punkty
        FROM EGZAMINY
        WHERE ID_STUDENT = id_studenta;
        return punkty;
    end;
begin
    for student in studenci
        loop
            if czyStudentZdawal(student.ID_STUDENT) then
                dbms_output.put_line(
                        student.IMIE || ' ' || student.NAZWISKO || ': ' ||
                        punktyZEgzaminowStudenta(student.ID_STUDENT)
                );
            else
                dbms_output.put_line(student.IMIE || ' ' || student.NAZWISKO || ': ' || 'Student nie zdawał egzaminów');
            end if;
        end loop;
end;
