-- Zadanie 2
-- Dla kazdego egzaminatora wskazac tych studentow, ktorych egzaminowal on w ciagu trzech ostatnich dni swojego
-- egzaminowania. Jezeli dany egzaminator nie przeprowadzil zadnego egzaminu, prosze wyswietlic komunikat "Brak
-- egzaminow". W odpowiedzi nalezy umiescic dane identyfikujace egzaminatora (identyfikator, nazwisko, imie),
-- dzien egzaminowania (w formacie DD-MM-YYYY) i egzaminowanych studentow (identyfikator, nazwisko, imie).
-- Zadanie prosze wykonac z uzyciem kursora.


declare
    cursor ostatnie_3_dni_egzaminowania(ID_EGZAMINATORA IN VARCHAR2) is
        select DISTINCT DATA_EGZAMIN
        from EGZAMINY E
        WHERE E.ID_EGZAMINATOR = ID_EGZAMINATORA
        order by DATA_EGZAMIN desc
            fetch first 3 rows only;
    cursor studenci_egzaminowani_w_dniu(DATA_EGZAMINU IN DATE, ID_EGZAMINATORA IN VARCHAR2) is
        select S.ID_STUDENT, NAZWISKO, IMIE
        from STUDENCI S
                 join EGZAMINY E on S.ID_STUDENT = E.ID_STUDENT
        where E.ID_EGZAMINATOR = ID_EGZAMINATORA
          and E.DATA_EGZAMIN = DATA_EGZAMINU;
    examFound boolean := false;
begin
    for egzaminator in (SELECT ID_EGZAMINATOR, NAZWISKO, IMIE FROM EGZAMINATORZY)
        loop
            examFound := false;
            dbms_output.put_line(
                    'Egzaminator: ' || egzaminator.ID_EGZAMINATOR || ' ' || egzaminator.NAZWISKO || ' ' ||
                    egzaminator.IMIE
            );

            for dzien in ostatnie_3_dni_egzaminowania(egzaminator.ID_EGZAMINATOR)
                loop
                    examFound := true;
                    dbms_output.put_line('Dzien egzaminowania: ' || to_char(dzien.DATA_EGZAMIN, 'dd-mm-yyyy'));
                    for student in studenci_egzaminowani_w_dniu(dzien.DATA_EGZAMIN, egzaminator.ID_EGZAMINATOR)
                        loop
                            dbms_output.put_line(
                                    'Student: ' || student.ID_STUDENT || ' ' || student.NAZWISKO || ' ' ||
                                    student.IMIE
                            );
                        end loop;
                end loop;
            if not examFound then
                dbms_output.put_line('Brak egzaminow');
            end if;
            DBMS_OUTPUT.put_line(chr(10));
        end loop;
end;