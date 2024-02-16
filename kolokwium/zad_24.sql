-- Utworzyć w bazie danych tabelę o nazwie OsrodkiAnaliza. Tabela powinna zawierać informacje o liczbie
-- egzaminów i liczbie studentów egzaminowanych w poszczególnych ośrodkach w kolejnych miesiącach w
-- poszczególnych latach.
-- W tabeli utworzyć 3 kolumny. Dwie pierwsze kolumny będą opisywać ośrodek , tj. jego ID i nazwę.
-- Trzecia kolumna będzie opisywać rok, miesiąc, liczbę egzaminów w ośrodku i liczbę osób egzaminowanych
-- w danym ośrodku w danym miesiącu danego roku. Dane dotyczące roku, miesiąca, liczby egzaminów i
-- liczby studentów należy umieścić w kolumnie będącej kolekcją typu tablica zagnieżdżona.
-- Wprowadzić dane do tabeli OsrodkiAnaliza na podstawie danych zgromadzonych tabelach Osrodki i Egzaminy.

create or replace type TypOsrodekInfo as object
(
    rok                        number,
    miesiac                    number,
    liczba_egzaminow           number,
    liczba_osob_egzaminowanych number
);
create or replace type TypOsrodekInfoTab as table of TypOsrodekInfo;

create table OsrodkiAnaliza
(
    id_osrodka    number,
    nazwa_osrodka varchar2(50),
    dane          TypOsrodekInfoTab
) nested table dane store as OsrodekInfoTab;

declare
    cursor o is select O.ID_OSRODEK,
                       NAZWA_OSRODEK,
                       count(E.ID_EGZAMIN)                as liczba_egzaminow,
                       count(distinct E.ID_STUDENT)       as liczba_osob_egzaminowanych,
                       extract(year from E.DATA_EGZAMIN)  as rok,
                       extract(month from E.DATA_EGZAMIN) as miesiac
                from OSRODKI O
                         LEFT JOIN LAB.EGZAMINY E on O.ID_OSRODEK = E.ID_OSRODEK
                group by O.ID_OSRODEK, NAZWA_OSRODEK, extract(year from E.DATA_EGZAMIN),
                         extract(month from E.DATA_EGZAMIN)
                order by O.ID_OSRODEK, extract(year from E.DATA_EGZAMIN), extract(month from E.DATA_EGZAMIN);
    v_dane          TypOsrodekInfoTab := TypOsrodekInfoTab();
    v_id_osrodka    number;
    v_nazwa_osrodka varchar2(50);
begin
    for o_rec in o
        loop
            if v_id_osrodka is null
            then
                v_id_osrodka := o_rec.ID_OSRODEK;
                v_nazwa_osrodka := o_rec.NAZWA_OSRODEK;
            end if;
            if v_id_osrodka <> o_rec.ID_OSRODEK
            then
                insert into OsrodkiAnaliza
                values (v_id_osrodka, v_nazwa_osrodka, v_dane);
                v_dane := TypOsrodekInfoTab();
                v_id_osrodka := o_rec.ID_OSRODEK;
            end if;
            v_dane.extend;
            v_dane(v_dane.last) := TypOsrodekInfo(
                    o_rec.rok,
                    o_rec.miesiac,
                    o_rec.liczba_egzaminow,
                    o_rec.liczba_osob_egzaminowanych);
        end loop;
    insert into OsrodkiAnaliza
    values (v_id_osrodka, v_nazwa_osrodka, v_dane);
end;

begin
    for o_rec in (select * from OsrodkiAnaliza)
        loop
            dbms_output.put_line(o_rec.id_osrodka || ' ' || o_rec.nazwa_osrodka);
            for dane_rec in (select * from table (o_rec.dane))
                loop
                    dbms_output.put_line(
                            dane_rec.rok || '-' || LPAD(dane_rec.miesiac, 2, '0') ||
                            ', egzaminy: ' || dane_rec.liczba_egzaminow ||
                            ', osoby: ' || dane_rec.liczba_osob_egzaminowanych);
                end loop;
            dbms_output.put_line(chr(10));
        end loop;
end;