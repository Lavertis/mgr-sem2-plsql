-- 230. Utworzyć tabelę zagnieżdżoną o nazwie NT_Osrodki, której elementy będą rekordami.
-- Każdy rekord zawiera dwa pola: Id oraz Nazwa, odnoszące się odpowiednio do
-- identyfikatora i nazwy ośrodka. Następnie zainicjować tabelę, wprowadzając do jej
-- elementów kolejne ośrodki z tabeli Osrodki. Po zainicjowaniu wartości elementów należy
-- wyświetlić ich wartości. Dodatkowo określić i wyświetlić liczbę elementów powstałej
-- tabeli zagnieżdżonej.


DECLARE
    TYPE tRec_Osrodki IS RECORD (Id osrodki.ID_OSRODEK%TYPE, Nazwa osrodki.NAZWA_OSRODEK%TYPE);
    TYPE tCol_Osrodki IS TABLE OF tRec_Osrodki ;
    Col_Osrodki tCol_Osrodki := tCol_Osrodki();
    CURSOR c_Osrodki IS
        SELECT ID_OSRODEK, NAZWA_OSRODEK
        FROM OSRODKI
        ORDER BY 2 ;
    i NUMBER := 0 ;
BEGIN
    FOR vc_Osrodki IN c_Osrodki
        LOOP
            Col_Osrodki.EXTEND;
            i := i + 1;
            Col_Osrodki(i).id := vc_Osrodki.id_osrodek;
            Col_Osrodki(i).nazwa := vc_Osrodki.Nazwa_Osrodek;
        END LOOP;
    FOR k IN Col_Osrodki.FIRST..Col_Osrodki.LAST
        LOOP
            dbms_output.put_line(Col_Osrodki(k).id || ' - ' || Col_Osrodki(k).nazwa);
        END LOOP;
    dbms_output.put_line('Collection contains ' || Col_Osrodki.COUNT || ' items');
END;