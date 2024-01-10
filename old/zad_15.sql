-- Zadanie 15
-- Ktory egzaminator nie przeprowadzil egzaminow w poszczegolnych latach? Dla kazdego roku, w ktorym odbyly sie
-- egzaminy, nalezy wskazac egzaminatora, ktory w danym roku nie prowadzil egzaminow. W odpowiedzi nalezy umiescic dane
-- o roku (w formacie YYYY) oraz pelne informacje o egzaminatorze (identyfikator, nazwisko, imię). W zadaniu nalezy
-- wykorzystac technike wyjatkow.

declare
    NieEgzaminowalException exception;
    cursor lata_egzaminow is select distinct extract(year from DATA_EGZAMIN) as rok
                             from EGZAMINY order by rok;

    function czy_egzaminator_egzaminowal_w_roku(id_egzaminatora number, rok number) return boolean is
        cursor egzaminy_egzaminatora is select distinct ID_EGZAMINATOR
                                        from EGZAMINY
                                        where extract(year from DATA_EGZAMIN) = rok
                                          and ID_EGZAMINATOR = id_egzaminatora;
    begin
        for s in egzaminy_egzaminatora
            loop
                return true;
            end loop;
        return false;
    end;
begin
    for rok_data in lata_egzaminow
        loop
            dbms_output.put_line('Rok: ' || rok_data.rok);
            for egzaminator in (select * from EGZAMINATORZY order by ID_EGZAMINATOR)
                loop
                    begin
                        if not czy_egzaminator_egzaminowal_w_roku(EGZAMINATOR.ID_EGZAMINATOR, rok_data.rok) then
                            raise NieEgzaminowalException;
                        end if;
                    exception
                        when NieEgzaminowalException then
                            dbms_output.put_line(
                                    'Egzaminator: ' || egzaminator.ID_EGZAMINATOR || ' ' ||
                                    egzaminator.IMIE || ' ' || egzaminator.NAZWISKO
                            );
                    end;
                end loop;
        end loop;
end;