-- Zadanie 7
-- Utworzyc kolekcje typu tablica zagniezdzona i nazwac ja NT_Osrodki. Kolekcja powinna zawierac elementy opisujace
-- date egzaminu oraz identyfikator i nazwe osrodka. Elementami kolekcji beda dane o tych osrodkach, w ktorych
-- przeprowadzono egzamin w trzech ostatnich dniach egzaminowania, oraz dane o dacie egzaminu. Zainicjowac wartosci
-- elementow kolekcji na podstawie danych z tabel Osrodki i Egzaminy. Zapewnic, by dane umieszczane byly w takiej
-- kolejnosci, aby na poczatku znalazly sie daty najpozniejsze egzaminow. Po zainicjowaniu kolekcji, wyświetlic
-- wartosci znajdujace sie w poszczegolnych jej elementach.

declare
    type NT_Osrodki_Data is record(
        data_egzaminu date,
        id_osrodka    number,
        nazwa_osrodka varchar2(50)
    );
    type NT_Osrodki is table of NT_Osrodki_Data;
    cursor o1 is select O.ID_OSRODEK, NAZWA_OSRODEK, DATA_EGZAMIN
                 from OSRODKI O
                          join EGZAMINY E on O.ID_OSRODEK = E.ID_OSRODEK
                 where DATA_EGZAMIN in
                       (select distinct DATA_EGZAMIN from EGZAMINY order by DATA_EGZAMIN desc fetch first 3 rows only);
    v_nt_osrodki NT_Osrodki := NT_Osrodki();
    i number := 1;
begin
    for osrodek in o1
        loop
            v_nt_osrodki.extend;
            v_nt_osrodki(i) := NT_Osrodki_Data(osrodek.DATA_EGZAMIN, osrodek.ID_OSRODEK, osrodek.NAZWA_OSRODEK);
            i := i + 1;
        end loop;
    for i in 1..v_nt_osrodki.COUNT
        loop
            DBMS_OUTPUT.PUT_LINE(
                    'Data egzaminu: ' || v_nt_osrodki(i).data_egzaminu ||
                    ' ID osrodka: ' || v_nt_osrodki(i).id_osrodka ||
                    ' Nazwa osrodka: ' || v_nt_osrodki(i).nazwa_osrodka
            );
        end loop;
end;