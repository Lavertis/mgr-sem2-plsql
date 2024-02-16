-- 5. Utworzyć w bazie danych tabelę o nazwie EgzaminatorzyAnaliza. Tabela powinna zawierać informacje o liczbie
-- studentów egzaminowanych przez poszczególnych egzaminatorów w kolejnych miesiącach w poszczególnych latach.
-- W tabeli utworzyć 4 kolumny. Trzy pierwsze kolumny będą opisywać egzaminatora, tj. jego ID, nazwisko i imię.
-- Czwarta kolumna będzie opisywać rok, miesiąc i liczbę osób egzaminowanych przez danego egzaminatora w danym
-- miesiącu danego roku. Dane dotyczące roku, miesiąca i liczby studentów należy umieścić w kolumnie będącej
-- kolekcją typu tablica zagnieżdżona. Wprowadzić dane do tabeli EgzaminatorzyAnaliza na podstawie danych
-- zgromadzonych tabelach Egzaminatorzy i Egzaminy.
-- Następnie wyświetlić dane znajdujące się w tabeli EgzaminatorzyAnaliza.

CREATE OR REPLACE TYPE TypEgzaminyEgzaminatora AS OBJECT
(
    rok              INT,
    miesiac          INT,
    liczba_studentow INT
);
CREATE OR REPLACE TYPE TypEgzaminyEgzaminatoraTab AS TABLE OF TypEgzaminyEgzaminatora;

CREATE TABLE EgzaminatorzyAnaliza
(
    id_egzaminatora INT,
    nazwisko        VARCHAR(50),
    imie            VARCHAR(50),
    egzaminy        TypEgzaminyEgzaminatoraTab
) NESTED TABLE egzaminy STORE AS egzaminy_tab;

DECLARE
    CURSOR c_egzaminatorzy IS
        SELECT Egzaminatorzy.id_egzaminator,
               nazwisko,
               imie,
               EXTRACT(YEAR FROM DATA_EGZAMIN)  AS rok,
               EXTRACT(MONTH FROM DATA_EGZAMIN) AS miesiac,
               COUNT(distinct ID_STUDENT)       AS liczba_studentow
        FROM Egzaminatorzy
                 LEFT JOIN EGZAMINY ON Egzaminatorzy.id_egzaminator = Egzaminy.id_egzaminator
        GROUP BY Egzaminatorzy.id_egzaminator,
                 nazwisko,
                 imie,
                 EXTRACT(YEAR FROM DATA_EGZAMIN),
                 EXTRACT(MONTH FROM DATA_EGZAMIN)
        ORDER BY Egzaminatorzy.id_egzaminator, rok, miesiac;
    v_egzaminator_id EgzaminatorzyAnaliza.id_egzaminatora%TYPE;
    v_nazwisko       EgzaminatorzyAnaliza.nazwisko%TYPE;
    v_imie           EgzaminatorzyAnaliza.imie%TYPE;
    v_egzaminy       TypEgzaminyEgzaminatoraTab := TypEgzaminyEgzaminatoraTab();
    v_egzamin        TypEgzaminyEgzaminatora;
BEGIN
    FOR r_egzaminator IN c_egzaminatorzy
        LOOP
            IF v_egzaminator_id IS NULL THEN
                v_egzaminator_id := r_egzaminator.id_egzaminator;
                v_nazwisko := r_egzaminator.nazwisko;
                v_imie := r_egzaminator.imie;
            ELSIF v_egzaminator_id <> r_egzaminator.id_egzaminator THEN
                INSERT INTO EgzaminatorzyAnaliza
                VALUES (v_egzaminator_id, v_nazwisko, v_imie, v_egzaminy);
                v_egzaminator_id := r_egzaminator.id_egzaminator;
                v_nazwisko := r_egzaminator.nazwisko;
                v_imie := r_egzaminator.imie;
                v_egzaminy := TypEgzaminyEgzaminatoraTab();
            END IF;
            IF r_egzaminator.rok IS NULL THEN
                CONTINUE;
            END IF;
            v_egzamin :=
                    TypEgzaminyEgzaminatora(r_egzaminator.rok, r_egzaminator.miesiac, r_egzaminator.liczba_studentow);
            v_egzaminy.EXTEND;
            v_egzaminy(v_egzaminy.COUNT) := v_egzamin;
        END LOOP;
    INSERT INTO EgzaminatorzyAnaliza
    VALUES (v_egzaminator_id, v_nazwisko, v_imie, v_egzaminy);
    COMMIT;
END;

BEGIN
    FOR r_egzaminator IN (SELECT * FROM EgzaminatorzyAnaliza)
        LOOP
            DBMS_OUTPUT.PUT_LINE(
                    r_egzaminator.id_egzaminatora || ' ' || r_egzaminator.nazwisko || ' ' || r_egzaminator.imie
            );
            FOR r_egzamin IN (SELECT * FROM TABLE (r_egzaminator.egzaminy))
                LOOP
                    DBMS_OUTPUT.PUT_LINE(
                            'Rok: ' || r_egzamin.rok ||
                            ' Miesiac: ' || r_egzamin.miesiac ||
                            ' Liczba studentow: ' || r_egzamin.liczba_studentow
                    );
                END LOOP;
            DBMS_OUTPUT.PUT_LINE(chr(10));
        END LOOP;
END;