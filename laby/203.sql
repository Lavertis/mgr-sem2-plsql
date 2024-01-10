-- 203. Dla tabeli Osrodki zdefiniować odpowiedni trigger, który podczas operacji usuwania
-- ośrodka z tej tabeli będzie kontrolował, czy w tabeli Egzaminy istnieją egzaminy
-- powiązane z tym ośrodkiem. Jeśli takie egzaminy istnieją, należy wyświetlić komunikat
-- "Nie można usunąć ośrodka, gdyż istnieją dla niego powiązane egzaminy".

CREATE OR REPLACE TRIGGER SprawdzEgzaminyPrzedUsunieciemOsrodkaTrigger
    BEFORE DELETE
    ON OSRODKI
    FOR EACH ROW
DECLARE
    vExamCount NUMBER;
BEGIN
    SELECT COUNT(*) INTO vExamCount FROM Egzaminy WHERE ID_OSRODEK = :OLD.ID_OSRODEK;
    IF vExamCount > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nie można usunąć ośrodka, gdyż istnieją dla niego powiązane egzaminy');
    END IF;
END;