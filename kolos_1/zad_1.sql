-- Zadanie 1
-- Ktory student zdawal w jednym miesiacu wiecej niz 10 egzaminow? Zadanie nalezy rozwiazac przy uzyciu techniki
-- wyjatkow (jesli to konieczne, mozna dodatkowo zastosowac kursory). W odpowiedzi prosze umiescic pelne dane
-- studenta (identyfikator, nazwisko, imie), rok i nazwe miesiaca oraz liczbe egzaminow.

declare
    Ponad10Egzaminow exception;
    cursor s1 is
        select STUDENCI.ID_STUDENT,
               NAZWISKO,
               IMIE,
               extract(year from DATA_EGZAMIN) as rok,
               to_char(DATA_EGZAMIN, 'Month')  as miesiac,
               count(*)                        as LICZBA_EGZAMINOW
        from STUDENCI
                 join EGZAMINY ON STUDENCI.ID_STUDENT = EGZAMINY.ID_STUDENT
        group by STUDENCI.ID_STUDENT, NAZWISKO, IMIE, extract(year from DATA_EGZAMIN), to_char(DATA_EGZAMIN, 'Month');
begin
    for s in s1
        loop
            begin
                if s.LICZBA_EGZAMINOW > 10 then
                    raise Ponad10Egzaminow;
                end if;
            exception
                when Ponad10Egzaminow then
                    dbms_output.put_line('Student ' || s.ID_STUDENT || ' ' || s.NAZWISKO || ' ' || s.IMIE ||
                                         ' zdawal w ' || s.miesiac || ' ' || s.rok || ' wiecej niz 10 egzaminow');
            end;
        end loop;
end;
