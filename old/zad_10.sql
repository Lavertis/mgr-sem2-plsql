-- Zadanie 10
-- Dla kazdego przedmiotu wskazac tych studentow, ktorzy zdawali egzamin w ostatnim dniu egzaminowania z tego
-- przedmiotu. Jesli nikt nie zdawal egzaminu z danego przedmiotu, nalezy wyswietlic odpowiedni komunikat.
-- W rozwiazaniu zadania nalezy wykorzystac podprogram (funkcja lub procedura) PL/SQL, ktory umozliwi wyznaczenie
-- daty ostatniego dnia egzaminowania z danego przedmiotu.


declare
    cursor przedmioty is
        select ID_PRZEDMIOT, NAZWA_PRZEDMIOT
        from PRZEDMIOTY;
    cursor studenci_z_ostatniego_dnia_egzaminowania(id_przedmiot number, ostatni_dzien date) is
        select S.ID_STUDENT, IMIE, NAZWISKO
        from STUDENCI S
                 JOIN EGZAMINY E on S.ID_STUDENT = E.ID_STUDENT
        where E.DATA_EGZAMIN = ostatni_dzien
        order by S.ID_STUDENT;
    ostatni_dzien date;

    function ostatni_dzien_egzaminowania(id_przedmiotu number) return date is
        ostatni_dzien date;
    begin
        select max(DATA_EGZAMIN) into ostatni_dzien from EGZAMINY where ID_PRZEDMIOT = id_przedmiotu;
        return ostatni_dzien;
    end;
begin
    for przedmiot in przedmioty
        loop
            DBMS_OUTPUT.PUT_LINE(przedmiot.ID_PRZEDMIOT || ' ' || przedmiot.NAZWA_PRZEDMIOT);
            ostatni_dzien := ostatni_dzien_egzaminowania(przedmiot.ID_PRZEDMIOT);
            if ostatni_dzien is null then
                DBMS_OUTPUT.PUT_LINE('Nikt nie zdawal egzaminu z danego przedmiotu');
            else
                DBMS_OUTPUT.PUT_LINE('Ostatni dzien egzaminowania: ' || ostatni_dzien);
                for student in studenci_z_ostatniego_dnia_egzaminowania(przedmiot.ID_PRZEDMIOT, ostatni_dzien)
                    loop
                        DBMS_OUTPUT.PUT_LINE(student.ID_STUDENT || ' ' || student.IMIE || ' ' || student.NAZWISKO);
                    end loop;
            end if;
            DBMS_OUTPUT.PUT_LINE(chr(10));
        end loop;
end;

