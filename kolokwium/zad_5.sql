-- Zadanie 5
-- Dla kazdego studenta wyznaczyc liczbe jego egzaminów. Jesli student nie zdawal zadnego egzaminu,
-- wyswietlic liczbe 0 (zero). Liczbe egzaminow danego studenta nalezy wyznaczyc przy pomocy funkcji PL/SQL.
-- Wynik w postaci listy studentow i liczby ich egzaminow przedstawic w postaci posortowanej wg nazwiska
-- i imienia studenta.


declare
    cursor s1 is
        select ID_STUDENT, IMIE, NAZWISKO
        FROM STUDENCI
        ORDER BY NAZWISKO, IMIE;
    liczba_egzaminow number;

    function get_liczba_egzaminow_studenta(id_studenta in STUDENCI.ID_STUDENT%TYPE) return number is
        liczba_egzaminow number;
    begin
        select count(*) into liczba_egzaminow from EGZAMINY E where E.ID_STUDENT = id_studenta;
        return liczba_egzaminow;
    end;
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