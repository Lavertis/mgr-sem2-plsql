-- 199. Dla tabeli Egzaminy zdefiniować wyzwalacz, który będzie wstawiał wartość w polu
-- Punkty w momencie wstawienia nowego rekordu lub aktualizacji rekordu istniejącego.
-- Kolumna będzie przechowywać informację o liczbie punktów zdobytych na egzaminie
-- przez studenta. Każdemu studentowi, który zdał egzamin, należy przyznać liczbę punktów
-- z przedziału 3 do 5 (z dokładnością do dwóch miejsc po przecinku), a studentowi, który
-- nie zdał egzaminu – liczbę punktów z przedziału 2 do 2.99 (również z dokładnością do
-- dwóch miejsc po przecinku).

CREATE OR REPLACE TRIGGER punkty_egzamin
    BEFORE INSERT OR UPDATE OF zdal
    ON egzaminy
    FOR EACH ROW
BEGIN
    CASE
        WHEN INSERTING THEN IF :NEW.zdal = 'T' THEN
            :NEW.punkty := round(dbms_random.value(3, 5), 2);
        ELSE
            :NEW.punkty := round(dbms_random.value(2, 2.99), 2);
        END IF;
        WHEN UPDATING ('zdal') THEN IF :new.zdal = 'T' AND :old.zdal = 'N' THEN
            :NEW.punkty := round(dbms_random.value(3, 5), 2);
        END IF;

        END CASE;
END;

CREATE OR REPLACE TRIGGER punkty_egzamin
    BEFORE INSERT OR UPDATE
    ON egzaminy
    FOR EACH ROW
BEGIN
    CASE
        WHEN UPDATING ('ZDAL') THEN IF :NEW.zdal = 'T' THEN
            :NEW.punkty := round(dbms_random.value(3, 5), 2);
        ELSIF :NEW.zdal = 'N' AND :OLD.zdal IS NULL THEN
            :NEW.punkty := round(dbms_random.value(2, 2.99), 2);
        END IF;
        WHEN INSERTING THEN IF :NEW.zdal = 'T' THEN
            :NEW.punkty := round(dbms_random.value(3, 5), 2);
        ELSE
            :NEW.punkty := round(dbms_random.value(2, 2.99), 2);
        END IF;
        END CASE;
END;

insert into studenci
values ('007007', 'Bond', 'James', null, null, null);

insert into egzaminy (id_egzamin, id_student, id_przedmiot, id_osrodek, id_egzaminator, data_egzamin, zdal)
values (4444, '007007', 1, 1, '0004', to_date('17-11-2023', 'dd-mm-yyyy'), 'N');

SELECT *
FROM EGZAMINY
where id_egzamin = 4444;

UPDATE egzaminy
SET zdal = 'T'
where id_egzamin = 4444;
