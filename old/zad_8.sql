-- Zadanie 8
-- Utworzyc w bazie danych tabele o nazwie PrzedmiotyAnaliza. Tabela powinna zawierac informacje o liczbie egzaminow
-- z poszczegolnych przedmiotow przeprowadzonych w poszczegolnych miesiacach dla kolejnych lat. W tabeli utworzyc
-- 2 kolumny. Pierwsza z nich opisuje przedmiot (nazwa przedmiotu). Druga kolumna opisuje rok, miesiac i liczbe
-- egzaminow z danego przedmiotu w danym miesiacu danego roku. Dane dotyczace roku, miesiaca i liczby egzaminow
-- nalezy umiescic w kolumnie bedacej kolekcja typu tablica zagniezdzona. Wprowadzic dane do tabeli PrzedmiotyAnaliza
-- na podstawie danych zgromadzonych w tabelach Przedmioty i Egzaminy. Nastepnie wyswietlic dane znajdujace sie
-- w tabeli PrzedmiotyAnaliza.

create or replace type TypEgzaminyZPrzedmiotu as object
(
    rok              number,
    miesiac          number,
    liczba_egzaminow number
);
create or replace type TypEgzaminyZPrzedmiotuTab is table of TypEgzaminyZPrzedmiotu;

create table Przedmioty_Analiza
(
    NAZWA_PRZEDMIOT varchar2(100),
    EGZAMINY_INFO   TypEgzaminyZPrzedmiotuTab
) nested table EGZAMINY_INFO store as EgzaminyZPrzedmiotuTab

declare
    temp_egzaminy_info TypEgzaminyZPrzedmiotuTab;
begin
    for przedmiot in (select * from PRZEDMIOTY)
        loop
            temp_egzaminy_info := TypEgzaminyZPrzedmiotuTab();
            for date_row in (select extract(year from DATA_EGZAMIN)  as rok,
                                    extract(month from DATA_EGZAMIN) as month,
                                    count(ID_EGZAMIN)                as liczba_egzaminow
                             from EGZAMINY E
                             where ID_PRZEDMIOT = przedmiot.ID_PRZEDMIOT
                             group by extract(year from DATA_EGZAMIN), extract(month from DATA_EGZAMIN)
                )
                loop
                    temp_egzaminy_info.extend;
                    temp_egzaminy_info(temp_egzaminy_info.COUNT) := TypEgzaminyZPrzedmiotu(
                            date_row.rok,
                            date_row.month,
                            date_row.liczba_egzaminow);
                end loop;
            insert into Przedmioty_Analiza values (przedmiot.NAZWA_PRZEDMIOT, temp_egzaminy_info);
        end loop;
    for przedmiot_analiza in (select * from PRZEDMIOTY_ANALIZA)
        loop
            DBMS_OUTPUT.PUT_LINE('Przedmiot: ' || przedmiot_analiza.NAZWA_PRZEDMIOT);
            for egzamin_info in (select * from table (przedmiot_analiza.EGZAMINY_INFO) order by rok, miesiac)
                loop
                    DBMS_OUTPUT.PUT_LINE(
                            'Rok: ' || egzamin_info.rok ||
                            ' Miesiac: ' || egzamin_info.miesiac ||
                            ' Liczba egzaminow: ' || egzamin_info.liczba_egzaminow
                    );
                end loop;
            dbms_output.put_line(chr(10));
        end loop;
end;


-- ver 2
CREATE OR REPLACE TYPE TypEgzaminyInfo AS OBJECT
(
    rok              NUMBER,
    miesiac          NUMBER,
    liczba_egzaminow NUMBER
);
CREATE OR REPLACE TYPE TypEgzaminyInfoTab AS TABLE OF TypEgzaminyInfo;

CREATE TABLE PrzedmiotyAnaliza
(
    nazwa_przedmiotu VARCHAR2(50),
    egzaminy_info    TypEgzaminyInfoTab
) NESTED TABLE egzaminy_info STORE AS egzaminy_info_tab;

DECLARE
    CURSOR c1 IS
        SELECT NAZWA_PRZEDMIOT,
               EXTRACT(YEAR FROM DATA_EGZAMIN)  AS rok,
               EXTRACT(MONTH FROM DATA_EGZAMIN) AS miesiac,
               COUNT(*)                         AS liczba_egzaminow
        FROM Przedmioty p
                 JOIN Egzaminy e ON p.ID_PRZEDMIOT = e.ID_PRZEDMIOT
        GROUP BY NAZWA_PRZEDMIOT, EXTRACT(YEAR FROM DATA_EGZAMIN), EXTRACT(MONTH FROM DATA_EGZAMIN)
        ORDER BY NAZWA_PRZEDMIOT, EXTRACT(YEAR FROM DATA_EGZAMIN), EXTRACT(MONTH FROM DATA_EGZAMIN);
    v_nazwa_przedmiotu PrzedmiotyAnaliza.nazwa_przedmiotu%TYPE;
    v_egzaminy_info    TypEgzaminyInfoTab := TypEgzaminyInfoTab();
BEGIN
    FOR rec IN c1
        LOOP
            IF v_nazwa_przedmiotu IS NULL
            THEN
                v_nazwa_przedmiotu := rec.NAZWA_PRZEDMIOT;
            END IF;
            IF v_nazwa_przedmiotu != rec.NAZWA_PRZEDMIOT
            THEN
                INSERT INTO PrzedmiotyAnaliza VALUES (v_nazwa_przedmiotu, v_egzaminy_info);
                v_nazwa_przedmiotu := rec.NAZWA_PRZEDMIOT;
                v_egzaminy_info := TypEgzaminyInfoTab();
            END IF;
            v_egzaminy_info.extend;
            v_egzaminy_info(v_egzaminy_info.last) := TypEgzaminyInfo(rec.rok, rec.miesiac, rec.liczba_egzaminow);
        END LOOP;
END;

BEGIN
    FOR rec IN (SELECT * FROM PrzedmiotyAnaliza)
        LOOP
            DBMS_OUTPUT.PUT_LINE(rec.nazwa_przedmiotu);
            FOR i IN 1..rec.egzaminy_info.count
                LOOP
                    DBMS_OUTPUT.PUT_LINE(
                            'Rok: ' || rec.egzaminy_info(i).rok || ' Miesiac: ' || rec.egzaminy_info(i).miesiac ||
                            ' Liczba egzaminow: ' || rec.egzaminy_info(i).liczba_egzaminow);
                END LOOP;
            dbms_output.put_line(CHR(10));
        END LOOP;
END;