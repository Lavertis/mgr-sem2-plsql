-- 192. Dla każdego przedmiotu, z którego przeprowadzono egzamin, wskazać tych studentów,
-- którzy zdawali egzamin w ostatnich dwóch dniach egzaminowania z tego przedmiotu.
-- Uporządkować wyświetlane dane wg nazwy przedmiotu, daty oraz nazwiska studenta. Do
-- opisu przedmiotu należy użyć jego nazwy, do opisu studenta – identyfikatora, nazwiska i
-- imienia. Datę należy wyświetlić w formacie YYYY-MM-DD.

declare
    cursor c1 is select distinct nazwa_przedmiot, p.id_przedmiot from przedmioty p inner join egzaminy e
                        on p.id_przedmiot = e.id_przedmiot order by 1  ;
    cursor c2 (pCourseID przedmioty.id_przedmiot%type) is
                    select distinct data_egzamin from egzaminy where id_przedmiot = pCourseID
                    order by 1 desc ;
    cursor c3 (pCourseID przedmioty.id_przedmiot%type, pExamDate date) is
                    select distinct s.id_student, nazwisko, imie from studenci s inner join egzaminy e
                    on s.id_student = e.id_student
                    where id_przedmiot = pCourseID and data_egzamin = pExamDate ;
begin
    for vc1 in c1 loop
            dbms_output.put_line(vc1.nazwa_przedmiot) ;
            for vc2 in c2(vc1.id_przedmiot) loop
                    exit when c2%rowcount > 2 ;
                    dbms_output.put_line('Exam date ' || to_char(vc2.data_egzamin, 'yyyy-mm-dd')) ;
                    for vc3 in c3(vc1.id_przedmiot, vc2.data_egzamin) loop
                        dbms_output.put_line(vc3.nazwisko || ' ' || vc3.imie || ' (' || vc3.id_student || ')') ;
                    end loop ;
            end loop ;
    end loop ;
end ;