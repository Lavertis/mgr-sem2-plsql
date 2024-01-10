-- 275. Utworzyć procedurę lub funkcję składowaną, która dokona weryfikacji poprawności
-- wartości pola Nr_ECDL w tabeli Studenci. Weryfikacja tej wartości jest dwuetapowa.
-- Pierwszy etap to sprawdzenie, czy wartość ta może wystąpić. Warunkiem istnienia tej
-- wartości jest zdanie przez studenta egzaminów ze wszystkich przedmiotów, które znajdują
-- się w tabeli Przedmioty. Drugi etap polega na sprawdzeniu, czy wartość występująca w tym
-- polu w danym wierszu jest równa identyfikatorowi studenta, którego ten wiersz dotyczy.
-- Następnie wykorzystać ten podprogram w bloku PL/SQL, w którym zostanie sprawdzony
-- każdy rekord w tabeli Studenci. Jeżeli istnieje rekord, który nie zostanie pozytywnie
-- zweryfikowany, należy go skopiować do tabeli St_NrInvalid, która zawiera kolumny
-- ID_Student, Nazwisko i Imie (tabelę należy utworzyć przed walidacją danych).

CREATE TABLE St_NrInvalid AS
SELECT ID_STUDENT, IMIE, NAZWISKO
FROM STUDENCI
WHERE 1 = 2;

CREATE OR REPLACE PROCEDURE verify_Nr_ECDL(
    p_id_student IN STUDENCI.ID_STUDENT%TYPE,
    p_nr_ecdl IN STUDENCI.NR_ECDL%TYPE,
    p_is_valid OUT BOOLEAN
) AS
    FUNCTION did_student_pass_all_exams RETURN BOOLEAN IS
        v_passed_subject_count NUMBER;
        v_subject_count        NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_passed_subject_count
        FROM EGZAMINY
        WHERE ID_STUDENT = p_id_student
          AND UPPER(ZDAL) = 'T';

        SELECT COUNT(DISTINCT ID_PRZEDMIOT) INTO v_subject_count FROM PRZEDMIOTY;

        RETURN v_passed_subject_count = v_subject_count;
    END did_student_pass_all_exams;
BEGIN
    p_is_valid := TRUE;
    IF did_student_pass_all_exams THEN
        IF p_nr_ecdl != p_id_student THEN
            p_is_valid := FALSE;
        END IF;
    ELSIF p_nr_ecdl IS NOT NULL THEN
        p_is_valid := FALSE;
    END IF;

END verify_Nr_ECDL;

DECLARE
    v_is_valid BOOLEAN;
BEGIN
    FOR student IN (SELECT * FROM STUDENCI)
        LOOP
            verify_Nr_ECDL(student.ID_STUDENT, student.NR_ECDL, v_is_valid);
            IF NOT v_is_valid THEN
                INSERT INTO St_NrInvalid VALUES (student.ID_STUDENT, student.IMIE, student.NAZWISKO);
            END IF;
        END LOOP;
END;

-- alternative
create or replace procedure isECDLNumberValid(
    pStudentId studenci.id_student%type,
    pECDLNumber studenci.nr_ecdl%type,
    pAllSubjects number,
    isValid out boolean
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

begin
    isValid := didPassedAll(pStudentId) and pECDLNumber = pStudentId;
end;

declare
    vECDLNumberValid boolean;
    vAllSubjects     number;
begin
    select count(*) into vAllSubjects from przedmioty;
    for c_st in (select * from studenci s where nr_ecdl is not null)
        loop
            isECDLNumberValid(c_st.id_student, c_st.nr_ecdl, vAllSubjects, vECDLNumberValid);
            if not vECDLNumberValid then
                insert into St_NrInvalid values (c_st.id_student, c_st.imie, c_st.nazwisko);
            end if;
        end loop;
end;
