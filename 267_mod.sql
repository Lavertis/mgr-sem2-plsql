-- 267. Utworzyć tabelę o nazwie TAZEgzaminy, która będzie zawierała informację o liczbie
-- zdanych i niezdanych egzaminów w poszczególnych ośrodkach. Tabela powinna zawierać
-- cztery kolumny (identyfikator ośrodka, nazwa ośrodka, liczba zdanych i liczba
-- niezdanych egzaminów). Następnie dla tabeli Egzaminy zdefiniować odpowiedni
-- wyzwalacz, który w przypadku modyfikacji lub wstawienia nowego egzaminu spowoduje
-- aktualizację zawartości tabeli TAZEgzaminy.

CREATE TABLE TAZEgzaminy
(
    ID_OSRODEK        int,
    NAZWA_OSRODEK     varchar(255),
    EGZAMINY_ZDANE    int,
    EGZAMINY_NIEZDANE int
);

DECLARE
    vLiczbaZdanych    NUMBER;
    vLiczbaNiezdanych NUMBER;
BEGIN
    FOR vc1 IN (SELECT id_osrodek, nazwa_osrodek FROM Osrodki)
        LOOP
            SELECT COUNT(*)
            INTO vLiczbaZdanych
            FROM Egzaminy e
            WHERE e.id_osrodek = vc1.id_osrodek
              AND e.zdal = 'T';

            SELECT COUNT(*)
            INTO vLiczbaNiezdanych
            FROM Egzaminy e
            WHERE e.id_osrodek = vc1.id_osrodek
              AND e.zdal = 'N';

            INSERT INTO TAZEgzaminy (ID_OSRODEK, NAZWA_OSRODEK, EGZAMINY_ZDANE, EGZAMINY_NIEZDANE)
            VALUES (vc1.id_osrodek, vc1.nazwa_osrodek, vLiczbaZdanych, vLiczbaNiezdanych);
        END LOOP;
END;