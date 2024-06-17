
--Gerenciamento (CRUD)
--Create
CREATE OR REPLACE PROCEDURE insert_estrela (
    p_id_estrela estrela.id_estrela%TYPE,
    p_nome estrela.nome%TYPE,
    p_classificacao estrela.classificacao%TYPE,
    p_massa estrela.massa%TYPE,
    p_X estrela.X%TYPE,
    p_Y estrela.Y%TYPE,
    p_Z estrela.Z%TYPE
) IS
BEGIN
    INSERT INTO estrela (ID_ESTRELA, NOME, CLASSIFICACAO, MASSA, X, Y, Z)
    VALUES (p_id_estrela, p_nome, p_classificacao, p_massa, p_X, p_Y, p_Z);
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Estrela inserida com sucesso.');

EXCEPTION
    
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20003, 'Estrela com ID ja inserida');
            
END insert_estrela;

--Delete
CREATE OR REPLACE PROCEDURE remove_estrela (
    p_id_estrela estrela.id_estrela%TYPE
) IS
    e_not_removed EXCEPTION;
BEGIN
    DELETE FROM estrela WHERE id_estrela = p_id_estrela;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE e_not_removed;
    ELSE
        COMMIT;
    END IF;
EXCEPTION
    WHEN e_not_removed THEN
        RAISE_APPLICATION_ERROR(-20005, 'Nenhuma Estrela removida');
END remove_estrela;


--Update
CREATE OR REPLACE PROCEDURE atualiza_estrela (
    p_id_estrela estrela.id_estrela%TYPE,
    p_nome estrela.nome%TYPE := NULL,
    p_classificacao estrela.classificacao%TYPE := NULL,
    p_massa estrela.massa%TYPE := NULL,
    p_X estrela.X%TYPE := NULL,
    p_Y estrela.Y%TYPE := NULL,
    p_Z estrela.Z%TYPE := NULL
) IS
    e_not_found EXCEPTION;
BEGIN
    UPDATE estrela
    SET 
        nome = NVL(p_nome, nome),
        classificacao = NVL(p_classificacao, classificacao),
        massa = NVL(p_massa, massa),
        x = NVL(p_X, x),
        y = NVL(p_Y, y),
        z = NVL(p_Z, z)
    WHERE id_estrela = p_id_estrela;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE e_not_found;
    ELSE
        COMMIT;
    END IF;
EXCEPTION
    WHEN e_not_found THEN
        RAISE_APPLICATION_ERROR(-20006, 'Nenhuma Estrela encontrada para atualização');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20007, 'Erro desconhecido: ' || SQLERRM);
END atualiza_estrela;

--Read
CREATE OR REPLACE PROCEDURE read_estrela (
    p_id_estrela estrela.id_estrela%TYPE,
    p_nome OUT estrela.nome%TYPE,
    p_classificacao OUT estrela.classificacao%TYPE,
    p_massa OUT estrela.massa%TYPE,
    p_X OUT estrela.X%TYPE,
    p_Y OUT estrela.Y%TYPE,
    p_Z OUT estrela.Z%TYPE
) IS
BEGIN
    SELECT NOME, CLASSIFICACAO, MASSA, X, Y, Z
    INTO p_nome, p_classificacao, p_massa, p_X, p_Y, p_Z
    FROM estrela
    WHERE id_estrela = p_id_estrela;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Estrela não encontrada com o ID: ' || p_id_estrela);
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Erro desconhecido: ' || SQLERRM);
END read_estrela;


-- Relatorio cientista
CREATE OR REPLACE PROCEDURE CIENTISTA_RELATORIO_PLANETA(
    cur OUT SYS_REFCURSOR
) IS
BEGIN
    OPEN cur FOR 
        SELECT p.ID_ASTRO AS PLANETA, 
        p.MASSA AS MASSA, 
        p.RAIO AS RAIO, 
        p.CLASSIFICACAO AS CLASSIFICACAO, 
        op.ESTRELA AS ORBITA, 
        s.NOME AS SISTEMA
        FROM PLANETA p
        left JOIN ORBITA_PLANETA op ON p.ID_ASTRO = op.PLANETA
        left JOIN ESTRELA e ON e.ID_ESTRELA = op.ESTRELA
        left JOIN SISTEMA s ON s.ESTRELA = e.ID_ESTRELA;
END CIENTISTA_RELATORIO_PLANETA;


CREATE OR REPLACE PROCEDURE CIENTISTA_RELATORIO_ESTRELA(
    cur OUT SYS_REFCURSOR
) IS
BEGIN
    OPEN cur FOR 
        SELECT e.ID_ESTRELA AS ID_ESTRELA, 
        e.NOME AS NOME, 
        e.CLASSIFICACAO AS CLASSIFICACAO, 
        e.MASSA AS MASSA,
        e.X AS COORD_X,
        e.Y AS COORD_Y, 
        e.Z AS COORD_Z , 
        s.NOME AS SISTEMA, 
        oe.ORBITANTE AS ESTRELA_ORBITANTE, 
        oe.DIST_MIN AS DIST_MIN_ORBITA, 
        oe.DIST_MAX AS DIST_MAX_ORBITA, 
        oe.PERIODO AS PERIODO_ORBITA
        FROM ESTRELA e
        left JOIN ORBITA_ESTRELA oe ON e.ID_ESTRELA = oe.ORBITADA
        left JOIN SISTEMA s ON e.ID_ESTRELA = s.ESTRELA;

END CIENTISTA_RELATORIO_ESTRELA;


CREATE OR REPLACE PROCEDURE CIENTISTA_RELATORIO_SISTEMA(
    cur OUT SYS_REFCURSOR
) IS
BEGIN
    OPEN cur FOR 
        SELECT * FROM SISTEMA;

END CIENTISTA_RELATORIO_SISTEMA;

CREATE OR REPLACE PROCEDURE CIENTISTA_RELATORIO_ORBITA_ESTRELA(
    cur OUT SYS_REFCURSOR
) IS
BEGIN
    OPEN cur FOR 
        SELECT * FROM ORBITA_ESTRELA;

END CIENTISTA_RELATORIO_ORBITA_ESTRELA;

CREATE OR REPLACE PROCEDURE CIENTISTA_RELATORIO_ORBITA_PLANETA(
    cur OUT SYS_REFCURSOR
) IS
BEGIN
    OPEN cur FOR 
        SELECT * FROM ORBITA_PLANETA;

END CIENTISTA_RELATORIO_ORBITA_PLANETA;
-- Relatorio Cientista b (BONUS)
-- Dado uma estrela e um intervalo de distancias retorna lista de estrelas que dentre o intervalo de distancias 
CREATE OR REPLACE PROCEDURE buscar_estrelas_por_distancia (
    p_id_estrela IN VARCHAR2,
    p_distancia_min IN NUMBER,
    p_distancia_max IN NUMBER,
    p_result OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_result FOR
    SELECT 
        ID_ESTRELA2 AS ESTRELA,
        DISTANCIA,
        e.NOME AS NOME,
        e.CLASSIFICACAO AS CLASSIFICACAO,
        e.MASSA AS MASSA,
        e.X AS COORD_X,
        e.Y AS COORD_Y,
        e.Z AS COORD_Z
    FROM 
        MV_DISTANCIAS_ESTRELAS
        JOIN ESTRELA e ON e.ID_ESTRELA = ID_ESTRELA2
    WHERE 
        ID_ESTRELA1 = p_id_estrela
        AND DISTANCIA BETWEEN p_distancia_min AND p_distancia_max
    UNION
    SELECT 
        ID_ESTRELA1 AS ESTRELA,
        DISTANCIA,
        e.NOME AS NOME,
        e.CLASSIFICACAO AS CLASSIFICACAO,
        e.MASSA AS MASSA,
        e.X AS COORD_X,
        e.Y AS COORD_Y,
        e.Z AS COORD_Z
    FROM 
        MV_DISTANCIAS_ESTRELAS
        JOIN ESTRELA e ON e.ID_ESTRELA = ID_ESTRELA1
    WHERE 
        ID_ESTRELA2 = p_id_estrela
        AND DISTANCIA BETWEEN p_distancia_min AND p_distancia_max;
END buscar_estrelas_por_distancia;

DECLARE
    v_cursor SYS_REFCURSOR;
    v_estrela VARCHAR2(31);
    v_distancia NUMBER;
    v_nome VARCHAR2(31); 
    v_classificacao VARCHAR2(31);
    v_massa NUMBER;
    v_coord_x NUMBER;
    v_coord_y NUMBER;
    v_coord_z NUMBER;
BEGIN
    -- Chama a procedure
    buscar_estrelas_por_distancia('1    Aqr', 170, 200, v_cursor);

    -- Lê os resultados
    LOOP
        FETCH v_cursor INTO v_estrela, v_distancia, v_nome, v_classificacao, v_massa, v_coord_x, v_coord_y, v_coord_z;
        EXIT WHEN v_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Estrela: ' || v_estrela || ' Distância: ' || v_distancia || ' Nome: ' || v_nome || 
                             ' Classificação: ' || v_classificacao || ' Massa: ' || v_massa || 
                             ' Coord_X: ' || v_coord_x || ' Coord_Y: ' || v_coord_y || ' Coord_Z: ' || v_coord_z);
    END LOOP;

    -- Fecha o cursor
    CLOSE v_cursor;
END;
/





-- Relatorio Cientista c (BONUS)
CREATE MATERIALIZED VIEW distancia_estrelas
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
    SELECT coluna1, coluna2, coluna3
    FROM tabela_original
    WHERE condição;


select * from estrela;

CREATE OR REPLACE FUNCTION calcular_distancia(
    x1 NUMBER, y1 NUMBER, z1 NUMBER,
    x2 NUMBER, y2 NUMBER, z2 NUMBER
) RETURN NUMBER IS
BEGIN
    RETURN SQRT((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) + (z2 - z1) * (z2 - z1));
END calcular_distancia;


CREATE INDEX IDX_MV_DISTANCIAS_ESTRELAS_ID1 ON MV_DISTANCIAS_ESTRELAS (ID_ESTRELA1);

CREATE INDEX IDX_MV_DISTANCIAS_ESTRELAS_ID2 ON MV_DISTANCIAS_ESTRELAS (ID_ESTRELA2);


CREATE MATERIALIZED VIEW MV_DISTANCIAS_ESTRELAS
BUILD IMMEDIATE
REFRESH COMPLETE ON COMMIT
AS
SELECT 
    e1.ID_ESTRELA AS ID_ESTRELA1, 
    e2.ID_ESTRELA AS ID_ESTRELA2,
    calcular_distancia(e1.X, e1.Y, e1.Z, e2.X, e2.Y, e2.Z) AS DISTANCIA
FROM 
    ESTRELA e1
JOIN 
    ESTRELA e2
ON 
    e1.ID_ESTRELA < e2.ID_ESTRELA;

select * from MV_DISTANCIAS_ESTRELAS where ID_ESTRELA1 = '1    Aqr';

    SELECT 
        ID_ESTRELA2 AS ESTRELA,
        DISTANCIA
    FROM 
        MV_DISTANCIAS_ESTRELAS
    WHERE 
        ID_ESTRELA1 = '1    Aqr'
        AND DISTANCIA BETWEEN 10 AND 200
    UNION
    SELECT 
        ID_ESTRELA1 AS ESTRELA,
        DISTANCIA
    FROM 
        MV_DISTANCIAS_ESTRELAS
    WHERE 
        ID_ESTRELA2 = '1    Aqr'
        AND DISTANCIA BETWEEN 10 AND 200;




