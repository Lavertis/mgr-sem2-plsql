-- Zadanie 13
-- Ktory egzaminator przeprowadzil wiecej niz 50 egzaminow w tym samym osrodku w jednym roku? Zadanie nalezy rozwiazac
-- przy uzyciu techniki wyjatkow (jesli to konieczne, mozna dodatkowo zastosowac kursory). W odpowiedzi proszę umiescic
-- pelne dane o ośrodku (identyfikator, nazwa), informacje o roku (w formacie YYYY), pelne dane egzaminatora
-- (identyfikator, nazwisko, imie) oraz liczbe egzaminow.

declare
    too_many_exams exception;
    exam_count number := 0;
    cursor lata_egzaminow_w_osrodku(id_osrodka number) is select extract(year from DATA_EGZAMIN) as rok
                                                          from EGZAMINY
                                                          where ID_OSRODEK = id_osrodka;

    function egzaminy_egzaminatora_w_osrodku_w_roku(id_egzaminatora number, id_osrodka number, rok number) return number is
        exams number := 0;
    begin
        select count(ID_EGZAMIN)
        into exams
        from EGZAMINY
        where extract(year from DATA_EGZAMIN) = rok
          and ID_EGZAMINATOR = id_egzaminatora
          and ID_OSRODEK = id_osrodka;
        return exams;
    end;
begin
    for egzaminator in (select * from EGZAMINATORZY)
        loop
            begin
                for osrodek in (select * from osrodki)
                    loop
                        for rok in lata_egzaminow_w_osrodku(osrodek.ID_OSRODEK)
                            loop
                                exam_count := egzaminy_egzaminatora_w_osrodku_w_roku(
                                        egzaminator.ID_EGZAMINATOR,
                                        osrodek.ID_OSRODEK,
                                        rok.rok);
                                if exam_count > 50 then
                                    raise too_many_exams;
                                end if;
                            end loop;
                    end loop;
            exception
                when too_many_exams then
                    dbms_output.put_line(
                            'Egzaminator ' || egzaminator.NAZWISKO || ' ' || egzaminator.IMIE ||
                            ' przeprowadzil wiecej niz 50 egzaminow w tym samym osrodku w jednym roku'
                    );
            end;
        end loop;
end;