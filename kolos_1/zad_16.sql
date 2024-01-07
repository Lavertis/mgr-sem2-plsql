-- Zadanie 16
-- Dla kazdego osrodka, w ktorym przeprowadzono egzaminy, prosze wskazac tych studentow, ktorzy byli egzaminowani
-- w ciagu trzech ostatnich dni egzaminowania w danym osrodku. Wyswietlic identyfikator i nazwe osrodka, date egzaminu
-- (w formacie DD-MM-YYYY) oraz identyfikator, imie i nazwisko studenta. Zadanie nalezy rozwiazać z uzyciem kursora.

declare
    cursor osrodki_z_egzaminami is select distinct O.ID_OSRODEK, O.NAZWA_OSRODEK
                                   from EGZAMINY E
                                            join LAB.OSRODKI O on O.ID_OSRODEK = E.ID_OSRODEK
                                   order by O.ID_OSRODEK;
    CURSOR ostatnie_3_dni_egzaminowania_w_osrodku(idOsrodka OSRODKI.id_osrodek%type) IS
        SELECT DISTINCT DATA_EGZAMIN
        FROM EGZAMINY
        WHERE ID_OSRODEK = idOsrodka
        ORDER BY DATA_EGZAMIN desc FETCH FIRST 3 row only;
    cursor studenci_egzaminowani_w_osrodku_dnia(id_osrodka number, dzien date) is
        select distinct S.ID_STUDENT, IMIE, NAZWISKO
        from EGZAMINY E
                 join STUDENCI S on E.ID_STUDENT = S.ID_STUDENT
        where E.ID_OSRODEK = id_osrodka
          and E.DATA_EGZAMIN = dzien;
begin
    for osrodek in osrodki_z_egzaminami
        loop
            dbms_output.put_line('Osrodek: ' || osrodek.ID_OSRODEK || ' ' || osrodek.NAZWA_OSRODEK);
            for dzien in ostatnie_3_dni_egzaminowania_w_osrodku(osrodek.ID_OSRODEK)
                loop
                    dbms_output.put_line('Dzien: ' || to_char(dzien.DATA_EGZAMIN, 'DD-MM-YYYY'));
                    for student in studenci_egzaminowani_w_osrodku_dnia(osrodek.ID_OSRODEK, dzien.DATA_EGZAMIN)
                        loop
                            dbms_output.put_line(
                                    'Student: ' || student.ID_STUDENT || ' ' || student.IMIE || ' ' || student.NAZWISKO
                            );
                        end loop;
                end loop;
            dbms_output.put_line(chr(10));
        end loop;
end;