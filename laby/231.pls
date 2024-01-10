-- 231. Zmodyfikować kod źródłowy w poprzednim zadaniu tak, aby po zainicjowaniu tabeli
-- zagnieżdżonej usunąć z niej elementy, zawierające ośrodki, w których nie przeprowadzono
-- egzaminu. Dokonać sprawdzenia poprawności wykonania zadania, wyświetlając elementy
-- tabeli po wykonaniu operacji usunięcia. Zadanie rozwiązać z wykorzystaniem
-- podprogramów PL/SQL.


INSERT INTO osrodki
VALUES (33, 'Arena Lublin', NULL);

DECLARE
    TYPE tRec_Osrodki IS RECORD (Id osrodki.ID_OSRODEK%TYPE, Nazwa osrodki.NAZWA_OSRODEK%TYPE);
    TYPE tCol_Osrodki IS TABLE OF tRec_Osrodki;
    Col_Osrodki tCol_Osrodki := tCol_Osrodki();
    CURSOR c_Osrodki IS
        SELECT ID_OSRODEK, NAZWA_OSRODEK
        FROM osrodki
        ORDER BY 2 ;
    i NUMBER := 0 ;
    FUNCTION IfExamExists(pid NUMBER) RETURN BOOLEAN IS
        x NUMBER ;
    BEGIN
        SELECT DISTINCT 1 INTO x FROM EGZAMINY WHERE ID_OSRODEK = pid;
        RETURN TRUE;
    EXCEPTION
        WHEN no_data_found THEN
            RETURN FALSE ;
    END ;
BEGIN
    FOR vc_Osrodki IN c_Osrodki
        LOOP
            Col_Osrodki.EXTEND;
            i := i + 1;
            Col_Osrodki(i).ID := vc_Osrodki.ID_OSRODEK;
            Col_Osrodki(i).NAZWA := vc_Osrodki.NAZWA_OSRODEK;
        END LOOP;
    FOR k IN Col_Osrodki.FIRST..Col_Osrodki.LAST
        LOOP
            dbms_output.put_line(Col_Osrodki(k).ID || ' - ' || Col_Osrodki(k).NAZWA);
        END LOOP;
    dbms_output.put_line('Collection contains ' || Col_Osrodki.COUNT || ' items');
    FOR k IN Col_Osrodki.FIRST..Col_Osrodki.LAST
        LOOP
            IF NOT IfExamExists(Col_Osrodki(k).ID) THEN
                Col_Osrodki.DELETE(k) ;
            END IF;
        END LOOP;
    dbms_output.put_line('Collection after delete operation');
    FOR k IN Col_Osrodki.FIRST..Col_Osrodki.LAST
        LOOP
            IF Col_Osrodki.EXISTS(k) THEN
                dbms_output.put_line(Col_Osrodki(k).ID || ' - ' || Col_Osrodki(k).NAZWA);
            END IF;
        END LOOP;
    dbms_output.put_line('Collection contains ' || Col_Osrodki.COUNT || ' items');
END ;