-- Zadanie 14
-- Dla kazdego roku, w ktorym odbyly sie egzaminy, prosze wskazac tego studenta, ktory zdal najwiecej egzaminów w danym
-- roku. Dodatkowo, nalezy podac sumaryczna liczbe punktow uzyskanych z tych egzaminow przez studenta. W odpowiedzi
-- umiescic informacje o roku (w formacie YYYY) oraz pelne informacje o studencie (identyfikator, nazwisko, imię).
-- Zadanie nalezy rozwiazac z uzyciem kursora.


declare
    cursor lata_egzaminow is
        select distinct extract(year from DATA_EGZAMIN) as rok
        from EGZAMINY
        order by rok;
    punkty number := 0;
    cursor studenci_z_najwieksza_liczba_zdanych_egzaminow_w_roku(rok number) is
        select S.ID_STUDENT, IMIE, NAZWISKO, count(ID_EGZAMIN) as liczba_egzaminow
        from studenci S
                 join LAB.EGZAMINY E on S.ID_STUDENT = E.ID_STUDENT
        where zdal = 'T'
          and extract(year from DATA_EGZAMIN) = rok
        group by S.ID_STUDENT, IMIE, NAZWISKO
        having count(ID_EGZAMIN) =
               (select count(ID_EGZAMIN) as liczba_egzaminow
                from egzaminy
                where zdal = 'T'
                  and extract(year from DATA_EGZAMIN) = rok
                group by ID_STUDENT
                order by liczba_egzaminow desc fetch first row only);

    function suma_punktow_studenta_w_roku(id_studenta number, rok number) return number is
        suma_punktow number := 0;
    begin
        select sum(PUNKTY)
        into suma_punktow
        from EGZAMINY
        where ID_STUDENT = id_studenta
          and zdal = 'T'
          and extract(year from DATA_EGZAMIN) = rok;
        return suma_punktow;
    exception
        when NO_DATA_FOUND then
            return 0;
    end;
begin
    for rok_data in lata_egzaminow
        loop
            DBMS_OUTPUT.PUT_LINE('Rok: ' || rok_data.rok);
            for student in studenci_z_najwieksza_liczba_zdanych_egzaminow_w_roku(rok_data.rok)
                loop
                    punkty := suma_punktow_studenta_w_roku(student.ID_STUDENT, rok_data.rok);
                    DBMS_OUTPUT.PUT_LINE(
                            'Student: ' || student.ID_STUDENT || ' ' || student.IMIE || ' ' || student.NAZWISKO ||
                            ' ' ||
                            'Liczba egzaminow: ' || student.liczba_egzaminow || ' ' ||
                            'Suma punktow: ' || punkty
                    );
                end loop;
        end loop;
end;