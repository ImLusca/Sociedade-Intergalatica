-- Relatorio cientista
CREATE OR REPLACE PACKAGE relatorio_cientista AS

    PROCEDURE CIENTISTA_RELATORIO_PLANETA(
        cur OUT SYS_REFCURSOR
    );
    
    PROCEDURE CIENTISTA_RELATORIO_ESTRELA(
        cur OUT SYS_REFCURSOR
    );
    
    PROCEDURE CIENTISTA_RELATORIO_SISTEMA(
        cur OUT SYS_REFCURSOR
    );
    
    PROCEDURE buscar_estrelas_por_distancia (
        p_id_estrela IN VARCHAR2,
        p_distancia_min IN NUMBER,
        p_distancia_max IN NUMBER,
        p_result OUT SYS_REFCURSOR
    );

END relatorio_cientista;

CREATE OR REPLACE PACKAGE BODY relatorio_cientista AS

    -- Retorna lista com informações dos planetas
    PROCEDURE CIENTISTA_RELATORIO_PLANETA(
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

    -- Retorna lista com informações das estrelas
    PROCEDURE CIENTISTA_RELATORIO_ESTRELA(
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

    -- Retorna lista com informações dos sistemas
    PROCEDURE CIENTISTA_RELATORIO_SISTEMA(
        cur OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN cur FOR 
            SELECT * FROM SISTEMA;
    END CIENTISTA_RELATORIO_SISTEMA;

    /*
    Relatorio Cientista b (BONUS)
    Dado uma estrela e um intervalo de distancias retorna lista de estrelas que dentre o intervalo de distancias 
    Checa o na view materializada as distâncias entre a estrela dada como input com as demais estrelas e checa se
    está entre o intervalo solicitado, como na view materializada tem apenas uma tupla para uma distância entre duas
    estrelas foi preciso checar se a estrela dada como input estava em ID_ESTRELA1 ou ID_ESTRELA2 e por isso a utilização
    de duas buscas e as unindo com UNION
    */
    PROCEDURE buscar_estrelas_por_distancia (
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

END relatorio_cientista;
/*
    Relatorio Cientista c (BONUS)
 
    View utilizada para melhorar a performance no cálculo de distâncias entre estrelas. 
    Por se tratar de uma view materializada, as distâncias entre duas estrelas são 
    calculadas apenas uma vez e salvas no banco de dados. Diferentemente de uma view comum, 
    que é recalculada toda vez que uma sessão é iniciada, a view materializada permite otimizar
    a consulta. Por esse motivo, também decidimos criar um índice para `ID_ESTRELA2`, já que será 
    preciso buscar tanto em `ID_ESTRELA1` quanto em `ID_ESTRELA2` ao procurar por uma estrela. 
    Calculamos apenas uma vez a distância entre as estrelas X e Y, evitando recalcular a distância entre Y e X.
*/

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
FROM ESTRELA e1
JOIN ESTRELA e2 ON e1.ID_ESTRELA < e2.ID_ESTRELA;

