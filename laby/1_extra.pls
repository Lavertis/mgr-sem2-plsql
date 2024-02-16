-- Zadanie 1 dodatkowe:
-- Utworzyć w bazie danych tabelę o nazwie RaportEgz, która będzie zawierać dwie kolumny.
-- Pierwsza z nich będzie opisywać egzaminatora, druga rok - rok, miesiąc, liczbę egzaminów i liczbę studentów egzaminowanych przez egzaminatora.
-- Dane o egzaminatorze (Id, nazwisko, imie) należy umieścić w jednej kolumnie, pozostałe dane należy umieścić w postaci kolekcji,
-- której  elementy opisują rok, nazwę miesiąca, liczbę egzaminów i liczbę studentów w danym miesiącu.
-- Posortować dane o miesiącach w obrębie roku zgodnie z kolejnością ich występowania w roku.
-- Następnie proszę wyświetlić zawartośc tabeli RaportEgz.

-- TODO not finished

create or replace type TypEgzaminator as object
(
    id_egzaminator number(4),
    nazwisko       varchar2(50),
    imie           varchar2(25)
);
create or replace type TypEgzaminy as object
(
    rok         varchar(4),
    miesiac     varchar2(15),
    lEgzaminow  number(5),
    lStundentow number(6)
);
create or replace type TypKolEgzaminy is table of TypEgzaminy;
create table RaportEgz
(
    EgzaminatorInfo TypEgzaminator,
    EgzaminyInfo    TypKolEgzaminy
) nested table EgzaminyInfo store as AEgzaminyInfo;

declare
    RecEgzaminator TypEgzaminator := TypEgzaminator();
    cursor c1 is select id_egzaminator, nazwisko, imie
                 from egzaminatorzy
                 order by 1;
begin
    for vc1 in c1
        loop
            RecEgzaminator := TypEgzaminator(vc1.id_egzaminator, vc1.nazwisko, vc1.imie);
        end loop;
end ;