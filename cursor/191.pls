-- 191. Wskazać tych egzaminatorów, którzy przeprowadzili egzaminy w ciągu trzech ostatnich
-- dni egzaminowania. W odpowiedzi umieścić datę egzaminu oraz dane identyfikujące
-- egzamnatora tj. identyfikator, imię i nazwisko.

declare
    cursor c1 is select distinct data_egzamin from egzaminy order by 1 desc ;
    cursor c2 (pExamDate date) is select distinct g.id_egzaminator, nazwisko, imie
                                                    from egzaminatorzy g inner join egzaminy e
                                                    on g.id_egzaminator = e.id_egzaminator
                                                    where data_egzamin = pExamDate
                                                    order by 2 ;
begin
    for vc1 in c1 loop
        exit when c1%rowcount > 3 ;
        dbms_output.put_line('Exam date ' || to_char(vc1.data_egzamin, 'dd-mm-yyyy')) ;
        for vc2 in c2(vc1.data_egzamin) loop
            dbms_output.put_line(vc2.nazwisko || ' ' || vc2.imie || ' (' || vc2.id_egzaminator || ')') ;
        end loop ;
    end loop ;
end ;