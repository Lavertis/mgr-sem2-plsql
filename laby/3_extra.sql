-- Zbudować pakiet o nazwie ECDL_Validate, który będzie zawierał funkcje (procedury) umożliwiające kontrolę
-- poprawności danych wprowadzanych do bazy danych.
-- Walidacja powinna obejmować następujące operacje:
-- - wprowadzanie egzaminów
-- - modyfikację egzaminów
-- - modyfikację wartości Nr_ECDL i Data_ECDL w tabeli Studenci.
--
-- Kontrola poprawności lub modyfikacji danych opisujących egzaminy powinna uniemożliwić:
-- - wprowadzenie zdanego egzaminu z przedmiotu, jeśli przedmiot jest już zdany przez danego studenta
-- - wprowadzenie niezdanego egzaminu z przedmiotu, jeśli przedmiot jest już zdany przez danego studenta
-- - data egzaminu nie może być późniejsza niż bieżąca data plus 1 dzień
-- - liczba punktów dla egzaminu zdanego musi być z przedziału od 3 do 5, a dla egzaminu niezdanego od 2 do 2.99
-- - dane w kolumnie Zdal muszą należeć do zbioru (T, N)
--
-- Kontrola danych wprowadzanych do kolumn Nr_ECDL i Data_ECDL powinna uniemożliwić:
-- - wprowadzenie wartości w kolumnie Nr_ECDL i Data_ECDL jeśli student nie zdał wszystkich przedmiotów
-- - wprowadzenie wartości w kolumnie Data_ECDL innej niż data ostatniego zdanego egzaminu z ostatniego
--   zdawanego przedmiotu


create or replace package ECDL_Validate as
    function wprEgzPrzyZdanym(p_id_student VARCHAR2, p_id_przedmiot NUMBER, p_zdany VARCHAR2) return BOOLEAN;
    function sprawdzenieDaty(p_data Date) return BOOLEAN;
    function sprawdzeniePunkty(p_punkty NUMBER) return BOOLEAN;
    function sprawdzenieZdany(p_zdany VARCHAR2) return BOOLEAN;
    function sprawdzenieECDL(p_id_student VARCHAR2) return BOOLEAN;
    function sprawdzenieDaty(p_id_student VARCHAR2) return BOOLEAN;
end ECDL_Validate;

create or replace package body ECDL_Validate as

    function wprEgzPrzyZdanym(p_id_student VARCHAR2, p_id_przedmiot NUMBER, p_zdany VARCHAR2) return BOOLEAN is
        v_zdany number;
    BEGIN
        SELECT count(*)
        INTO v_zdany
        FROM egzaminy
        WHERE ID_STUDENT = id_student
          AND ID_PRZEDMIOT = id_przedmiot
          AND ZDAL = 'T';

        IF v_zdany != 1 THEN
            DBMS_OUTPUT.PUT_LINE('student nie zdal jeszcze z tego przedmiotu, rekord mozna wprowadzic');
            RETURN FALSE;
        ELSE
            IF p_zdany = 'T' THEN
                DBMS_OUTPUT.PUT_LINE('nie mozna wprowadzic zdanego egzaminu dla zdanego przedmiotu');
            ELSE
                DBMS_OUTPUT.PUT_LINE('nie mozna wprowadzic niezdanego egzaminu dla zdanego przedmiotu');
            END IF;
        END IF;
        RETURN TRUE;
    END;
    function sprawdzenieDaty(p_data Date) return BOOLEAN is
    begin
        IF p_data > SYSDATE + 1 THEN
            DBMS_OUTPUT.PUT_LINE('Data egzaminu nie może być późniejsza niż bieżąca data plus 1 dzień');
            RETURN FALSE;
        ELSE
            RETURN TRUE;
        END IF;
    end;
    function sprawdzeniePunkty(p_punkty NUMBER) return BOOLEAN is
    begin
        IF (p_punkty < 3 OR p_punkty > 5) THEN
            DBMS_OUTPUT.PUT_LINE('Liczba punktów nie spełnia wymagań');
            RETURN FALSE;
        ELSE
            RETURN TRUE;
        END IF;
    end;
    function sprawdzenieZdany(p_zdany VARCHAR2) return BOOLEAN is
    begin
        return TRUE;
    end;
    function sprawdzenieECDL(p_id_student VARCHAR2) return BOOLEAN is
    begin
        return TRUE;
    end;
    function sprawdzenieDaty(p_id_student VARCHAR2) return BOOLEAN is
    begin
        return TRUE;
    end;


end ECDL_Validate;

-- CREATE OR REPLACE PACKAGE BODY ECDL_Validate AS
--     PROCEDURE ValidateExam(
--         p_Id_student IN studenci.Id_student%TYPE,
--         p_Id_przedmiot IN przedmioty.Id_przedmiot%TYPE,
--         p_Data_egzamin IN DATE,
--         p_Zdal IN VARCHAR2,
--         p_Punkty IN NUMBER
--     ) IS
--         v_przedmiot_zdany NUMBER;
--         v_ostatni_egzamin DATE;
--     BEGIN
--         -- Sprawdzenie, czy student zdał już przedmiot
--         SELECT COUNT(*)
--         INTO v_przedmiot_zdany
--         FROM egzaminy
--         WHERE Id_student = p_Id_student
--           AND Id_przedmiot = p_Id_przedmiot
--           AND Punkty IS NOT NULL;
--
--         IF p_Punkty IS NOT NULL AND v_przedmiot_zdany > 0 THEN
--             RAISE_APPLICATION_ERROR(-20001, 'Nie można zdawać ponownie zdanego przedmiotu');
--         ELSIF p_Punkty IS NULL AND v_przedmiot_zdany = 0 THEN
--             RAISE_APPLICATION_ERROR(-20002, 'Nie można zdawać niezdanego przedmiotu');
--         END IF;
--
--         -- Sprawdzenie daty egzaminu
--         SELECT MAX(Data_egzamin)
--         INTO v_ostatni_egzamin
--         FROM egzaminy
--         WHERE Id_student = p_Id_student
--           AND Id_przedmiot = p_Id_przedmiot;
--
--         IF p_Data_egzamin < v_ostatni_egzamin THEN
--             RAISE_APPLICATION_ERROR(-20003,
--                                     'Data egzaminu nie może być wcześniejsza niż data ostatniego zdanego egzaminu');
--         END IF;
--
--         IF p_Data_egzamin > SYSDATE + 1 THEN
--             RAISE_APPLICATION_ERROR(-20004, 'Data egzaminu nie może być późniejsza niż bieżąca data plus 1 dzień');
--         END IF;
--
--         IF (p_Punkty IS NOT NULL AND (p_Punkty < 3 OR p_Punkty > 5)) OR
--            (p_Punkty IS NULL AND (p_Punkty < 2 OR p_Punkty > 2.99)) THEN
--             RAISE_APPLICATION_ERROR(-20005, 'Liczba punktów nie spełnia wymagań');
--         END IF;
--
--         IF p_Zdal NOT IN ('T', 'N') THEN
--             RAISE_APPLICATION_ERROR(-20006, 'Zdalność musi być oznaczona jako "T" lub "N"');
--         END IF;
--     END ValidateExam;
--
--     PROCEDURE ValidateModifyExam(
--         p_ID_Egzamin IN egzaminy.ID_Egzamin%TYPE,
--         p_Id_student IN studenci.Id_student%TYPE,
--         p_Id_przedmiot IN przedmioty.Id_przedmiot%TYPE,
--         p_Data_egzamin IN DATE,
--         p_Zdal IN VARCHAR2,
--         p_Punkty IN NUMBER
--     ) IS
--         v_przedmiot_zdany NUMBER;
--         v_ostatni_egzamin DATE;
--     BEGIN
--         -- Sprawdzenie, czy student zdał już przedmiot
--         SELECT COUNT(*)
--         INTO v_przedmiot_zdany
--         FROM egzaminy
--         WHERE Id_student = p_Id_student
--           AND Id_przedmiot = p_Id_przedmiot
--           AND Punkty IS NOT NULL;
--
--         IF p_Punkty IS NOT NULL AND v_przedmiot_zdany > 0 THEN
--             RAISE_APPLICATION_ERROR(-20001, 'Nie można modyfikować na zdany egzamin');
--         ELSIF p_Punkty IS NULL AND v_przedmiot_zdany = 0 THEN
--             RAISE_APPLICATION_ERROR(-20002, 'Nie można modyfikować na niezdanego egzaminu');
--         END IF;
--
--         -- Sprawdzenie daty egzaminu
--         SELECT MAX(Data_egzamin)
--         INTO v_ostatni_egzamin
--         FROM egzaminy
--         WHERE Id_student = p_Id_student
--           AND Id_przedmiot = p_Id_przedmiot
--           AND ID_Egzamin <> p_ID_Egzamin;
--
--         IF p_Data_egzamin < v_ostatni_egzamin THEN
--             RAISE_APPLICATION_ERROR(-20003,
--                                     'Data egzaminu nie może być wcześniejsza niż data ostatniego zdanego egzaminu');
--         END IF;
--
--         IF p_Data_egzamin > SYSDATE + 1 THEN
--             RAISE_APPLICATION_ERROR(-20004, 'Data egzaminu nie może być późniejsza niż bieżąca data plus 1 dzień');
--         END IF;
--
--         IF (p_Punkty IS NOT NULL AND (p_Punkty < 3 OR p_Punkty > 5)) OR
--            (p_Punkty IS NULL AND (p_Punkty < 2 OR p_Punkty > 2.99)) THEN
--             RAISE_APPLICATION_ERROR(-20005, 'Liczba punktów nie spełnia wymagań');
--         END IF;
--
--         IF p_Zdal NOT IN ('T', 'N') THEN
--             RAISE_APPLICATION_ERROR(-20006, 'Zdalność musi być oznaczona jako "T" lub "N"');
--         END IF;
--     END ValidateModifyExam;
--
--     PROCEDURE ValidateModifyECDL(
--         p_Id_student IN studenci.Id_student%TYPE,
--         p_Nr_ECDL IN studenci.nr_ECDL%TYPE,
--         p_Data_ECDL IN studenci.data_ECDL%TYPE
--     ) IS
--         v_ostatni_egzamin DATE;
--     BEGIN
--         -- Sprawdzenie daty ostatniego zdanego egzaminu
--         SELECT MAX(Data_egzamin)
--         INTO v_ostatni_egzamin
--         FROM egzaminy
--         WHERE Id_student = p_Id_student
--           AND Punkty IS NOT NULL;
--
--         IF p_Nr_ECDL IS NOT NULL AND v_ostatni_egzamin IS NULL THEN
--             RAISE_APPLICATION_ERROR(-20007,
--                                     'Student musi zdać wszystkie przedmioty przed wprowadzeniem wartości Nr_ECDL');
--         END IF;
--
--         IF p_Nr_ECDL IS NOT NULL AND p_Data_ECDL <= v_ostatni_egzamin THEN
--             RAISE_APPLICATION_ERROR(-20008, 'Data ECDL musi być późniejsza niż data ostatniego zdanego egzaminu');
--         END IF;
--     END ValidateModifyECDL;
-- END ECDL_Validate;
