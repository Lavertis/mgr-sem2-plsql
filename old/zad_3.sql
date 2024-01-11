-- Zadanie 3
-- Dla kazdego osrodka wskazac tych studentow, ktorzy zdawali egzamin w tym osrodku w kolejnych latach. W rozwiazaniu
-- zadania wykorzystac podprogram (funkcje lub procedure) PL/SQL, ktory umozliwia kontrole uczestnictwa studenta
-- w egzaminie przeprowadzonych w danych osrodku i w danym roku. Do okreslenia roku wykorzystac funkcje EXTRACT.


declare
    cursor osrodki is
        select *
        from OSRODKI;
    cursor studenci_zdajacy_w_osrodku(id_osrodka in varchar2) is
        select distinct E.ID_STUDENT, IMIE, NAZWISKO
        from EGZAMINY E
                 join STUDENCI S on E.ID_STUDENT = S.ID_STUDENT
        WHERE E.ID_OSRODEK = id_osrodka
        order by E.ID_STUDENT;
    cursor lata_egzaminow_w_osrodku(id_osrodka in varchar2) is
        select distinct extract(year from DATA_EGZAMIN) as rok
        from EGZAMINY E
        where E.ID_OSRODEK = id_osrodka;
    lata_zdawania int     := 0;
    czy_zdawal    boolean := false;

    function czy_student_zdawal_w_osrodku_w_roku(
        id_osrodka in varchar2,
        id_studenta in varchar2,
        rok in number
    ) return boolean is
        cursor c1 is
            select *
            from EGZAMINY E
            where E.ID_STUDENT = id_studenta
              and E.ID_OSRODEK = id_osrodka
              and extract(year from E.DATA_EGZAMIN) = rok;
    begin
        for i in c1
            loop
                return true;
            end loop;
        return false;
    end;
begin
    for osrodek in osrodki
        loop
            dbms_output.put_line('Osrodek: ' || osrodek.ID_OSRODEK || ' ' || osrodek.NAZWA_OSRODEK);
            for student in studenci_zdajacy_w_osrodku(osrodek.ID_OSRODEK)
                loop
                    lata_zdawania := 0;
                    for data in lata_egzaminow_w_osrodku(osrodek.ID_OSRODEK)
                        loop
                            czy_zdawal := czy_student_zdawal_w_osrodku_w_roku(osrodek.ID_OSRODEK, student.ID_STUDENT,
                                                                              data.rok);
                            if czy_zdawal then
                                lata_zdawania := lata_zdawania + 1;
                            end if;
                        end loop;
                    if lata_zdawania > 1 then
                        dbms_output.put_line(student.ID_STUDENT || ' ' || student.IMIE || ' ' || student.NAZWISKO ||
                                             ' zdawal w ' || lata_zdawania || ' latach');
                    end if;
                end loop;
            DBMS_OUTPUT.put_line(chr(10));
        end loop;
end;
