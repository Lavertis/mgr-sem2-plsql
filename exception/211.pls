-- 211. Który egzaminator i kiedy egzaminował więcej niż 5 osób w ciągu jednego dnia? Podać
-- identyfikator, Nazwisko i imię egzaminatora, a także informacje o liczbie egzaminowanych
-- osób oraz dniu, w których takie zdarzenie miało miejsce. Zadanie wykonać wykorzystując
-- wyjątek użytkownika.

DECLARE
    Uwaga EXCEPTION;
       CURSOR CEgzaminator IS
    SELECT
        et.id_egzaminator, et.imie, et.nazwisko, en.data_egzamin, COUNT(distinct id_student) AS Liczba
    FROM
             egzaminatorzy et
        INNER JOIN egzaminy en ON et.id_egzaminator = en.id_egzaminator
    GROUP BY
        et.id_egzaminator, et.imie, et.nazwisko, en.data_egzamin;
BEGIN
    FOR vCur IN CEgzaminator LOOP
        BEGIN
            IF vCur.Liczba >5 THEN RAISE Uwaga;
            END IF;
        EXCEPTION
            WHEN Uwaga THEN
                Dbms_output.Put_line(vCur.id_egzaminator || ' ' ||
vCur.Nazwisko || ' ' || vCur.Imie || ' ' || vCur.data_egzamin || ' ' || vCur.Liczba) ;
        END;
    END LOOP;
END;