-- Zadanie 6
-- Ktory student zdawal z przedmiotu "Bazy danych" wiecej niz 10 egzaminow w ciagu jednego roku? Zadanie nalezy
-- rozwiazac przy pomocy wyjatkow (dodatkowo mozna wykorzystac kursory). W odpowiedzi prosze podac pelne dane studenta
-- (identyfikator, nazwisko, imie), rok (w formacie YYYY) oraz liczbe egzaminow.

declare
    ZdawalWiecejNiz10 exception;
    cursor s1 is select S.ID_STUDENT,
                        NAZWISKO,
                        IMIE,
                        extract(year from DATA_EGZAMIN) as rok,
                        count(ID_EGZAMIN)               as liczba_egzaminow
                 from STUDENCI S
                          join LAB.EGZAMINY E on S.ID_STUDENT = E.ID_STUDENT
                          join LAB.PRZEDMIOTY P on P.ID_PRZEDMIOT = E.ID_PRZEDMIOT
                 where NAZWA_PRZEDMIOT = 'Bazy danych'
                 group by S.ID_STUDENT, NAZWISKO, IMIE, extract(year from DATA_EGZAMIN);
begin
    for student in s1
        loop
            begin
                if student.liczba_egzaminow > 10 then
                    raise ZdawalWiecejNiz10;
                end if;
            exception
                when ZdawalWiecejNiz10 then
                    DBMS_OUTPUT.PUT_LINE(
                            'Student ' || student.ID_STUDENT || ' ' ||
                            student.NAZWISKO || ' ' ||
                            student.IMIE || ' zdawal wiecej niz 10 egzaminow w roku ' ||
                            student.rok
                    );
            end;
        end loop;
end;