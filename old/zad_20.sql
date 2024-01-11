-- Zadanie 20
-- Utworzyc kolekcje typu tablica zagniezdzona i nazwac ja NT_Egzaminatorzy. Kolekcja powinna zawierac elementy,
-- z ktorych kazdy opisuje egzaminatora oraz liczbe studentow przeegzaminowanych przez niego. Do opisu egzaminatora
-- prosze uzyc identyfikatora, nazwiska i imienia. Zainicjowac wartosci elementow kolekcji na podstawie danych
-- z tabel Egzaminatorzy i Egzaminy. Zapewnic, by egzaminatorzy umieszczeni w kolejnych elementach uporzadkowani byli
-- wg liczby egzaminowanych osób, od najwiekszej do najmniejszej (tzn. pierwszy element kolekcji zawiera egzaminatora,
-- ktory egzaminowal najwiecej osob). Po zainicjowaniu kolekcji, wyświetlic wartosci znajdujace sie w poszczegolnych
-- jej elementach.


declare
    type Typ_NT_Egzaminator is record (
        id_egzaminator number,
        imie varchar2(15),
        nazwisko varchar2(25),
        liczba_studentow number
    );
    type Typ_NT_Egzaminatorzy_Tab is table of Typ_NT_Egzaminator;

    v_nt_egzaminatorzy Typ_NT_Egzaminatorzy_Tab := Typ_NT_Egzaminatorzy_Tab();
    cursor e1 is
        select EGZAMINY.ID_EGZAMINATOR, IMIE, NAZWISKO, COUNT(ID_STUDENT) as liczba_studentow
        from EGZAMINATORZY
                 join EGZAMINY on EGZAMINATORZY.ID_EGZAMINATOR = EGZAMINY.ID_EGZAMINATOR
        group by EGZAMINY.ID_EGZAMINATOR, IMIE, NAZWISKO
        order by liczba_studentow desc ;
begin
    for e in e1
        loop
            v_nt_egzaminatorzy.extend;
            v_nt_egzaminatorzy(v_nt_egzaminatorzy.COUNT) := Typ_NT_Egzaminator(
                    e.ID_EGZAMINATOR,
                    e.IMIE,
                    e.NAZWISKO,
                    e.liczba_studentow);
        end loop;
    for i in 1..v_nt_egzaminatorzy.COUNT
        loop
            dbms_output.put_line(
                    v_nt_egzaminatorzy(i).id_egzaminator || ' ' ||
                    v_nt_egzaminatorzy(i).imie || ' ' ||
                    v_nt_egzaminatorzy(i).nazwisko || ' ' ||
                    v_nt_egzaminatorzy(i).liczba_studentow
            );
        end loop;
end;