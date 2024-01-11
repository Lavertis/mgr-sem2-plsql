-- Zadanie 4
-- Utworzyc kolekcje typu tablica zagniezdzona i nazwac ja NT_Studenci. Kolekcja powinna zawierac elementy opisujace
-- liczbe egzaminow kazdego studenta oraz liczbe zdobytych punktow przez studenta. Zainicjowac wartosci elementow
-- kolekcji na podstawie danych z tabeli Studenci i Egzaminy. Zapewnic, by studenci umieszczeni w kolejnych elementach
-- uporzadkowani byli wg liczby zdawanych egzaminow, od najwiekszej do najmniejszej (tzn. pierwszy element kolekcji
-- zawiera studenta, ktory mial najwiecej egzaminow). Po zainicjowaniu kolekcji, wyswietlic wartosci znajdujace sie
-- w poszczegolnych jej elementach.

DECLARE
    type NT_Student_Data is record
    (
        id_studenta      number,
        imie             varchar2(15),
        nazwisko         varchar2(25),
        liczba_egzaminow number,
        liczba_punktow   number
    );
    TYPE NT_Studenci IS TABLE OF NT_Student_Data;
    nt_student_tab NT_Studenci := NT_Studenci();
    i number := 1;
BEGIN
    FOR rekord IN (SELECT s.ID_STUDENT,
                          s.imie,
                          s.nazwisko,
                          count(e.ID_EGZAMIN) as liczba_egzaminow,
                          sum(e.PUNKTY)       as liczba_punktow
                   FROM Studenci s
                            JOIN Egzaminy e ON s.ID_STUDENT = e.ID_STUDENT
                   GROUP BY s.ID_STUDENT, s.imie, s.nazwisko
                   ORDER BY liczba_egzaminow DESC)
        LOOP
            nt_student_tab.extend;
            nt_student_tab(i) :=
                    NT_Student_Data(rekord.ID_STUDENT, rekord.imie, rekord.nazwisko, rekord.liczba_egzaminow,
                                    rekord.liczba_punktow);
            i := i + 1;
        END LOOP;

    FOR i IN 1..nt_student_tab.count
        LOOP
            dbms_output.put_line(
                    nt_student_tab(i).id_studenta || ' ' ||
                    nt_student_tab(i).imie || ' ' ||
                    nt_student_tab(i).nazwisko ||
                    ', egzaminy: ' || nt_student_tab(i).liczba_egzaminow ||
                    ', punkty: ' || nt_student_tab(i).liczba_punktow
            );
        END LOOP;
END;