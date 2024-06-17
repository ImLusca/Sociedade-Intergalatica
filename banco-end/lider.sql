-- i
CREATE OR REPLACE PROCEDURE update_faccao_nome (
    old_nome IN VARCHAR2,
    new_nome IN VARCHAR2
) IS
    TYPE t_nacao_faccao IS TABLE OF NACAO_FACCAO%ROWTYPE;
    TYPE t_participa IS TABLE OF PARTICIPA%ROWTYPE;

    l_nacao_faccao t_nacao_faccao;
    l_participa t_participa;

BEGIN
    -- Inicia transacao
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

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

-- ii
-- PRECISA ALTERAR PROCEDURE DE ALTERAR OS USUARIOS
CREATE OR REPLACE PROCEDURE indica_lider (
    novo_lider IN LIDER.CPI%TYPE,
    nome_faccao IN FACCAO.NOME%TYPE
) IS
    old_lider LIDER.CPI%TYPE;

BEGIN

    SELECT LIDER INTO old_lider
    FROM FACCAO
    WHERE nome_faccao = NOME;

    UPDATE FACCAO 
    SET LIDER = novo_lider
    WHERE NOME = nome_faccao;


    commit;

END;

select * from faccao;
select * from nacao_faccao;
select * from participa;
BEGIN
    update_faccao_nome('Faccao1-Updted', 'Faccao1');
END;


CREATE OR REPLACE PROCEDURE indica_lider (
    novo_lider IN LIDER.CPI%TYPE,
    nome_faccao IN FACCAO.NOME%TYPE
) IS
    old_lider LIDER.CPI%TYPE;

    e_unique_violation EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_unique_violation, -00001);

BEGIN
    BEGIN
        -- Pega nome do antigo lider
        SELECT LIDER INTO old_lider
        FROM FACCAO
        WHERE NOME = nome_faccao;

        UPDATE FACCAO 
        SET LIDER = novo_lider
        WHERE NOME = nome_faccao;

        -- INSERE NOVO USUARIO
        -- RETIRA ANTIGO USUARIO
        COMMIT;

    EXCEPTION
        WHEN e_unique_violation THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erro: O CPI utilizado já é lider em outra faccao.');

        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: Faccao não existe.');

        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Algum erro aconteceu: ' || SQLERRM);
    END;
END;



select * from lider;
select * from faccao;

select LIDER.CPI, FACCAO.NOME from LIDER LEFT JOIN FACCAO ON FACCAO.LIDER = LIDER.CPI;


BEGIN
    indica_lider('111.111.111-11', 'Facc11');
END;


-- iii
--View do Gerenciamento das comunidades

-- iii
--View do Gerenciamento das comunidades
CREATE OR REPLACE PROCEDURE GET_COMUNIDADES_HABITANDO_PLANETA (
    p_cpi_lider IN CHAR
)
IS
BEGIN
    -- Cursor para buscar todas as comunidades que habitam um planeta dominado por uma das nações da facção do líder
    FOR rec IN (
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
            f.LIDER = p_cpi_lider
    ) LOOP
        -- Saída das comunidades
        DBMS_OUTPUT.PUT_LINE('Espécie: ' || rec.ESPECIE || ', Comunidade: ' || rec.NOME);
    END LOOP;
END;


CREATE OR REPLACE PROCEDURE INSERE_PARTICIPA (
    p_especie     IN VARCHAR2,
    p_comunidade  IN VARCHAR2,
    p_faccao      IN VARCHAR2
)
IS
BEGIN
    -- Inserir a nova tupla na tabela PARTICIPA
    INSERT INTO PARTICIPA (ESPECIE, COMUNIDADE, FACCAO)
    VALUES (p_especie, p_comunidade, p_faccao);
    
    -- Mensagem de sucesso (opcional)
    DBMS_OUTPUT.PUT_LINE('Inserção realizada com sucesso: ' ||
                         'Espécie = ' || p_especie || ', Comunidade = ' || p_comunidade || ', Facção = ' || p_faccao);
EXCEPTION
    WHEN OTHERS THEN
        -- Captura qualquer erro e levanta uma exceção com uma mensagem customizada
        RAISE_APPLICATION_ERROR(-20001, 'Erro ao inserir a tupla em PARTICIPA: ' || SQLERRM);
END;


-- 1b
CREATE OR REPLACE PROCEDURE remove_faccao_nacao (
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

commit;

select * from nacao_faccao;

-- Teste
DECLARE
    -- Variáveis para armazenar os parâmetros
    p_lider faccao.lider%TYPE := '123.456.782-34';
    p_nacao nacao.nome%TYPE := 'NacaoA';
BEGIN
    -- Chamar a procedure para remover a nação da facção
    remove_faccao_nacao(p_lider, p_nacao);
    
    -- Verificar se a nação foi removida corretamente
    IF SQL%ROWCOUNT > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Relação nação-facção removida com sucesso.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nenhuma relação nação-facção foi removida.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
END;

select * from nacao_faccao;

rollback;





-- Relatorio Lider
CREATE OR REPLACE PROCEDURE LIDER_RELATORIO(
    lider_cpi IN CHAR,
    p_group_by IN VARCHAR2,
    cur OUT SYS_REFCURSOR
)
IS
    v_sql VARCHAR2(4000);
BEGIN
    IF p_group_by = 'NACAO' OR p_group_by = 'ESPECIE' THEN
        v_sql := '
        SELECT  
            d.nacao AS nacao,
            c.especie AS especie,
            c.nome AS comunidade,
            s.nome AS sistema,
            c.qtd_habitantes AS habitantes
        FROM faccao f
        JOIN participa p ON f.nome = p.faccao
        JOIN comunidade c ON p.especie = c.especie AND p.comunidade = c.nome
        LEFT JOIN especie e ON e.nome = c.ESPECIE
        LEFT JOIN habitacao h ON h.especie = c.especie AND h.comunidade = c.nome
        LEFT JOIN dominancia d ON d.planeta = h.planeta
        LEFT JOIN ORBITA_PLANETA op ON op.PLANETA = h.PLANETA
        LEFT JOIN SISTEMA s ON s.ESTRELA = op.ESTRELA
        WHERE f.lider = ''' || lider_cpi || '''
        ORDER BY ' || p_group_by;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Invalid group_by parameter. Use ''NACAO'' or ''ESPECIE''.');
    END IF;
    OPEN cur FOR v_sql;
END;


--Testando
DECLARE
    v_result_cursor SYS_REFCURSOR;
    v_nacao VARCHAR2(100);
    v_especie VARCHAR2(100);
    v_comunidade VARCHAR2(100);
    v_sistema VARCHAR2(100);
    v_habitantes NUMBER;
BEGIN
    -- Call the procedure with the leader ID and order by column
    LIDER_RELATORIO('123.456.782-34', 'NACAO', v_result_cursor);

    -- Fetch and display the results
    LOOP
        FETCH v_result_cursor INTO v_nacao, v_especie, v_comunidade, v_sistema, v_habitantes;
        EXIT WHEN v_result_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Nacao: ' || v_nacao || ', Especie: ' || v_especie || 
                             ', Comunidade: ' || v_comunidade || ', Sistema: ' || v_sistema || 
                             ', Habitantes: ' || v_habitantes);
    END LOOP;

    -- Close the cursor
    CLOSE v_result_cursor;
END;
