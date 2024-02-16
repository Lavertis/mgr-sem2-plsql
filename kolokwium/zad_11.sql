-- Zadanie 11
-- Utworzyc w bazie danych tabele o nazwie StudExamDates. Tabela powinna zawierac informacje o studentach oraz
-- datach zdanych egzaminow z poszczegolnych przedmiotow. W tabeli utworzyc cztery kolumny. Trzy kolumny beda opisywac
-- studenta (identyfikator, imie i nazwisko). Czwarta - przedmiot (nazwa przedmiotu) oraz date zdanego egzaminu z tego
-- przedmiotu. Dane dotyczace przedmiotu i daty egzaminu nalezy umiescic w kolumnie bedacej kolekcja typu tabela
-- zagniezdzona. Wprowadzic dane do tabeli StudExamDates na podstawie danych zgromadzonych w tabelach Egzaminy,
-- Studenci i Przedmioty. Nastepnie wyswietlic dane znajdujace sie w tabeli StudExamDates.


create or replace type Przedmiot_Egzamin_Typ as object
(
    nazwa_przedmiotu      varchar2(100),
    data_zdanego_egzaminu date
);
create or replace type Przedmiot_Egzamin_Tab as table of Przedmiot_Egzamin_Typ;

create table Stud_Exam_Dates
(
    id_student          number(10)   not null,
    imie                varchar2(15) not null,
    nazwisko            varchar2(25) not null,
    przedmioty_egzaminy Przedmiot_Egzamin_Tab
) nested table przedmioty_egzaminy store as przedmioty_egzaminy_tab;

declare
    cursor studenci is
        select *
        from STUDENCI;
    cursor przedmioty is
        select *
        from PRZEDMIOTY;
    data_egzaminu date;
    temp_przedmioty_egzaminy Przedmiot_Egzamin_Tab;

    function data_zdania_egzaminu_przez_studenta_z_przedmiotu(id_przedmiotu number, id_studenta varchar2) return date is
        data_zdania date;
    begin
        select DATA_EGZAMIN
        into data_zdania
        from EGZAMINY
        where ID_PRZEDMIOT = id_przedmiotu
          and ID_STUDENT = id_studenta
          and ZDAL = 'T'
            fetch first 1 row only;
        return data_zdania;
    exception
        when NO_DATA_FOUND then
            return null;
    end;
begin
    for student in studenci
        loop
            temp_przedmioty_egzaminy := Przedmiot_Egzamin_Tab();
            for przedmiot in przedmioty
                loop
                    data_egzaminu := data_zdania_egzaminu_przez_studenta_z_przedmiotu(
                            przedmiot.ID_PRZEDMIOT,
                            student.ID_STUDENT);
                    if data_egzaminu is not null then
                        temp_przedmioty_egzaminy.extend;
                        temp_przedmioty_egzaminy(temp_przedmioty_egzaminy.count) := Przedmiot_Egzamin_Typ(
                                przedmiot.NAZWA_PRZEDMIOT,
                                data_egzaminu);
                    end if;
                end loop;
            insert into Stud_Exam_Dates
            values (student.ID_STUDENT, student.IMIE, student.NAZWISKO, temp_przedmioty_egzaminy);
        end loop;
end;

begin
    for stud_exams in (select * from STUD_EXAM_DATES)
        loop
            DBMS_OUTPUT.PUT_LINE('Student: ' || stud_exams.IMIE || ' ' || stud_exams.NAZWISKO);
            for exam_date in (select * from table (stud_exams.przedmioty_egzaminy))
                loop
                    DBMS_OUTPUT.PUT_LINE(
                            'Przedmiot: ' || exam_date.nazwa_przedmiotu ||
                            ' Data zdania: ' || exam_date.data_zdanego_egzaminu);
                end loop;
        end loop;
end;