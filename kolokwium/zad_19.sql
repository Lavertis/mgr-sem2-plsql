-- Zadanie 19
-- Ktory student nie zdawal jeszcze egzaminu z przedmiotu "Bazy danych"? W rozwiazaniu zadania wykorzystac technike
-- wyjatkow (dodatkowo można takze uzyc kursory). W odpowiedzi umiescic pelne dane studenta (identyfikator, nazwisko,
-- imie).

declare
    NieZdawalBazDanychException exception ;
    cursor s1 is
        select ID_STUDENT, IMIE, NAZWISKO
        FROM STUDENCI;

    function czy_student_zdawal_bazy_danych(id_studenta varchar2) return boolean is
        cursor egzaminy_studenta_z_baz_danych is
            select ID_EGZAMIN
            from EGZAMINY E
                     join LAB.PRZEDMIOTY P on P.ID_PRZEDMIOT = E.ID_PRZEDMIOT
            where NAZWA_PRZEDMIOT = 'Bazy danych'
              and ID_STUDENT = id_studenta;
    begin
        for e in egzaminy_studenta_z_baz_danych
            loop
                return true;
            end loop;
        return false;
    end;
begin
    for student in s1
        loop
            begin
                if not czy_student_zdawal_bazy_danych(student.ID_STUDENT) then
                    raise NieZdawalBazDanychException;
                end if;
            exception
                when NieZdawalBazDanychException then
                    dbms_output.put_line(student.ID_STUDENT || ' ' || student.IMIE || ' ' || student.NAZWISKO);
            end;
        end loop;
end;