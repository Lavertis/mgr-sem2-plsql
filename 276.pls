-- 276. Utworzyć funkcję składowaną, która będzie kontrolowała proces wprowadzania danych do
-- tabeli Egzaminy. Funkcja powinna zwrócić wartość FALSE, jeśli podjęto próbę
-- wprowadzenia egzaminu z przedmiotu, który został już zdany przez studenta. Jako
-- parametry funkcji przyjąć identyfikator studenta, identyfikator przedmiotu oraz wynik
-- egzaminu.

CREATE OR REPLACE FUNCTION is_exam_valid(
    student_id IN NUMBER,
    subject_id IN NUMBER,
    is_passed IN VARCHAR2
) RETURN boolean IS
    v_passed_exam_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_passed_exam_count
    FROM EGZAMINY
    WHERE ID_STUDENT = student_id
      AND ID_PRZEDMIOT = subject_id
      AND ZDAL = 'T';

    RETURN v_passed_exam_count = 0 OR is_passed = 'N';
END;


-- alternative
CREATE OR REPLACE FUNCTION sprawdz_egzamin(
    p_student_id IN NUMBER,
    p_przedmiot_id IN NUMBER
) RETURN BOOLEAN AS
    v_liczba_egzaminow NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_liczba_egzaminow
    FROM Egzaminy
    WHERE id_student = p_student_id
      AND id_przedmiot = p_przedmiot_id
      AND zdal = 'T';

    IF v_liczba_egzaminow > 0 THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
END sprawdz_egzamin;