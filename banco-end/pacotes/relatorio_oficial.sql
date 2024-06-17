CREATE OR REPLACE PACKAGE relatorio_oficial AS

    PROCEDURE habitantes_por_faccao (p_lider lider.cpi%TYPE, cur OUT SYS_REFCURSOR);
    PROCEDURE habitantes_por_especie (p_lider lider.cpi%TYPE, cur OUT SYS_REFCURSOR);
    PROCEDURE habitantes_por_planeta (p_lider lider.cpi%TYPE, cur OUT SYS_REFCURSOR);
    PROCEDURE habitantes_por_sistema (p_lider lider.cpi%TYPE, cur OUT SYS_REFCURSOR);
    
END relatorio_oficial;

CREATE OR REPLACE PACKAGE BODY relatorio_oficial AS

/*
    Relatório com os dados da evolução populacional dos habitantes de uma nação
    Para cada lider foi buscado sua nação
    assim foi considerado como parte da população todos os habitantes que vivem nos planetas dominados
    pela nação e assim foi buscado todas as habitações nesses planetas e extraido o valor da quantidade
    de habitantes quando relacionado com comunidades.
    Para calcular a evolução populacional foi feita uma tabela que com o nome da faccão, a quantiade de habitantes
    como valor positivo e a data de inicio da habitação, também foi feito o mesmo para outro tabela onde se alterou 
    a quantidade de habitantes para um valor negativo e agora retorna a data de fim.
    Para retirar a somatório por ano, as duas tabelas foram unidas com union all e com 
    gruoup by(ano) e sum(quantiade de habitantes) temos a variação populacional por ano em que houve alteração.
*/
    PROCEDURE habitantes_por_faccao (
        p_lider lider.cpi%TYPE,
        cur OUT SYS_REFCURSOR) IS
        
    BEGIN
        OPEN cur FOR 
            SELECT FACCAO, DATA, SUM(QTD_HABITANTES) OVER (PARTITION BY faccao ORDER BY DATA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS NUM_HABITANTES
                FROM (
                    SELECT F.NOME AS FACCAO, C.QTD_HABITANTES, H.DATA_INI AS DATA
                    
                        FROM LIDER L
                        JOIN DOMINANCIA D ON D.NACAO = L.NACAO
                        JOIN HABITACAO H ON H.PLANETA = D.PLANETA
                        JOIN COMUNIDADE C ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
                        WHERE L.CPI = p_lider
                        
                    UNION ALL
                    SELECT F.NOME AS FACCAO, -C.QTD_HABITANTES, H.DATA_FIM AS DATA
                        FROM LIDER L
                        JOIN DOMINANCIA D ON D.NACAO = L.NACAO
                        JOIN HABITACAO H ON H.PLANETA = D.PLANETA
                        JOIN COMUNIDADE C ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
                        WHERE L.CPI = p_lider AND H.DATA_FIM IS NOT NULL)
                ORDER BY DATA;
    END habitantes_por_faccao;


    --Mesma lógica aplicada em habitantes_por_faccao porém retornando por espécia
    PROCEDURE habitantes_por_especie (
        p_lider lider.cpi%TYPE,
        cur OUT SYS_REFCURSOR) IS
        
    BEGIN
        OPEN cur FOR     
            SELECT ESPECIE, DATA, SUM(QTD_HABITANTES) OVER (PARTITION BY ESPECIE ORDER BY DATA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS NUM_HABITANTES
                FROM (
                    SELECT C.ESPECIE AS ESPECIE, C.QTD_HABITANTES, H.DATA_INI AS DATA
                        FROM LIDER L
                        JOIN DOMINANCIA D ON D.NACAO = L.NACAO
                        JOIN HABITACAO H ON H.PLANETA = D.PLANETA
                        JOIN COMUNIDADE C ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
                        WHERE L.CPI = p_lider
                        
                    UNION ALL
                    SELECT C.ESPECIE AS ESPECIE, -C.QTD_HABITANTES, H.DATA_FIM AS DATA
                        FROM LIDER L
                        JOIN DOMINANCIA D ON D.NACAO = L.NACAO
                        JOIN HABITACAO H ON H.PLANETA = D.PLANETA
                        JOIN COMUNIDADE C ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
                        WHERE L.CPI = p_lider AND H.DATA_FIM IS NOT NULL)
                ORDER BY DATA;
        
    END habitantes_por_especie;

    --Mesma lógica aplicada em habitantes_por_faccao porém retornando por planeta
    PROCEDURE habitantes_por_planeta (
        p_lider lider.cpi%TYPE,
        cur OUT SYS_REFCURSOR) IS
            
    BEGIN
        OPEN cur FOR     
            SELECT PLANETA, DATA, SUM(QTD_HABITANTES) OVER (PARTITION BY PLANETA ORDER BY DATA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS NUM_HABITANTES
                FROM (
                    SELECT H.PLANETA AS PLANETA, C.QTD_HABITANTES, H.DATA_INI AS DATA
                        FROM LIDER L
                        JOIN DOMINANCIA D ON D.NACAO = L.NACAO
                        JOIN HABITACAO H ON H.PLANETA = D.PLANETA
                        JOIN COMUNIDADE C ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
                        WHERE L.CPI = p_lider
                        
                    UNION ALL
                    SELECT H.PLANETA AS PLANETA, -C.QTD_HABITANTES, H.DATA_FIM AS DATA
                        FROM LIDER L
                        JOIN DOMINANCIA D ON D.NACAO = L.NACAO
                        JOIN HABITACAO H ON H.PLANETA = D.PLANETA
                        JOIN COMUNIDADE C ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
                        WHERE L.CPI = p_lider AND H.DATA_FIM IS NOT NULL)
                ORDER BY DATA;
                    
    END habitantes_por_planeta;
    
    PROCEDURE habitantes_por_sistema (
        p_lider lider.cpi%TYPE,
        cur OUT SYS_REFCURSOR) IS
                
    BEGIN
        OPEN cur FOR       
            SELECT SISTEMA, DATA, SUM(QTD_HABITANTES) OVER (PARTITION BY SISTEMA ORDER BY DATA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS NUM_HABITANTES
                FROM (
                    SELECT S.NOME AS SISTEMA, C.QTD_HABITANTES, H.DATA_INI AS DATA
                        FROM LIDER L
                        JOIN DOMINANCIA D ON D.NACAO = L.NACAO
                        JOIN HABITACAO H ON H.PLANETA = D.PLANETA
                        JOIN COMUNIDADE C ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
                        LEFT JOIN ORBITA_PLANETA OP ON OP.PLANETA = H.PLANETA 
                        LEFT JOIN SISTEMA S ON S.ESTRELA = OP.ESTRELA 
                        WHERE L.CPI = p_lider
                        
                    UNION ALL
                    SELECT S.NOME AS SISTEMA, -C.QTD_HABITANTES, H.DATA_FIM AS DATA
                        FROM LIDER L
                        JOIN DOMINANCIA D ON D.NACAO = L.NACAO
                        JOIN HABITACAO H ON H.PLANETA = D.PLANETA
                        JOIN COMUNIDADE C ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
                        LEFT JOIN ORBITA_PLANETA OP ON OP.PLANETA = H.PLANETA 
                        LEFT JOIN SISTEMA S ON S.ESTRELA = OP.ESTRELA 
                        WHERE L.CPI = p_lider AND H.DATA_FIM IS NOT NULL)
                ORDER BY DATA;
                
    END habitantes_por_sistema;
    
END relatorio_oficial;





    
    
