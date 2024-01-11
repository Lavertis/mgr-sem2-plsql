-- 4.Utworzyć kolekcję typu tablica zagnieżdżona i nazwać ją NT_Studenci. Kolekcja powinna zawierać elementy
-- opisujące liczbę egzaminów każdego studenta oraz liczbę zdobytych punktów przez studenta. Zainicjować wartości
-- elementów kolekcji na podstawie danych z tabel Studenci i Egzaminy. Zapewnić, by studenci umieszczeni w kolejnych
-- elementach uporządkowani byli wg liczby zdawanych egzaminów, od największej do najmniejszej (tzn. pierwszy element
-- kolekcji zawiera studenta, który miał najwięcej egzaminów). Po zainicjowaniu kolekcji, wyświetlić wartości
-- znajdujące się w poszczególnych jej elementach.


DECLARE
    TYPE Typ_NT_Student IS record
    (
        id_student NUMBER,
        imie       VARCHAR2(15),
        nazwisko   VARCHAR2(25),
        punkty     NUMBER,
        egzaminy   NUMBER
    );
    TYPE Typ_NT_Student_Tab IS TABLE OF Typ_NT_Student;

    NT_Studenci Typ_NT_Student_Tab := Typ_NT_Student_Tab();
    CURSOR c1 IS SELECT s.id_student, imie, nazwisko, COUNT(id_egzamin) AS egzaminy, SUM(punkty) AS punkty
                 FROM studenci s
                          JOIN egzaminy e ON s.id_student = e.id_student
                 GROUP BY s.id_student, imie, nazwisko
                 ORDER BY egzaminy DESC;
BEGIN
    FOR i IN c1
        LOOP
            NT_Studenci.extend;
            NT_Studenci(NT_Studenci.COUNT) := Typ_NT_Student(i.id_student, i.imie, i.nazwisko, i.punkty, i.egzaminy);
        END LOOP;
    FOR i IN 1 .. NT_Studenci.COUNT
        LOOP
            DBMS_OUTPUT.PUT_LINE(
                    NT_Studenci(i).id_student || ' ' ||
                    NT_Studenci(i).imie || ' ' ||
                    NT_Studenci(i).nazwisko || ', ' ||
                    'punkty: ' || NT_Studenci(i).punkty || ', ' ||
                    'egzaminy: ' || NT_Studenci(i).egzaminy);
        END LOOP;
END;