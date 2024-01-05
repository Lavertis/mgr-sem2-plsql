-- Zadanie z tablicy z kolekcją w kolekcji
-- TODO not working

CREATE OR REPLACE TYPE TypStudent AS OBJECT
(
    id_student NUMBER(4),
    nazwisko   VARCHAR2(50),
    imie       VARCHAR2(25)
);
CREATE OR REPLACE TYPE TypKolStudent IS TABLE OF TypStudent;

CREATE OR REPLACE TYPE TypEgzaminator AS OBJECT
(
    id_egzaminator NUMBER(4),
    nazwisko       VARCHAR2(50),
    imie           VARCHAR2(25),
    egzaminowani_s TypKolStudent
);
CREATE OR REPLACE TYPE TypKolEgzaminator IS TABLE OF TypEgzaminator;

CREATE TABLE Raport_Roczny
(
    rok           VARCHAR2(4),
    miesiac       VARCHAR2(15),
    egzaminatorzy TypKolEgzaminator
) NESTED TABLE egzaminatorzy STORE AS AEgzaminatorzyInfo (NESTED TABLE egzaminowani_s STORE AS AStudenci);

DECLARE
    egzaminatorzy TypKolEgzaminator;
    k             NUMBER := 0 ;
    CURSOR c1 IS SELECT DISTINCT EXTRACT(YEAR FROM data_egzamin) AS year, EXTRACT(MONTH FROM data_egzamin) AS month
                 FROM egzaminy
                 GROUP BY EXTRACT(YEAR FROM data_egzamin), EXTRACT(MONTH FROM data_egzamin)
                 ORDER BY 1, 2;

    FUNCTION getKolEgzaminatorzy(d_year VARCHAR(4), d_month VARCHAR2(15)) RETURN TypKolEgzaminator IS
        Col_Egzaminatorzy TypKolEgzaminator := TypKolEgzaminator();
        CURSOR c_egzaminatorzy IS SELECT DISTINCT e.id_egzaminator, egz.imie, egz.nazwisko
                                  FROM egzaminy e
                                           INNER JOIN egzaminatorzy egz ON e.id_egzaminator = egz.id_egzaminator
                                  WHERE EXTRACT(YEAR FROM data_egzamin) = d_year
                                    AND EXTRACT(MONTH FROM data_egzamin) = d_month;
        CURSOR c_studenci(id_egzaminator NUMBER, year VARCHAR(4), month VARCHAR2(15)) IS SELECT DISTINCT e.id_student, imie, nazwisko
                                                                FROM studenci s
                                                                         INNER JOIN egzaminy e ON e.id_student = s.id_student
                                                                WHERE e.id_egzaminator = id_egzaminator
                                                                  AND EXTRACT(YEAR FROM data_egzamin) = year
                                                                  AND EXTRACT(MONTH FROM data_egzamin) = month;
        Col_Studenci TypKolStudent;
        i            NUMBER := 0 ;
        j            NUMBER := 0;
    BEGIN
        FOR vc_egzaminatorzy IN c_egzaminatorzy
            LOOP
                Col_Egzaminatorzy.EXTEND;

                Col_Egzaminatorzy(i).imie := vc_egzaminatorzy.imie;
                Col_Egzaminatorzy(i).nazwisko := vc_egzaminatorzy.nazwisko;
                Col_Egzaminatorzy(i).id_egzaminator := vc_egzaminatorzy.id_egzaminator;

                Col_Studenci := TypKolStudent();

                FOR vc_studenci IN c_studenci(vc_egzaminatorzy.id_egzaminator, d_year, d_month)
                    LOOP
                        Col_Studenci.EXTEND;

                        Col_Studenci(j).id_student := vc_studenci.id_student;
                        Col_Studenci(j).imie := vc_studenci.imie;
                        Col_Studenci(j).nazwisko := vc_studenci.nazwisko;

                        j := j + 1;
                    END LOOP;

                Col_Egzaminatorzy(i).egzaminowani_s := Col_Studenci;

                i := i + 1;
            END LOOP;

        RETURN Col_Egzaminatorzy;

    END;

BEGIN
    egzaminatorzy := TypKolEgzaminator();
    FOR vc_daty IN c1
        LOOP
            egzaminatorzy.EXTEND;
            egzaminatorzy(k) := getKolEgzaminatorzy(vc_daty.year, vc_daty.month);
            k := k + 1;

            INSERT INTO Raport_Roczny VALUES (vc_daty.year, vc_daty.month, egzaminatorzy(k));
        END LOOP;

END;