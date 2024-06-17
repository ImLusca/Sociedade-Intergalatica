CREATE OR REPLACE PACKAGE gerenciamento_lider AS 
    
    PROCEDURE update_faccao_nome (
        old_nome IN VARCHAR2,
        new_nome IN VARCHAR2
    );

    PROCEDURE indica_lider (
        novo_lider IN LIDER.CPI%TYPE,
        nome_faccao IN FACCAO.NOME%TYPE
    );

    PROCEDURE GET_COMUNIDADES_HABITANDO_PLANETA (
        p_cpi_lider IN CHAR
    );

    PROCEDURE INSERE_PARTICIPA (
        p_especie     IN VARCHAR2,
        p_comunidade  IN VARCHAR2,
        p_faccao      IN VARCHAR2
    );

    PROCEDURE remove_faccao_nacao (
        p_lider faccao.lider%TYPE,
        p_nacao nacao.nome%TYPE
    );

END gerenciamento_lider;

CREATE OR REPLACE PACKAGE gerenciamento_lider AS 
    
    PROCEDURE update_faccao_nome (
        old_nome IN VARCHAR2,
        new_nome IN VARCHAR2
    );

    PROCEDURE indica_lider (
        novo_lider IN LIDER.CPI%TYPE,
        nome_faccao IN FACCAO.NOME%TYPE
    );
    
    PROCEDURE GET_COMUNIDADES_HABITANDO_PLANETA (
        p_cpi_lider IN CHAR,
        cur OUT SYS_REFCURSOR
    );

    PROCEDURE INSERE_PARTICIPA (
        p_especie     IN VARCHAR2,
        p_comunidade  IN VARCHAR2,
        p_faccao      IN VARCHAR2
    );

    PROCEDURE remove_faccao_nacao (
        p_lider faccao.lider%TYPE,
        p_nacao nacao.nome%TYPE
    );

END gerenciamento_lider;

CREATE OR REPLACE PACKAGE BODY gerenciamento_lider AS 

    PROCEDURE update_faccao_nome (
        old_nome IN VARCHAR2,
        new_nome IN VARCHAR2
    ) IS
    
        TYPE t_nacao_faccao IS TABLE OF NACAO_FACCAO%ROWTYPE;
        TYPE t_participa IS TABLE OF PARTICIPA%ROWTYPE;

        l_nacao_faccao t_nacao_faccao;
        l_participa t_participa;


    BEGIN
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
        
        BEGIN

            -- Salva Dados de NacaoFaccao e Participa em uma collections
            SELECT NACAO, FACCAO
            BULK COLLECT INTO l_nacao_faccao
            FROM NACAO_FACCAO
            WHERE FACCAO = old_nome;

            SELECT FACCAO, ESPECIE, COMUNIDADE
            BULK COLLECT INTO l_participa
            FROM PARTICIPA
            WHERE FACCAO = old_nome;

            -- Deleta Nacao Faccao
            DELETE FROM NACAO_FACCAO
            WHERE FACCAO = old_nome;

            -- Deleta Faccao
            DELETE FROM PARTICIPA
            WHERE FACCAO = old_nome;

            -- Atualiza faccao
            UPDATE FACCAO
            SET NOME = new_nome
            WHERE NOME = old_nome;

            -- Insere valores atualizados em Nacao Faccao e Participa
            FOR i IN 1..l_nacao_faccao.COUNT LOOP
                INSERT INTO NACAO_FACCAO (NACAO, FACCAO)
                VALUES (l_nacao_faccao(i).NACAO, new_nome);
            END LOOP;

            FOR i IN 1..l_participa.COUNT LOOP
                INSERT INTO PARTICIPA (FACCAO, ESPECIE, COMUNIDADE)
                VALUES (new_nome, l_participa(i).ESPECIE, l_participa(i).COMUNIDADE);
            END LOOP;
            
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE;
        END;
    END update_faccao_nome;

    -- Dado um novo lider e uma faccão altera o lider da faccao com o novo lider
    PROCEDURE indica_lider (
        novo_lider IN LIDER.CPI%TYPE,
        nome_faccao IN FACCAO.NOME%TYPE
    ) IS
        old_lider LIDER.CPI%TYPE;

        e_unique_violation EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_unique_violation, -00001);

    BEGIN
        -- Pega nome do antigo lider
        SELECT LIDER INTO old_lider
        FROM FACCAO
        WHERE NOME = nome_faccao;

        UPDATE FACCAO 
        SET LIDER = novo_lider
        WHERE NOME = nome_faccao;

        COMMIT;

    EXCEPTION
        WHEN e_unique_violation THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20001, 'Erro: O CPI utilizado já é lider em outra faccao.');

        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20002, 'Error: Faccao não existe.');

        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20003, 'Algum erro aconteceu: ' || SQLERRM);
    END;

    -- Retorna uma lista com todas as comunidades que habitam planetas dominados pela faccao do lider
    PROCEDURE GET_COMUNIDADES_HABITANDO_PLANETA (
        p_cpi_lider IN CHAR,
        cur OUT SYS_REFCURSOR
    ) IS

    BEGIN
        -- Cursor para buscar todas as comunidades que habitam um planeta dominado por uma das nações da facção do líder
        OPEN cur FOR 
            SELECT DISTINCT 
                c.ESPECIE, 
                c.NOME 
            FROM 
                FACCAO f
                JOIN NACAO_FACCAO nf ON f.NOME = nf.FACCAO
                JOIN NACAO n ON nf.NACAO = n.NOME
                JOIN DOMINANCIA d ON n.NOME = nf.NACAO
                JOIN HABITACAO h ON d.PLANETA = h.PLANETA
                JOIN COMUNIDADE c ON h.ESPECIE = c.ESPECIE AND h.COMUNIDADE = c.NOME
            WHERE 
                f.LIDER = p_cpi_lider;
        
    END GET_COMUNIDADES_HABITANDO_PLANETA;




    -- Insere uma tupla em participa dado especie, comunidade e faccao
    PROCEDURE INSERE_PARTICIPA (
        p_especie     IN VARCHAR2,
        p_comunidade  IN VARCHAR2,
        p_faccao      IN VARCHAR2
    ) IS

    BEGIN
        -- Inserir a nova tupla na tabela PARTICIPA
        INSERT INTO PARTICIPA (ESPECIE, COMUNIDADE, FACCAO)
        VALUES (p_especie, p_comunidade, p_faccao);
        
    EXCEPTION
        WHEN OTHERS THEN
            -- Captura qualquer erro e levanta uma exceção com uma mensagem customizada
            RAISE_APPLICATION_ERROR(-20001, 'Erro ao inserir a tupla em PARTICIPA: ' || SQLERRM);
    END INSERE_PARTICIPA;

    -- Remove a relação nacao faccao dado o cpi do lider da faccao e a nação
    PROCEDURE remove_faccao_nacao (
        p_lider faccao.lider%TYPE,
        p_nacao nacao.nome%TYPE
    ) AS
        nome_faccao faccao.nome%TYPE;
        e_not_removed EXCEPTION;
    BEGIN
        -- Obter o nome da facção do líder fornecido
        SELECT F.nome INTO nome_faccao FROM faccao F WHERE F.lider = p_lider;
        
        -- Remover a nação da facção correspondente
        DELETE FROM nacao_faccao NF WHERE nome_faccao = NF.faccao AND NF.nacao = p_nacao;
        
        -- Verificar se alguma linha foi afetada
        IF SQL%NOTFOUND THEN
            RAISE e_not_removed;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'Líder não encontrado');
        WHEN e_not_removed THEN
            RAISE_APPLICATION_ERROR(-20002, 'Nenhuma relação nação-facção removida');
    END remove_faccao_nacao;

END gerenciamento_lider;
