-- 268. W tabeli Studenci dokonać aktualizacji danych w kolumnie Nr_ECDL oraz Data_ECDL.
-- Wartość Nr_ECDL powinna być równa identyfikatorowi studenta, a Data_ECDL – dacie
-- ostatniego zdanego egzaminu. Wartości te należy wstawić tylko dla tych studentów,
-- którzy zdali już wszystkie przedmioty. W rozwiązaniu zastosować podprogramy typu
-- funkcja i procedura (samodzielnie określić strukturę kodu źródłowego w PL/SQL).


-- -- Tworzenie funkcji sprawdzającej, czy student zdał wszystkie przedmioty
-- CREATE OR REPLACE FUNCTION czyZdalWszystkiePrzedmioty(student_id IN VARCHAR2) RETURN BOOLEAN IS
--     liczba_przedmiotow NUMBER;
--     liczba_zdan NUMBER;
-- BEGIN
--     SELECT COUNT(*) INTO liczba_przedmiotow FROM PRZEDMIOTY;
--
--     SELECT COUNT(*) INTO liczba_zdan
--     FROM EGZAMINY E
--     WHERE E.ID_STUDENT = student_id
--     AND ZDAL = 'T';
--
--     IF liczba_przedmiotow > 0 AND liczba_przedmiotow = liczba_zdan THEN
--         RETURN TRUE; -- Zdał wszystkie przedmioty
--     ELSE
--         RETURN FALSE; -- Nie zdał wszystkich przedmiotów
--     END IF;
-- END;
--
-- -- Tworzenie procedury do aktualizacji danych Nr_ECDL i Data_ECDL dla studentów
-- CREATE OR REPLACE PROCEDURE aktualizujDaneECDL AS
--     v_student STUDENCI%ROWTYPE; -- Zmienna do przechowywania danych z tabeli STUDENCI
--     my_varchar_variable VARCHAR2(10); -- Zmienna do przechowywania wartości z funkcji
-- BEGIN
--     FOR v_student IN (SELECT ID_STUDENT FROM STUDENCI)
--         LOOP
--             DBMS_OUTPUT.PUT_LINE('Aktualizacja danych dla studenta o ID: ' || v_student.ID_STUDENT);
--             my_varchar_variable :=
--                     CASE czyZdalWszystkiePrzedmioty(v_student.ID_STUDENT)
--                         WHEN true THEN 'true'
--                         WHEN false THEN 'false'
--                         ELSE NULL
--                         END;
--             DBMS_OUTPUT.PUT_LINE(my_varchar_variable);
--             IF czyZdalWszystkiePrzedmioty(v_student.ID_STUDENT) THEN
--                 -- Aktualizacja Nr_ECDL i Data_ECDL tylko dla studentów, którzy zaliczyli wszystkie przedmioty
--                 UPDATE Studenci S
--                 SET Nr_ECDL   = v_student.ID_STUDENT,
--                     Data_ECDL = (SELECT MAX(DATA_EGZAMIN)
--                                  FROM EGZAMINY E
--                                  WHERE E.ID_STUDENT = v_student.ID_STUDENT
--                                    AND ZDAL = 'T')
--                 WHERE S.ID_STUDENT = v_student.ID_STUDENT;
--
--                 COMMIT; -- Zatwierdzenie zmian
--             END IF;
--         END LOOP;
-- END;


-- CREATE OR REPLACE FUNCTION czyZdalWszystkiePrzedmioty(student_id IN VARCHAR2) RETURN NUMBER IS
--     liczba_przedmiotow NUMBER;
--     liczba_zdan        NUMBER;
-- BEGIN
--     SELECT COUNT(*) INTO liczba_przedmiotow FROM PRZEDMIOTY;
--
--     SELECT COUNT(*)
--     INTO liczba_zdan
--     FROM EGZAMINY E
--     WHERE E.ID_STUDENT = student_id
--       AND ZDAL = 'T';
--
--     IF liczba_przedmiotow > 0 AND liczba_przedmiotow = liczba_zdan THEN
--         RETURN 1; -- Zdał wszystkie przedmioty
--     ELSE
--         RETURN 0; -- Nie zdał wszystkich przedmiotów
--     END IF;
-- END;
--
-- -- Procedure to update Nr_ECDL and Data_ECDL for students who passed all subjects
-- CREATE OR REPLACE PROCEDURE aktualizujDaneECDL AS
-- BEGIN
--     FOR v_student IN (SELECT ID_STUDENT FROM STUDENCI)
--         LOOP
--         DBMS_OUTPUT.PUT_LINE('Aktualizacja danych dla studenta o ID: ' || v_student.ID_STUDENT);
--             IF czyZdalWszystkiePrzedmioty(v_student.ID_STUDENT) = 1 THEN
--                 -- Update Nr_ECDL and Data_ECDL only for students who passed all subjects
--                 UPDATE Studenci S
--                 SET Nr_ECDL   = v_student.ID_STUDENT,
--                     Data_ECDL = (SELECT MAX(DATA_EGZAMIN)
--                                  FROM EGZAMINY E
--                                  WHERE E.ID_STUDENT = v_student.ID_STUDENT
--                                    AND ZDAL = 'T')
--                 WHERE S.ID_STUDENT = v_student.ID_STUDENT;
--             END IF;
--         END LOOP;
--     COMMIT; -- Commit changes after all updates
-- END;

DECLARE
   FUNCTION getDataOstatniegoEgzaminu(student_id IN VARCHAR) RETURN DATE IS
      last_exam_date DATE;
   BEGIN
      SELECT MAX(DATA_EGZAMIN) INTO last_exam_date
      FROM EGZAMINY
      WHERE ID_STUDENT = student_id AND zdal = 'T';
      RETURN last_exam_date;
   END getDataOstatniegoEgzaminu;

   FUNCTION czyZdalWszystkiePrzedmioty(student_id IN VARCHAR) RETURN BOOLEAN IS
      liczba_egzaminow NUMBER;
       vCourseNumber number ;
       vPassedCourseNumber number ;
   BEGIN
     SELECT COUNT(*) INTO vCourseNumber FROM przedmioty ;
     SELECT COUNT(*) INTO vPassedCourseNumber FROM egzaminy
     		WHERE id_student = student_id and zdal = 'T' ;
		 IF vCourseNumber = vPassedCourseNumber THEN
     		RETURN TRUE ;
     ELSE
     		RETURN FALSE;
		END IF ;
   END czyZdalWszystkiePrzedmioty;

   PROCEDURE updateStudentData(student_id IN VARCHAR) AS
      data DATE;
   BEGIN
      data := getDataOstatniegoEgzaminu(student_id);
      UPDATE Studenci
      SET Nr_ECDL = student_id,
          Data_ECDL = data
      WHERE ID_Student = student_id;
      COMMIT;
   END updateStudentData;

BEGIN
   FOR student_id IN (SELECT ID_Student FROM Studenci) LOOP
      IF czyZdalWszystkiePrzedmioty(student_id.ID_Student) THEN
         updateStudentData(student_id.ID_Student);
      END IF;
   END LOOP;
END;