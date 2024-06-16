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
CREATE OR REPLACE VIEW VW_CREDENCIAMENTO_COMUNIDADES AS
SELECT 
    f.nome AS faccao,
    f.lider As Lider,
    n.nome AS nacao,
    d.planeta AS planeta,
    h.especie As especie,
    c.nome AS comunidade,
    CASE 
        WHEN pa.faccao IS NOT NULL THEN 'CREDENCIADA'
        ELSE 'NAO CREDENCIADA'
    END AS status_credenciamento
FROM 
    faccao f
JOIN 
    nacao_faccao nf ON f.nome = nf.faccao
JOIN 
    nacao n ON nf.nacao = n.nome
JOIN 
    dominancia d ON n.nome = d.nacao AND d.data_fim IS NULL
JOIN 
    habitacao h ON d.planeta = h.planeta AND h.data_fim IS NULL
JOIN 
    comunidade c ON h.especie = c.especie AND h.comunidade = c.nome
LEFT JOIN 
    participa pa ON pa.faccao = f.nome AND pa.especie = c.especie AND pa.comunidade = c.nome;


select * from VW_CREDENCIAMENTO_COMUNIDADES;
select * from VW_CREDENCIAMENTO_COMUNIDADES where lider='123.456.789-10';


CREATE OR REPLACE TRIGGER trg_instead_of_insert_vw_credenciamento
INSTEAD OF INSERT ON VW_CREDENCIAMENTO_COMUNIDADES
FOR EACH ROW
DECLARE
    v_exists INTEGER;
    v_faccao_exists INTEGER;
    v_nacao_exists INTEGER;
    v_dominancia_active INTEGER;
    v_habitacao_active INTEGER;
    v_comunidade_exists INTEGER;
BEGIN
    -- Verifica se a facção existe
    SELECT COUNT(*)
    INTO v_faccao_exists
    FROM faccao
    WHERE nome = :new.faccao;

    IF v_faccao_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'A facção não existe.');
    END IF;

    -- Verifica se a nação existe
    SELECT COUNT(*)
    INTO v_nacao_exists
    FROM nacao
    WHERE nome = :new.nacao;

    IF v_nacao_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'A nação não existe.');
    END IF;

    -- Verifica se há dominância ativa para a nação no planeta
    SELECT COUNT(*)
    INTO v_dominancia_active
    FROM dominancia
    WHERE nacao = :new.nacao
      AND planeta = :new.planeta
      AND data_fim IS NULL;

    IF v_dominancia_active = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Não há dominância ativa para a nação no planeta.');
    END IF;

    -- Verifica se há habitação ativa para a espécie no planeta
    SELECT COUNT(*)
    INTO v_habitacao_active
    FROM habitacao
    WHERE planeta = :new.planeta
      AND especie = :new.especie
      AND data_fim IS NULL;

    IF v_habitacao_active = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Não há habitação ativa para a espécie no planeta.');
    END IF;

    -- Verifica se a comunidade da espécie existe
    SELECT COUNT(*)
    INTO v_comunidade_exists
    FROM comunidade
    WHERE especie = :new.especie
      AND nome = :new.comunidade;

    IF v_comunidade_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'A comunidade da espécie não existe.');
    END IF;

    -- Verifica se a comunidade já está credenciada
    SELECT COUNT(*)
    INTO v_exists
    FROM participa
    WHERE faccao = :new.faccao
      AND especie = :new.especie
      AND comunidade = :new.comunidade;

    IF v_exists = 0 THEN
        -- Insere o credenciamento na tabela PARTICIPA
        INSERT INTO participa (faccao, especie, comunidade)
        VALUES (:new.faccao, :new.especie, :new.comunidade);
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'A comunidade já está credenciada.');
    END IF;
END;

--Inserts validos
INSERT INTO VW_CREDENCIAMENTO_COMUNIDADES (faccao, lider, nacao, planeta, especie, comunidade, status_credenciamento)
VALUES ('Facção A', '123.456.789-10', 'Nação 2', 'Planeta 2', 'Especie 3', 'Comunidade 3', 'CREDENCIADA');

INSERT INTO VW_CREDENCIAMENTO_COMUNIDADES (faccao, lider, nacao, planeta, especie, comunidade)
VALUES ('Facção A', '123.456.789-10', 'Nação 1', 'Planeta 1', 'Especie 2', 'Comunidade 2');

--inserts invalidos
INSERT INTO VW_CREDENCIAMENTO_COMUNIDADES (faccao, lider, nacao, planeta, especie, comunidade)
VALUES ('Facção X', '123.456.789-10', 'Nação 2', 'Planeta 2', 'Especie 3', 'Comunidade 3');

INSERT INTO VW_CREDENCIAMENTO_COMUNIDADES (faccao, lider, nacao, planeta, especie, comunidade)
VALUES ('Facção A', '123.456.789-10', 'Nação X', 'Planeta 2', 'Especie 3', 'Comunidade 3');

INSERT INTO VW_CREDENCIAMENTO_COMUNIDADES (faccao, lider, nacao, planeta, especie, comunidade)
VALUES ('Facção A', '123.456.789-10', 'Nação 1', 'Planeta 2', 'Especie 1', 'Comunidade 1');

INSERT INTO VW_CREDENCIAMENTO_COMUNIDADES (faccao, lider, nacao, planeta, especie, comunidade)
VALUES ('Facção A', '123.456.789-10', 'Nação 2', 'Planeta 2', 'Especie 3', 'Comunidade X');


--Inserts validos
INSERT INTO VW_CREDENCIAMENTO_COMUNIDADES (faccao, lider, nacao, planeta, especie, comunidade, status_credenciamento)
VALUES ('Facção A', '123.456.789-10', 'Nação 2', 'Planeta 2', 'Especie 3', 'Comunidade 3', 'CREDENCIADA');

INSERT INTO VW_CREDENCIAMENTO_COMUNIDADES (faccao, lider, nacao, planeta, especie, comunidade)
VALUES ('Facção A', '123.456.789-10', 'Nação 1', 'Planeta 1', 'Especie 2', 'Comunidade 2');

--inserts invalidos
INSERT INTO VW_CREDENCIAMENTO_COMUNIDADES (faccao, lider, nacao, planeta, especie, comunidade)
VALUES ('Facção X', '123.456.789-10', 'Nação 2', 'Planeta 2', 'Especie 3', 'Comunidade 3');

INSERT INTO VW_CREDENCIAMENTO_COMUNIDADES (faccao, lider, nacao, planeta, especie, comunidade)
VALUES ('Facção A', '123.456.789-10', 'Nação X', 'Planeta 2', 'Especie 3', 'Comunidade 3');

INSERT INTO VW_CREDENCIAMENTO_COMUNIDADES (faccao, lider, nacao, planeta, especie, comunidade)
VALUES ('Facção A', '123.456.789-10', 'Nação 1', 'Planeta 2', 'Especie 1', 'Comunidade 1');

INSERT INTO VW_CREDENCIAMENTO_COMUNIDADES (faccao, lider, nacao, planeta, especie, comunidade)
VALUES ('Facção A', '123.456.789-10', 'Nação 2', 'Planeta 2', 'Especie 3', 'Comunidade X');




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