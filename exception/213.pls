-- 213. Przeprowadzić kontrolę, czy w ośrodku (ośrodkach) o nazwie LBS przeprowadzono
-- egzaminy. Dla każdego ośrodka o podanej nazwie, w którym odbył się egzamin, wyświetlić
-- odpowiedni komunikat podający liczbę egzaminów. Jeśli nie ma ośrodka o podanej nazwie,
-- wyświetlić komunikat o treści "Ośrodek o podanej nazwie nie istnieje". Jeśli w ośrodku nie
-- było egzaminu, należy wyświetlić komunikat "Ośrodek nie uczestniczył w egzaminach". Do
-- rozwiązania zadania wykorzystać wyjątki systemowe i/lub wyjątki użytkownika.

DECLARE
    Uwaga Exception;
    CURSOR Cosrodek IS
        SELECT o.id_osrodek,
               o.nazwa_osrodek,
               COUNT(e.id_egzamin) AS Liczba
        FROM osrodki o
                 LEFT JOIN egzaminy e
                           ON o.id_osrodek = e.id_osrodek
        WHERE upper(nazwa_osrodek) = 'LBS'
        GROUP BY o.id_osrodek, o.nazwa_osrodek;
    VRekOsrod Cosrodek%ROWTYPE;
BEGIN
    OPEN Cosrodek;
    FETCH Cosrodek INTO VRekOsrod;
    IF Cosrodek%NOTFOUND THEN
        dbms_output.put_line('Ośrodek o podanej nazwie nie istnieje');
    ELSE
        WHILE Cosrodek%FOUND
            LOOP
                BEGIN
                    IF VRekOsrod.Liczba = 0 THEN
                        RAISE Uwaga;
                    END IF;
                    Dbms_output.Put_line(VRekOsrod.nazwa_osrodek || ' przeprowadzil egzaminow: ' || VRekOsrod.Liczba);

                EXCEPTION
                    WHEN Uwaga THEN
                        Dbms_output.Put_line('Ośrodek nie uczestniczył w egzaminach') ;
                END;
                FETCH Cosrodek INTO VRekOsrod;
            END LOOP;
    END IF;
    CLOSE Cosrodek;
END;