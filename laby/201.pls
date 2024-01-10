-- 201. Utworzyć tabelę o nazwie TLOEgzaminy, która będzie zawierać informacje o liczbie
-- egzaminów przeprowadzonych w poszczególnych ośrodkach. Następnie zdefiniować
-- odpowiedni wyzwalacz dla tabeli Egzaminy, który w momencie wstawienia nowego
-- egzaminu spowoduje aktualizację danych w tabeli TLOEgzaminy.

CREATE TABLE TLOEgzaminy AS
SELECT O.ID_OSRODEK, NAZWA_OSRODEK, COUNT(*) AS LICZBA_EGZAMINOW
FROM OSRODKI O
         INNER JOIN EGZAMINY E ON O.ID_OSRODEK = E.ID_OSRODEK
GROUP BY O.ID_OSRODEK, NAZWA_OSRODEK;

CREATE OR REPLACE TRIGGER TLOEgzaminyTrigger
    AFTER INSERT
    ON EGZAMINY
    FOR EACH ROW
BEGIN
    UPDATE TLOEgzaminy
    SET LICZBA_EGZAMINOW = LICZBA_EGZAMINOW + 1
    WHERE ID_OSRODEK = :NEW.ID_OSRODEK;
END;
