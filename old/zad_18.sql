-- Zadanie 18
-- Utworzyc kolekcje typu tablica zagniezdzona i nazwac ja NT_Studenci. Kolekcja powinna zawierac elementy opisujace
-- date ostatniego egzaminu poszczegolnych studentow. Zainicjowac wartosci elementow kolekcji na podstawie danych
-- z tabel Studenci i Egzaminy. Do opisu studenta nalezy uzyc jego identyfikatora, nazwiska i imienia. Zapewnic,
-- by elementy kolekcji uporzadkowane byly wg daty egzaminu, od najstarszej do najnowszej (tzn. pierwszy element
-- kolekcji zawiera studenta, ktory zdawal najwczesniej egzamin). Po zainicjowaniu kolekcji, wyswietlic wartosci
-- znajdujace sie w poszczegolnych jej elementach.


declare
    type Typ_NT_Student is record
    (
        id_student               varchar2(7),
        imie                     varchar2(15),
        nazwisko                 varchar2(25),
        data_ostatniego_egzaminu date
    );
    type Typ_NT_Student_Tab is table of Typ_NT_Student;

    cursor s1 is select S.ID_STUDENT, IMIE, NAZWISKO, MAX(DATA_EGZAMIN) as data_ostatniego_egzaminu
                 from STUDENCI S
                          join LAB.EGZAMINY E on S.ID_STUDENT = E.ID_STUDENT
                 group by S.ID_STUDENT, IMIE, NAZWISKO
                 order by data_ostatniego_egzaminu;
    v_nt_studenci Typ_NT_Student_Tab := Typ_NT_Student_Tab();
begin
    for student in s1
        loop
            v_nt_studenci.extend;
            v_nt_studenci(v_nt_studenci.COUNT) := Typ_NT_Student(
                    student.ID_STUDENT,
                    student.IMIE,
                    student.NAZWISKO,
                    student.data_ostatniego_egzaminu);
        end loop;
    for i in 1..v_nt_studenci.COUNT
        loop
            dbms_output.put_line(
                    v_nt_studenci(i).id_student || ' ' ||
                    v_nt_studenci(i).imie || ' ' ||
                    v_nt_studenci(i).nazwisko || ' ' ||
                    to_char(v_nt_studenci(i).data_ostatniego_egzaminu, 'DD-MM-YYYY')
            );
        end loop;
end;