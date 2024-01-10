-- 237. Utworzyć tabelę bazy danych o nazwie Analityka_Studenci. Tabela powinna zawierać
-- informacje o liczbie egzaminów każdego studenta w każdym z ośrodków. W tabeli
-- utworzyć kolumny opisujące studenta (identyfikator, Nazwisko i imię), ośrodek
-- (identyfikator i nazwa) oraz liczbę egzaminów studenta w danym ośrodku. Dane dotyczące
-- ośrodka i liczby egzaminów należy umieścić w kolumnie, będącej tabelą zagnieżdżoną.
-- Wprowadzić dane do tabeli Analityka_Studenci na podstawie danych zgromadzonych w
-- tabelach Egzaminy, Osrodki i Studenci.

CREATE OR REPLACE TYPE TypRecKolOsrodkow AS OBJECT
(
    id_osrodek    NUMBER(4),
    nazwa_osrodek VARCHAR2(50),
    legzaminow    NUMBER(5)
);

CREATE OR REPLACE TYPE TypKolOsrodkow IS TABLE OF TypRecKolOsrodkow;

CREATE TABLE Analityka_Studenci
(
    id_student  NUMBER(4),
    nazwisko    VARCHAR2(50),
    imie        VARCHAR2(25),
    KolOsrodkow TypKolOsrodkow
) NESTED TABLE KolOsrodkow STORE AS AKolOSrodkow;

-- copilot - nie wiem, czy dobrze
INSERT INTO Analityka_Studenci
SELECT s.id_student,
       s.nazwisko,
       s.imie,
       CAST(
               MULTISET(
               SELECT e.id_osrodek,
                      o.nazwa_osrodek,
                      COUNT(*)
               FROM Egzaminy e
                        JOIN Osrodki o ON e.id_osrodek = o.id_osrodek
               WHERE e.id_student = s.id_student
               GROUP BY e.id_osrodek,
                        o.nazwa_osrodek
           ) AS TypKolOsrodkow
       )
FROM Studenci s
GROUP BY s.id_student,
         s.nazwisko,
         s.imie;

-- lab - dobrze
DECLARE
    CURSOR c1 IS SELECT id_student, imie, nazwisko
                 FROM studenci
                 ORDER BY 3, 2;
    CURSOR c2 IS SELECT id_osrodek, nazwa_osrodek
                 FROM osrodki
                 ORDER BY 2;
    legzaminow  NUMBER;
    KolOsrodkow TypKolOsrodkow;
BEGIN
    FOR vc1 IN c1
        LOOP
            KolOsrodkow := TypKolOsrodkow();
            FOR vc2 IN c2
                LOOP
                    SELECT COUNT(*)
                    INTO legzaminow
                    FROM egzaminy
                    WHERE id_student = vc1.id_student
                      AND id_osrodek = vc2.id_osrodek;
                    KolOsrodkow.extend;
                    KolOsrodkow(c2%ROWCOUNT) := TypRecKolOsrodkow(vc2.id_osrodek, vc2.nazwa_osrodek, legzaminow);
                END LOOP;
            INSERT INTO Analityka_Studenci VALUES (vc1.id_student, vc1.nazwisko, vc1.imie, KolOsrodkow);
        END LOOP;
END;

SELECT id_student, nazwisko, imie, nt.id_osrodek, nt.nazwa_osrodek, nt.legzaminow
FROM Analityka_Studenci,
     TABLE (KolOsrodkow) nt;

SELECT *
FROM Analityka_Studenci;

