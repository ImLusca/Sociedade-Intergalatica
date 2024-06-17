CREATE OR REPLACE PACKAGE relatorio_lider AS

    PROCEDURE comunidades_faccao_planeta(p_faccao faccao.nome%TYPE, out_cursor OUT SYS_REFCURSOR);
    PROCEDURE comunidades_faccao_especie(p_faccao faccao.nome%TYPE, out_cursor OUT SYS_REFCURSOR);
    PROCEDURE comunidades_faccao_sistema(p_faccao faccao.nome%TYPE, out_cursor OUT SYS_REFCURSOR);
    PROCEDURE comunidades_faccao_nacao(p_faccao faccao.nome%TYPE, out_cursor OUT SYS_REFCURSOR);

END relatorio_lider;

/*
    Informações sobre comunidades da própria facção
    Dado uma faccao retorna dados de todas as comunidades que se relacionam em participa com esta faccão
    Foi utilizado diferente procedures uma para cada group by retornando um cursos da tabela para aplicação
*/
CREATE OR REPLACE PACKAGE BODY relatorio_lider AS

    PROCEDURE comunidades_faccao_planeta(p_faccao faccao.nome%TYPE, out_cursor OUT SYS_REFCURSOR) IS
        BEGIN
            OPEN out_cursor FOR
                SELECT H.planeta, COUNT(DISTINCT C.NOME || C.ESPECIE), SUM(C.QTD_HABITANTES)
                FROM PARTICIPA P
                left join COMUNIDADE C on C.ESPECIE = P.ESPECIE and C.NOME = P.COMUNIDADE
                left join HABITACAO H on C.ESPECIE = H.ESPECIE and C.NOME = H.COMUNIDADE
                WHERE H.DATA_FIM IS NULL AND P.faccao = p_faccao
                GROUP BY H.planeta;
    END comunidades_faccao_planeta;

    PROCEDURE comunidades_faccao_especie(p_faccao faccao.nome%TYPE, out_cursor OUT SYS_REFCURSOR) IS
        BEGIN
            OPEN out_cursor FOR
                SELECT C.especie AS ESPECIE, COUNT(DISTINCT C.NOME) AS NUM_COMUNIDADES, SUM(C.QTD_HABITANTES) AS NUM_HABITANTES
                FROM PARTICIPA P
                left join COMUNIDADE C on C.ESPECIE = P.ESPECIE and C.NOME = P.COMUNIDADE
                left join HABITACAO H on C.ESPECIE = H.ESPECIE and C.NOME = H.COMUNIDADE
                WHERE H.DATA_FIM IS NULL AND P.faccao = p_faccao
                GROUP BY C.especie;
    END comunidades_faccao_especie;

    PROCEDURE comunidades_faccao_sistema(p_faccao faccao.nome%TYPE, out_cursor OUT SYS_REFCURSOR) IS
        BEGIN
            OPEN out_cursor FOR
                SELECT S.estrela AS SISTEMA, COUNT(DISTINCT C.NOME) AS NUM_COMUNIDADES, SUM(C.QTD_HABITANTES) AS NUM_HABITANTES
                FROM PARTICIPA P
                left join COMUNIDADE C on C.ESPECIE = P.ESPECIE and C.NOME = P.COMUNIDADE
                left join HABITACAO H on C.ESPECIE = H.ESPECIE and C.NOME = H.COMUNIDADE    
                LEFT JOIN ORBITA_PLANETA OP on H.planeta = OP.PLANETA
                LEFT JOIN SISTEMA S on OP.PLANETA= S.ESTRELA
                WHERE H.DATA_FIM IS NULL AND P.faccao = p_faccao
                GROUP BY S.estrela;
    END comunidades_faccao_sistema;

    PROCEDURE comunidades_faccao_nacao(p_faccao faccao.nome%TYPE, out_cursor OUT SYS_REFCURSOR) IS
        BEGIN
            OPEN out_cursor FOR
                SELECT D.NACAO AS NACAO, COUNT(DISTINCT C.NOME) AS NUM_COMUNIDADES, SUM(C.QTD_HABITANTES) AS NUM_HABITANTES
                FROM PARTICIPA P
                left join COMUNIDADE C on C.ESPECIE = P.ESPECIE and C.NOME = P.COMUNIDADE
                left join HABITACAO H on C.ESPECIE = H.ESPECIE and C.NOME = H.COMUNIDADE    
                LEFT JOIN DOMINANCIA D on H.PLANETA = D.PLANETA
                WHERE H.DATA_FIM IS NULL AND P.faccao = p_faccao
                GROUP BY D.NACAO;
    END comunidades_faccao_nacao;

END relatorio_lider;
