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