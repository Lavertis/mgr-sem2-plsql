-- 235. Utworzyć tabelę bazy danych o nazwie Analityka. Tabela powinna zawierać informacje o
-- liczbie egzaminów poszczególnych egzaminatorów w poszczególnych ośrodkach. W tabeli
-- utworzyć kolumny opisujące ośrodek (identyfikator oraz nazwa), egzaminatora
-- (identyfikator, imię i Nazwisko) oraz liczbę egzaminów egzaminatora w danym ośrodku.
-- Dane dotyczące egzaminatora i liczby jego egzaminów należy umieścić w kolumnie,
-- będącej tabelą zagnieżdżoną. Wprowadzić dane do tabeli Analityka na podstawie danych
-- zgromadzonych w tabelach Egzaminy, Osrodki i Egzaminatorzy.
-- Następnie wyświetlić dane znajdujące się w tabeli Analityka.

CREATE OR REPLACE TYPE TypRecKolOsrodkow AS OBJECT
(
    id_osrodek    NUMBER(4),
    nazwa_osrodek VARCHAR2(50),
    legzaminow    NUMBER(5)
);

CREATE OR REPLACE TYPE TypKolOsrodkow IS TABLE OF TypRecKolOsrodkow;

CREATE TABLE Analityka
(
    id_egzaminator NUMBER(4),
    nazwisko       VARCHAR2(50),
    imie           VARCHAR2(25),
    KolOsrodkow    TypKolOsrodkow
) NESTED TABLE KolOsrodkow STORE AS AKolOSrodkow;

DECLARE
    CURSOR c1 IS SELECT id_egzaminator, imie, nazwisko
                 FROM egzaminatorzy
                 ORDER BY 3, 2;
    CURSOR c2 IS SELECT id_osrodek, nazwa_osrodek
                 FROM osrodki
                 ORDER BY 2;

    legzaminow  NUMBER;
    KolOsrodkow TypKolOsrodkow;
BEGIN
    FOR vc1 IN c1
        LOOP
            -- iteracja po egzaminatorach
            KolOsrodkow := TypKolOsrodkow();
            FOR vc2 IN c2
                LOOP
                    -- iteracja po osrodkach
                    SELECT COUNT(*)
                    INTO legzaminow
                    FROM egzaminy
                    WHERE id_egzaminator = vc1.id_egzaminator
                      AND id_osrodek = vc2.id_osrodek;
                    KolOsrodkow.extend;
                    KolOsrodkow(c2%ROWCOUNT) := TypRecKolOsrodkow(vc2.id_osrodek, vc2.nazwa_osrodek, legzaminow);
                END LOOP;
            INSERT INTO Analityka VALUES (vc1.id_egzaminator, vc1.nazwisko, vc1.imie, KolOsrodkow);
        END LOOP;
END;

SELECT id_egzaminator, nazwisko, imie, nt.id_osrodek, nt.nazwa_osrodek, nt.legzaminow
FROM analityka,
     TABLE (KolOsrodkow) nt;

