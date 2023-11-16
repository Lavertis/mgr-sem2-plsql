-- 274. Utworzyć procedurę składowaną, która dokona weryfikacji poprawności daty ECDL w
-- tabeli Studenci. Data ta może istnieć w tej kolumnie, jeśli student zdał wszystkie
-- przedmioty oraz musi być większa od daty ostatniego zdanego egzaminu przez studenta,
-- jeśli pierwszy warunek jest spełniony. Jeśli powyższe warunki nie są spełnione, wówczas
-- należy błędny rekord skopiować do tabeli St_DateInvalid, która zawiera kolumny
-- ID_Student, Nazwisko i Imie (tabelę należy utworzyć przed walidacją danych).

CREATE TABLE STUDENCI_INVALID AS
SELECT ID_STUDENT, IMIE, NAZWISKO
FROM STUDENCI
WHERE 1 = 0;

-- TODO this is not working
CREATE OR REPLACE PROCEDURE VALIDATE_ECDL_DATE(
    student IN STUDENCI%ROWTYPE,
    is_valid OUT BOOLEAN
) IS
    vCourseNumber       NUMBER;
    vPassedCourseNumber NUMBER;
    data_egzaminu       DATE;

    FUNCTION dataOstatniegoEgzaminu(student_id IN VARCHAR) RETURN DATE IS
        data_egzaminu DATE;
    BEGIN
        SELECT MAX(DATA_EGZAMIN) INTO data_egzaminu FROM EGZAMINY WHERE ID_STUDENT = student_id;
        RETURN data_egzaminu;
    END dataOstatniegoEgzaminu;

    FUNCTION czyZdalWszystkiePrzedmioty(student_id IN VARCHAR) RETURN BOOLEAN IS
        vCourseNumber       NUMBER;
        vPassedCourseNumber NUMBER;
    BEGIN
        SELECT COUNT(*) INTO vCourseNumber FROM przedmioty;
        SELECT COUNT(*)
        INTO vPassedCourseNumber
        FROM egzaminy
        WHERE id_student = student_id
          AND zdal = 'T';
        IF vCourseNumber = vPassedCourseNumber THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END czyZdalWszystkiePrzedmioty;
BEGIN
    is_valid := FALSE;

    IF czyZdalWszystkiePrzedmioty(student.ID_STUDENT) THEN
        data_egzaminu := dataOstatniegoEgzaminu(student.ID_STUDENT);
        IF data_egzaminu IS NOT NULL AND STUDENT.DATA_ECDL > data_egzaminu THEN
            is_valid := TRUE;
        END IF;
    END IF;
END;

DECLARE
    cursor studenci is
        select *
        from studenci;
BEGIN
    for student in studenci
        loop
            DECLARE
                is_valid BOOLEAN;
            BEGIN
                VALIDATE_ECDL_DATE(student, is_valid);
                IF NOT is_valid THEN
                    INSERT INTO STUDENCI_INVALID VALUES (student.ID_STUDENT, student.IMIE, student.NAZWISKO);
                END IF;
            END;
        END LOOP;
    COMMIT;
END;


-- TODO alternative which works
create table St_DateInvalid as
select id_student, imie, nazwisko
from studenci
where 1 = 2;

create or replace procedure isECDLValid(
    pStudentId studenci.id_student%type,
    pECDLDate studenci.data_ecdl%type,
    pAllSubjects number, isValid out boolean
) as
    function didPassedAll(pStudentId studenci.id_student%type) return boolean is
        vPassedSubjects number;
    begin
        select count(distinct id_przedmiot)
        into vPassedSubjects
        from egzaminy
        where id_student = pStudentId
          and upper(zdal) = 'T';

        if vPassedSubjects < pAllSubjects then
            return false;
        end if;

        return true;
    end didPassedAll;

    function getLastExam(pStudentId studenci.id_student%type) return date is
        vLastExam date;

    begin
        select max(data_egzamin)
        into vLastExam
        from egzaminy
        where id_student = pStudentId
          and upper(zdal) = 'T';

        return vLastExam;
    end getLastExam;

begin
    isValid := (pECDLDate is null) or
               (pECDLDate is not null and (didPassedAll(pStudentId) and pECDLDate > getLastExam(pStudentId)));
end;

declare
    vECDLDateValid boolean;
    vAllSubjects   number;
begin
    select count(*) into vAllSubjects from przedmioty;
    for c_st in (select * from studenci s)
        loop
            isECDLValid(c_st.id_student, c_st.data_ecdl, vAllSubjects, vECDLDateValid);

            if not vECDLDateValid then
                insert into St_DateInvalid values (c_st.id_student, c_st.imie, c_st.nazwisko);
            end if;
        end loop;
end;