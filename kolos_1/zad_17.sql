-- Zadanie 17
-- Utworzyc w bazie danych tabele o nazwie Analityka. Tabela powinna zawierac informacje o liczbie egzaminow
-- poszczegolnych egzaminatorow w poszczegolnych osrodkach. W tabeli utworzyc 4 kolumny. Trzy pierwsze kolumny opisuja
-- egzaminatora (identyfikator, imie i nazwisko). Czwarta kolumna o nazwie Osrodki opisuje osrodek (identyfikator oraz
-- nazwa) oraz liczbe egzaminow danego egzaminatora w tym osrodku. Dane dotyczace osrodka i liczby egzaminow nalezy
-- umiescic w kolumnie bedacej kolekcja typu tablica zagniezdzona. Wprowadzic dane do tabeli Analityka na podstawie
-- danych zgromadzonych w tabelach Egzaminy, Osrodki i Egzaminatorzy. Nastepnie wyświetlic dane znajdujace sie
-- w tabeli Analityka.

create or replace type TypOsrodekEgzaminatora as object
(
    nazwa_osrodek    varchar2(50),
    liczba_egzaminow number
);
create or replace type TypOsrodekEgzaminatoraTab as table of TypOsrodekEgzaminatora;

create table Analityka
(
    id_egzaminator number,
    imie           varchar2(15),
    nazwisko       varchar2(25),
    osrodki        TypOsrodekEgzaminatoraTab
) nested table osrodki store as OsrodekEgzaminatoraTab;

declare
    cursor egzaminatorzy is select *
                            from EGZAMINATORZY
                            order by ID_EGZAMINATOR;
    cursor osrodki is select *
                      from osrodki
                      order by ID_OSRODEK;
    exam_count                number;
    temp_osrodki_egzaminatora TypOsrodekEgzaminatoraTab;
begin
    for egzaminator in egzaminatorzy
        loop
            temp_osrodki_egzaminatora := TypOsrodekEgzaminatoraTab();
            for osrodek in osrodki
                loop
                    select count(ID_EGZAMIN)
                    into exam_count
                    from EGZAMINY
                    where ID_EGZAMINATOR = egzaminator.ID_EGZAMINATOR
                      and ID_OSRODEK = osrodek.ID_OSRODEK;
                    temp_osrodki_egzaminatora.extend;
                    temp_osrodki_egzaminatora(temp_osrodki_egzaminatora.count) := TypOsrodekEgzaminatora(
                            osrodek.NAZWA_OSRODEK,
                            exam_count);
                end loop;
            insert into Analityka
            values (egzaminator.ID_EGZAMINATOR, egzaminator.IMIE, egzaminator.NAZWISKO, temp_osrodki_egzaminatora);
        end loop;
end;

begin
    for analityka_row in (select * from Analityka)
        loop
            dbms_output.put_line(
                    'EGZAMINATOR: ' || analityka_row.ID_EGZAMINATOR || ' ' || analityka_row.IMIE || ' ' ||
                    analityka_row.NAZWISKO
            );
            dbms_output.put_line('OSRODKI: ');
            for osrodek in (select * from table (analityka_row.OSRODKI))
                loop
                    dbms_output.put_line(osrodek.NAZWA_OSRODEK || ': ' || osrodek.LICZBA_EGZAMINOW);
                end loop;
            dbms_output.put_line(chr(10));
        end loop;
end;
