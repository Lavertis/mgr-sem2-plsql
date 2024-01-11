-- Zadanie 3
-- Dla kazdego osrodka wskazac tych studentow, ktorzy zdawali egzamin w tym osrodku w kolejnych latach. W rozwiazaniu
-- zadania wykorzystac podprogram (funkcje lub procedure) PL/SQL, ktory umozliwia kontrole uczestnictwa studenta
-- w egzaminie przeprowadzonych w danych osrodku i w danym roku. Do okreslenia roku wykorzystac funkcje EXTRACT.


declare
    cursor c_osrodki is select ID_OSRODEK, NAZWA_OSRODEK
                        from OSRODKI;
    cursor c_studenci is select ID_STUDENT, IMIE, NAZWISKO
                         from STUDENCI;
    cursor lata_egzaminow_w_osrodku(id_osrodka number) is
        select distinct extract(year from DATA_EGZAMIN) as ROK
        from EGZAMINY
        where ID_OSRODEK = id_osrodka
        order by ROK;

    function czy_student_zdawal_w_osrodku_w_roku(id_studenta varchar2, id_osrodka number, rok number) return boolean is
        cursor egzaminy_studenta is
            select ID_EGZAMIN
            from EGZAMINY
            where ID_STUDENT = id_studenta
              and ID_OSRODEK = id_osrodka
              and extract(year from DATA_EGZAMIN) = rok
                fetch first 1 row only;
    begin
        for egzamin in egzaminy_studenta
            loop
                return true;
            end loop;
        return false;
    end;
begin
    for osrodek in c_osrodki
        loop
            dbms_output.put_line('Osrodek: ' || osrodek.NAZWA_OSRODEK);
            for rok in lata_egzaminow_w_osrodku(osrodek.ID_OSRODEK)
                loop
                    dbms_output.put_line('Rok: ' || rok.ROK);
                    for student in c_studenci
                        loop
                            if czy_student_zdawal_w_osrodku_w_roku(student.ID_STUDENT, osrodek.ID_OSRODEK, rok.ROK)
                            then
                                dbms_output.put_line('    ' || student.IMIE || ' ' || student.NAZWISKO);
                            end if;
                        end loop;
                end loop;
            dbms_output.put_line(chr(10));
        end loop;
end;