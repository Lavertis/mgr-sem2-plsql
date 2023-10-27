-- 216. Przeprowadzić kontrolę danych w tabeli Studenci, polegającą na weryfikacji możliwości
-- istnienia wartości w kolumnach Nr_ECDL i Data_ECDL. Wartości w tych kolumnach
-- mogą istnieć tylko wówczas, gdy student zdał wszystkie przedmioty. Zadanie należy
-- rozwiązać z użyciem techniki wyjątków. Jako wyjątek należy uznać istnienie wartości w
-- podanych w kolumnach w sytuacji, gdy student nie zdał wszystkich przedmiotów. Jeśli
-- zostanie zidentyfikowany taki student to należy wyświetlić jego dane, tj. identyfikator,
-- nazwisko i imię.

-- TODO finish this
-- declare
--     cursor c1 is
--         select *
--         from STUDENCI
--         WHERE NR_ECDL IS NOT NULL
--           AND DATA_ECDL IS NOT NULL;
--     cursor przedmioty is
--         select ID_PRZEDMIOT
--         from PRZEDMIOTY;
--     cursor czy_student_zdal (id_studenta STUDENCI.ID_STUDENT%TYPE, id_przedmiotu PRZEDMIOTY.ID_PRZEDMIOT%TYPE) is
--         select count(ID_STUDENT) as liczba
--         from EGZAMINY
--         WHERE ID_STUDENT = id_studenta
--           AND ID_PRZEDMIOT = id_przedmiotu
--           AND ZDAL = 'T';
--     liczba number;
-- begin
--     for rekord in c1 loop
--         for rekord2 in przedmioty loop
--             begin
--                 open czy_student_zdal(rekord.ID_STUDENT, rekord2.ID_PRZEDMIOT);
--                 fetch czy_student_zdal into liczba;
--                 close czy_student_zdal;
--                 if liczba = 0 then
--                     raise no_data_found;
--                 end if;
--             exception
--                 when no_data_found then
--                     dbms_output.put_line('Student ' || rekord.ID_STUDENT || ' ' || rekord.NAZWISKO || ' ' || rekord.IMIE || ' nie zdal wszystkich przedmiotow');
--             end;
--         end loop;
--     end loop;
-- end;

CREATE OR REPLACE PROCEDURE SprawdzECDL
AS
    v_egzamin_count   NUMBER;
    v_przedmiot_count NUMBER;
    ost_egzamin       DATE;
BEGIN
    SELECT COUNT(id_przedmiot)
    INTO v_przedmiot_count
    FROM przedmioty;
    FOR rec IN (SELECT Id_student, Nr_ECDL, Data_ECDL FROM studenci WHERE Nr_ECDL IS NOT NULL OR Data_ECDL IS NOT NULL)
        LOOP
            SELECT MAX(DATA_EGZAMIN)
            INTO ost_egzamin
            FROM egzaminy e
            WHERE e.id_student = rec.id_student
              and zdal = 'T';

            SELECT COUNT(*)
            INTO v_egzamin_count
            FROM egzaminy
            WHERE Id_student = rec.Id_student
              AND Zdal = 'T';

            IF v_egzamin_count != v_przedmiot_count THEN
                RAISE_APPLICATION_ERROR(
                        -20002,
                        'Student ' || rec.Id_student ||
                        ' nie zdał jeszcze wszystkich przedmiotow, a mimo to są podane Nr_ECDL lub Data_ECDL.'
                );
            END IF;
            IF rec.Data_ECDL != ost_egzamin THEN
                RAISE_APPLICATION_ERROR(
                        -20002,
                        'Student ' || rec.Id_student || ' ma niepoprawna date w polu Data_ECDL'
                );
            END IF;
        END LOOP;
END;