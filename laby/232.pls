-- 232. Utworzyć tabelę bazy danych o nazwie Indeks. Tabela powinna zawierać informacje o
-- studencie (identyfikator, Nazwisko, imię), przedmiotach (nazwa przedmiotu), z których
-- student zdał już swoje egzaminy oraz datę zdanego egzaminu. Lista przedmiotów wraz z
-- datami dla danego studenta powinna być kolumną typu tabela zagnieżdżona. Dane w tabeli
-- Indeks należy wygenerować na podstawie zawartości tabeli Egzaminy, Studenci oraz Przedmioty.


CREATE OR REPLACE TYPE Typ_Przedmiot_Data
AS OBJECT
(
    Nazwa         VARCHAR2(40),
    Data_egzaminu DATE
);

CREATE OR REPLACE TYPE Typ_ZPD IS TABLE OF Typ_Przedmiot_Data;

CREATE TABLE indeks
(
    id_student      VARCHAR2(7),
    nazwisko        VARCHAR2(50),
    imie            VARCHAR2(25),
    ZdanePrzedmioty Typ_ZPD
) NESTED TABLE ZdanePrzedmioty STORE AS ZdanePrzed_Tab;

DECLARE
    kolekcja Typ_ZPD := Typ_ZPD();
    CURSOR c_studenci IS SELECT DISTINCT s.id_student, nazwisko, imie
                         FROM Studenci s;

    FUNCTION f_utworz_kolekcje(ids studenci.id_student%TYPE) RETURN Typ_ZPD IS
        kolekcja_przedmiotow Typ_ZPD := Typ_ZPD();
        rekord               Typ_Przedmiot_Data;
        CURSOR c_przedmioty IS SELECT nazwa_przedmiot, data_egzamin
                               FROM Egzaminy e
                                        INNER JOIN Przedmioty p ON e.id_przedmiot = p.id_przedmiot
                               WHERE id_student = ids
                                 AND zdal = 'T';
    BEGIN
        FOR vc IN c_przedmioty
            LOOP
                rekord := Typ_Przedmiot_Data(vc.nazwa_przedmiot, vc.data_egzamin);
                kolekcja_przedmiotow.EXTEND();
                kolekcja_przedmiotow(c_przedmioty%ROWCOUNT) := rekord;
            END LOOP;
        RETURN kolekcja_przedmiotow;
    END f_utworz_kolekcje;
BEGIN
    FOR vcs IN c_studenci
        LOOP
            kolekcja := f_utworz_kolekcje(vcs.id_student);
            INSERT INTO indeks VALUES (vcs.id_student, vcs.nazwisko, vcs.imie, kolekcja);
        END LOOP;
END;

SELECT ind.id_student, ind.nazwisko, ind.imie, nt.nazwa, TO_CHAR(nt.data_egzaminu, 'dd-mm-yyyy') ExamDate
FROM indeks ind,
     TABLE (zdaneprzedmioty) nt;

UPDATE TABLE (SELECT ind.zdaneprzedmioty FROM indeks ind WHERE ind.id_student = '0000001')
SET data_egzaminu = TO_DATE('30-11-2023', 'dd-mm-yyyy')
WHERE nazwa = 'Wytwarzanie aplikacji sterowane modelami';

DELETE TABLE (SELECT ind.zdaneprzedmioty FROM indeks ind WHERE ind.id_student = '0000001')
WHERE nazwa = 'Wytwarzanie aplikacji sterowane modelami';