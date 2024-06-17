CREATE OR REPLACE PACKAGE RELATORIO_COMANDANTE AS

    PROCEDURE info_planetas (cur1 OUT SYS_REFCURSOR, cur2 OUT SYS_REFCURSOR);
    PROCEDURE planetas_preocupantes (p_cpi_lider LIDER.CPI%TYPE, cur OUT SYS_REFCURSOR);
    PROCEDURE planetas_potencial_expansao (p_max_dist NUMBER, p_nacao NACAO.NOME%TYPE, cur OUT SYS_REFCURSOR);
    
    --bonus
    PROCEDURE GET_DOMINANCIAS_PERIODO (
            p_start_date IN DATE,
            p_end_date IN DATE,
            p_cursor OUT SYS_REFCURSOR
        );
    
END RELATORIO_COMANDANTE; 
/
CREATE OR REPLACE PACKAGE BODY RELATORIO_COMANDANTE AS 

    PROCEDURE info_planetas ( cur1 OUT SYS_REFCURSOR, cur2 OUT SYS_REFCURSOR ) IS
        BEGIN

            -- nacao dominante atual, datas de fim e inicio da ultima domina��o
            OPEN cur1 FOR
                SELECT
                    PLANETA.ID_ASTRO,
                    DOMINANCIA.NACAO,
                    DOMINANCIA.DATA_INI,
                    DOMINANCIA.DATA_FIM
                FROM
                    PLANETA
                LEFT JOIN DOMINANCIA ON PLANETA.ID_ASTRO = DOMINANCIA.PLANETA
                                    AND DOMINANCIA.DATA_FIM IS NULL
                ORDER BY
                    PLANETA.ID_ASTRO;
        
            -- quantidades de comunidades, esp�cies, habitantes e faccoes presentes
            OPEN cur2 FOR
                SELECT
                    PLANETA.ID_ASTRO,
                    COUNT(DISTINCT COMUNIDADE.ESPECIE || COMUNIDADE.NOME), --num comuniades
                    COUNT(DISTINCT COMUNIDADE.ESPECIE), --num especies
                    COALESCE(SUM(COMUNIDADE.QTD_HABITANTES), 0), -- num habitantes
                    COUNT(DISTINCT PARTICIPA.FACCAO), -- num faccoes presentes
                    STATS_MODE(PARTICIPA.FACCAO) --facc�o majorit�ria (STATS_MODE uma fun��o que dado um conjunto de valores retorna o valor com maior frequ�ncia)
                FROM
                    PLANETA
                LEFT JOIN HABITACAO ON PLANETA.ID_ASTRO = HABITACAO.PLANETA
                LEFT JOIN COMUNIDADE ON HABITACAO.ESPECIE = COMUNIDADE.ESPECIE
                                    AND HABITACAO.COMUNIDADE = COMUNIDADE.NOME
                                    AND HABITACAO.DATA_FIM IS NULL
                LEFT JOIN PARTICIPA ON PARTICIPA.ESPECIE = COMUNIDADE.ESPECIE
                                AND PARTICIPA.COMUNIDADE = COMUNIDADE.NOME
                GROUP BY
                    PLANETA.ID_ASTRO
                ORDER BY
                    PLANETA.ID_ASTRO;
        
        EXCEPTION
            
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20002, 'Erro:' || SQLERRM);   
        
    END info_planetas;
    
    -- 3 a i.

    /*
        O conceito sobre essa parte é que o comandante teria informações particulares sobre os planetas que sua facção domina, reportando se a facção majoritária
        (faccao que mais comunidades participam) é de fato, ou não, a sua facção.
    */

    PROCEDURE planetas_preocupantes (
        p_cpi_lider LIDER.CPI%TYPE,
        cur OUT SYS_REFCURSOR) AS
    
    BEGIN
        OPEN cur FOR
            SELECT A.FACCAO, A.PLANETA, B.FACCAO_MAJORITARIA
            -- faccões e planetas da nação do comandante
            FROM
                (SELECT F.NOME AS FACCAO, D.PLANETA AS PLANETA
                    FROM FACCAO F 
                    JOIN NACAO_FACCAO NF ON F.NOME = NF.FACCAO
                    JOIN DOMINANCIA D ON NF.NACAO = D.NACAO
                    WHERE F.LIDER = p_cpi_lider) A
            JOIN 
            -- planetas e faccões majorítarias nesses planetas
                (SELECT PLANETA.ID_ASTRO AS PLANETA, STATS_MODE(PARTICIPA.FACCAO) AS FACCAO_MAJORITARIA 
                    FROM PLANETA
                    LEFT JOIN HABITACAO ON PLANETA.ID_ASTRO = HABITACAO.PLANETA AND HABITACAO.DATA_FIM IS NULL
                    LEFT JOIN PARTICIPA ON PARTICIPA.ESPECIE = HABITACAO.ESPECIE AND PARTICIPA.COMUNIDADE = HABITACAO.COMUNIDADE
                    GROUP BY PLANETA.ID_ASTRO) B
            ON A.PLANETA = B.PLANETA;
      
    EXCEPTION
        
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002, 'Erro:' || SQLERRM);   
    
    END planetas_preocupantes;
    
    -- 3 a ii.
    /*
        filtro de distância máxima para achar planetas não errantes não dominados.
    */
    PROCEDURE planetas_potencial_expansao (p_max_dist NUMBER, p_nacao NACAO.NOME%TYPE, cur OUT SYS_REFCURSOR) AS
    
    BEGIN

        OPEN cur FOR
            SELECT 
                planeta, massa, raio, classificacao, min(dist) AS DIST_MINIMA
            FROM
                (SELECT 
                a.planeta, 
                distancia(a.estrela, b.estrela) AS dist
                FROM
                    (SELECT 
                        op.planeta,
                        s.estrela
                    FROM
                        SISTEMA s
                        JOIN ORBITA_PLANETA op ON s.ESTRELA = op.ESTRELA
                        LEFT JOIN DOMINANCIA d ON OP.PLANETA = d.PLANETA
                        WHERE d.PLANETA IS NULL OR d.DATA_FIM IS NOT NULL) a
                CROSS JOIN    
                    (SELECT 
                        DISTINCT S.ESTRELA 
                    FROM
                        SISTEMA S
                        JOIN ORBITA_PLANETA op ON s.ESTRELA = op.ESTRELA
                        JOIN DOMINANCIA d ON op.PLANETA = d.PLANETA
                        WHERE D.NACAO = p_nacao AND D.DATA_FIM IS NULL) b) res
            JOIN planeta p ON p.id_astro = res.planeta
            WHERE dist < p_max_dist
            GROUP BY res.PLANETA, p.massa, p.raio, p.classificacao;
        
    END planetas_potencial_expansao;
    
    -- bonus

    /*
        Essa procedure coleta informações sobre planetas e suas dominância em intervalos de tempo
    */
    PROCEDURE GET_DOMINANCIAS_PERIODO (
            p_start_date IN DATE,
            p_end_date IN DATE,
            p_cursor OUT SYS_REFCURSOR
        )
    IS
    BEGIN
        -- Verificação de validação
        IF p_end_date <= p_start_date THEN
            RAISE_APPLICATION_ERROR(-20001, 'A data de fim deve ser posterior à data de início.');
        END IF;
        
        OPEN p_cursor FOR
            SELECT 
                PLANETA,
                NACAO,
                DATA_INI,
                DATA_FIM
            FROM 
                DOMINANCIA
            WHERE
                (DATA_INI <= p_end_date AND (DATA_FIM IS NULL OR DATA_FIM >= p_start_date))
            ORDER BY
                DATA_INI;
    END GET_DOMINANCIAS_PERIODO;
    
END RELATORIO_COMANDANTE; 


/*
Calcula distancia entre 2 estrelas.
*/
CREATE FUNCTION distancia (
            estrela1 estrela.id_estrela%TYPE,
            estrela2 estrela.id_estrela%TYPE )
        RETURN NUMBER IS
            dist NUMBER;
            TYPE coordenadas IS RECORD (
                X NUMBER,
                Y NUMBER,
                Z NUMBER
            );
            coord_estrela1 coordenadas;
            coord_estrela2 coordenadas;
    BEGIN 
        SELECT X, Y, Z INTO coord_estrela1
            FROM estrela
            WHERE id_estrela = estrela1;
        
        SELECT X, Y, Z INTO coord_estrela2
            FROM estrela
            WHERE id_estrela = estrela2;
        
        dist := SQRT(POWER(coord_estrela1.X - coord_estrela2.X, 2) + POWER(coord_estrela1.Y - coord_estrela2.Y, 2) + POWER(coord_estrela1.Z - coord_estrela2.Z, 2));
            
        RETURN dist;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20061, 'No data found');
END distancia;

    
