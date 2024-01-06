-- Zadanie 9
-- Prosze wskazac tych egzaminatorow, ktorzy przeprowadzili egzaminy w dwoch ostatnich dniach egzaminowania
-- z kazdego przedmiotu. Jesli z danego przedmiotu nie bylo egzaminu, prosze wyswietlic komunikat "Brak egzaminow".
-- W odpowiedzi nalezy umiescic nazwe przedmiotu, date egzaminu (w formacie DD-MM-YYYY) oraz identyfikator, nazwisko
-- i imie egzaminatora. Zadanie nalezy wykonać z uzyciem kursora.

declare
    cursor daty_egzaminow(id_przedmiotu number) is
        select distinct DATA_EGZAMIN
        from EGZAMINY E
                 join LAB.PRZEDMIOTY P on P.ID_PRZEDMIOT = E.ID_PRZEDMIOT
        where P.ID_PRZEDMIOT = id_przedmiotu
        order by DATA_EGZAMIN desc fetch first 2 rows only;
    cursor egzaminatorzy_custom(id_przedmiotu number, data_egzaminu date) is
        select distinct EGZAMINATORZY.ID_EGZAMINATOR, IMIE, NAZWISKO
        FROM EGZAMINATORZY
                 join EGZAMINY on EGZAMINATORZY.ID_EGZAMINATOR = EGZAMINY.ID_EGZAMINATOR
        where ID_PRZEDMIOT = id_przedmiotu
          and DATA_EGZAMIN = data_egzaminu
        order by EGZAMINATORZY.ID_EGZAMINATOR;
    byly_egzaminy boolean := false;
begin
    for przedmiot in (select * from PRZEDMIOTY)
        loop
            byly_egzaminy := false;
            DBMS_OUTPUT.put_line('Przedmiot: ' || przedmiot.ID_PRZEDMIOT || ' ' || przedmiot.NAZWA_PRZEDMIOT);
            for date_row in daty_egzaminow(przedmiot.ID_PRZEDMIOT)
                loop
                    byly_egzaminy := true;
                    DBMS_OUTPUT.put_line('Data egzaminu: ' || to_char(date_row.DATA_EGZAMIN, 'dd-mm-yyyy'));
                    for egzaminator in egzaminatorzy_custom(przedmiot.ID_PRZEDMIOT, date_row.DATA_EGZAMIN)
                        loop
                            DBMS_OUTPUT.put_line(
                                    'Egzaminator: ' || egzaminator.ID_EGZAMINATOR || ' ' ||
                                    egzaminator.IMIE || ' ' ||
                                    egzaminator.NAZWISKO
                            );
                        end loop;
                end loop;
            if not byly_egzaminy then
                DBMS_OUTPUT.put_line('Brak egzaminow');
            end if;
            DBMS_OUTPUT.put_line(chr(10));
        end loop;
end;
