-- Zadanie 5
-- Dla kazdego studenta wyznaczyc liczbe jego egzaminów. Jesli student nie zdawal zadnego egzaminu,
-- wyswietlic liczbe 0 (zero). Liczbe egzaminow danego studenta nalezy wyznaczyc przy pomocy funkcji PL/SQL.
-- Wynik w postaci listy studentow i liczby ich egzaminow przedstawic w postaci posortowanej wg nazwiska
-- i imienia studenta.

create or replace function get_liczba_egzaminow_studenta(id_studenta in STUDENCI.ID_STUDENT%TYPE) return number is
    liczba_egzaminow number;
begin
    select count(*) into liczba_egzaminow from EGZAMINY E where E.ID_STUDENT = id_studenta;
    return liczba_egzaminow;
end;

declare
    cursor s1 is select S.ID_STUDENT, IMIE, NAZWISKO, count(E.ID_EGZAMIN) as liczba_egzaminow
                 FROM STUDENCI S
                          LEFT JOIN EGZAMINY E on E.ID_STUDENT = S.ID_STUDENT
                 group by S.ID_STUDENT, NAZWISKO, IMIE
                 ORDER BY NAZWISKO, IMIE;
    liczba_egzaminow number;
begin
    for student in s1
        loop
            liczba_egzaminow := get_liczba_egzaminow_studenta(student.ID_STUDENT);
            dbms_output.put_line(
                    student.ID_STUDENT || ' ' ||
                    student.NAZWISKO || ' ' ||
                    student.IMIE || ' ' ||
                    liczba_egzaminow
            );
        end loop;
end;