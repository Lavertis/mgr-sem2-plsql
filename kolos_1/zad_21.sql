-- Zadanie 21
-- Utworzyc kolekcje typu tablica zagniezdzona i nazwac ja NT_Studenci. W kolekcji nalezy umiescic elementy, z ktorych
-- kazdy opisuje studenta oraz calkowita liczbe punktow zdobytych przez niego ze wszystkich egzaminow. Do opisu
-- studenta nalezy uzyc jego identyfikatora, nazwiska i imienia. Zainicjowac wartosci elementow kolekcji na podstawie
-- danych z tabel Studenci i Egzaminy. Zapewnic, by dane umieszczane byly w takiej kolejnosci, aby na poczatku
-- znalezli sie studenci, ktorzy zdobyli najwieksza liczbe punktow. Po zainicjowaniu kolekcji, wyświetlic wartosci
-- znajdujace sie w poszczegolnych jej elementach.

create or replace type Typ_NT_Student as object
(
    id_student     number,
    imie           varchar2(15),
    nazwisko       varchar2(25),
    zdobyte_punkty number
);

create or replace type Typ_NT_Studenci_Tab as table of Typ_NT_Student;

declare
    cursor s1 is
        select S.ID_STUDENT, IMIE, NAZWISKO, NVL(SUM(PUNKTY), 0) as suma_punktow
        from STUDENCI S
                 left join LAB.EGZAMINY E on S.ID_STUDENT = E.ID_STUDENT
        group by S.ID_STUDENT, IMIE, NAZWISKO
        order by suma_punktow desc;
    v_nt_studenci Typ_NT_Studenci_Tab := Typ_NT_Studenci_Tab();
begin
    for s in s1
        loop
            v_nt_studenci.extend;
            v_nt_studenci(v_nt_studenci.COUNT) := Typ_NT_Student(s.ID_STUDENT, s.IMIE, s.NAZWISKO, s.suma_punktow);
        end loop;
    for i in 1..v_nt_studenci.count
        loop
            dbms_output.put_line(
                    v_nt_studenci(i).id_student || ' ' ||
                    v_nt_studenci(i).imie || ' ' ||
                    v_nt_studenci(i).nazwisko || ' ' ||
                    v_nt_studenci(i).zdobyte_punkty
            );
        end loop;
end;