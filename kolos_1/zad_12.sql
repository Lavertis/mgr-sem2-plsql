-- Zadanie 12
-- Dla kazdego egzaminatora o nazwisku Muryjas wskazac tych studentow, ktorzy zdawali u niego egzaminy w ostatnim dniu
-- egzaminowania przez tego egzaminatora. Jezeli egzaminator o podanym nazwisku nie istnieje, prosze wyswietlic
-- komunikat "Brak egzaminatora o podanym nazwisku". Jezeli dany egzaminator o tym nazwisku nie przeprowadzil zadnego
-- egzaminu, prosze wyswietlic komunikat "Brak egzaminow". W odpowiedzi umiescic dane identyfikujace egzaminatora tj.
-- jego identyfikator, nazwisko i imie, date egzaminu (w formacie DD-MM-YYYY) oraz dane identyfikujace studenta tj.
-- jego identyfikator, nazwisko i imie. Zadanie nalezy wykonac z uzyciem kursora.

declare
    cursor egzaminatorzy_muryjas is select *
                                    from EGZAMINATORZY
                                    where NAZWISKO = 'Muryjas';
    cursor studenci_zdajacy_u_egzaminatora_danego_dnia(id_egzaminatora number, dzien date) is
        select distinct S.ID_STUDENT, IMIE, NAZWISKO
        FROM STUDENCI S
                 join LAB.EGZAMINY E on S.ID_STUDENT = E.ID_STUDENT
        where E.ID_EGZAMINATOR = id_egzaminatora
          and E.DATA_EGZAMIN = dzien;
    ostatni_dzien      date;
    brak_egzaminatorow boolean := true;

    function ostatni_dzien_egzaminowania_egzaminatora(id_egzaminatora number) return date is
        ostatni_dzien date;
    begin
        select max(DATA_EGZAMIN) into ostatni_dzien from EGZAMINY where ID_EGZAMINATOR = id_egzaminatora;
        return ostatni_dzien;
    exception
        when NO_DATA_FOUND then
            return null;
    end;
begin
    for egzaminator in egzaminatorzy_muryjas
        loop
            brak_egzaminatorow := false;
            DBMS_OUTPUT.PUT_LINE(
                    'Egzaminator: ' || egzaminator.ID_EGZAMINATOR || ' ' ||
                    egzaminator.IMIE || ' ' ||
                    egzaminator.NAZWISKO || ' ' ||
                    to_char(ostatni_dzien, 'DD-MM-YYYY')
            );

            ostatni_dzien := ostatni_dzien_egzaminowania_egzaminatora(egzaminator.ID_EGZAMINATOR);
            if ostatni_dzien is null then
                DBMS_OUTPUT.PUT_LINE('Brak egzaminow');
                continue;
            end if;
            for student in studenci_zdajacy_u_egzaminatora_danego_dnia(egzaminator.ID_EGZAMINATOR, ostatni_dzien)
                loop
                    DBMS_OUTPUT.PUT_LINE(
                            'Student: ' || student.ID_STUDENT || ' ' || student.IMIE || ' ' || student.NAZWISKO
                    );
                end loop;
            DBMS_OUTPUT.PUT_LINE(chr(10));
        end loop;
    if brak_egzaminatorow then
        DBMS_OUTPUT.PUT_LINE('Brak egzaminatorow o podanym nazwisku');
    end if;
end;