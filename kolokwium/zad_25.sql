-- Dla każdego ośrodka, w którym odbył się egzamin, wyznaczyć liczbę studentów,
-- którzy byli egzaminowani w danym ośrodku w kolejnych latach.
-- Liczbę egzaminowanych studentów należy wyznaczyć przy pomocy funkcji PL/SQL.
-- Wynik w postaci listy ośrodków i w/w liczb przedstawić w postaci posortowanej wg nazwy ośrodka i numeru roku.

declare
    cursor o1 is select *
                 from OSRODKI;
    cursor lata_egzaminowania_osrodka(id_osrodka number) is
        select distinct extract(year from DATA_EGZAMIN) as rok
        from EGZAMINY
        where EGZAMINY.ID_OSRODEK = id_osrodka
        order by rok;
    function liczba_studentow_osrodka_w_roku(id_osrodka number, rok number) return number is
        liczba_studentow number;
    begin
        select count(distinct ID_STUDENT)
        into liczba_studentow
        from EGZAMINY
        where EGZAMINY.ID_OSRODEK = id_osrodka
          and extract(year from DATA_EGZAMIN) = rok;
        return liczba_studentow;
    end;
begin
    for o in o1
        loop
            dbms_output.put_line(o.NAZWA_OSRODEK);
            for rok in lata_egzaminowania_osrodka(o.ID_OSRODEK)
                loop
                    dbms_output.put_line('    ' || rok.rok || ' ' ||
                                         liczba_studentow_osrodka_w_roku(o.ID_OSRODEK, rok.rok));
                end loop;
        end loop;
end;