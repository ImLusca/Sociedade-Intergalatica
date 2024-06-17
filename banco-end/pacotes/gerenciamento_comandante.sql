CREATE OR REPLACE PACKAGE GerenciamentoComandante AS
    
    PROCEDURE sair_federacao (p_nome_nacao VARCHAR2);
    PROCEDURE entrar_federacao (p_nome_nacao VARCHAR2, p_federacao VARCHAR2);
    PROCEDURE criar_federacao_com_nacao (p_nome_federacao VARCHAR2, p_nome_nacao VARCHAR2, p_data_fund DATE DEFAULT SYSDATE);
    PROCEDURE dominancia_planeta (p_planeta PLANETA.ID_ASTRO%TYPE, p_nacao NACAO.nome%TYPE, p_data_ini DATE DEFAULT SYSDATE);
    
END;

-- 3. A) i.

CREATE OR REPLACE PACKAGE BODY GerenciamentoComandante AS

    -- Dado uma nação ela retira a relação com a federação
    PROCEDURE sair_federacao (
        p_nome_nacao VARCHAR2
    ) IS
    
        v_federacao FEDERACAO.NOME%TYPE;
        v_count NUMBER;
        
    BEGIN
    
        SELECT federacao INTO v_federacao FROM nacao WHERE nome = p_nome_nacao;
        
        SELECT COUNT(*) INTO v_count FROM Nacao WHERE Federacao = v_federacao;
        
        IF v_count = 1 THEN
            DELETE FROM Federacao WHERE nome = v_federacao;
        END IF;
        
        UPDATE nacao SET federacao = NULL WHERE nome = p_nome_nacao;
        
        COMMIT;
        
    EXCEPTION
        
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20020, 'Essa nação não existe');
        
    END;

    -- Dado uma nação e federação é alterado a federação da nação pela federação inserida
    PROCEDURE entrar_federacao (
        p_nome_nacao VARCHAR2,
        p_federacao VARCHAR2
    ) IS
        
        e_naoEncontrado EXCEPTION;
        v_dummy  VARCHAR2(1);
        
    BEGIN
    
        SELECT '1' INTO v_dummy FROM federacao WHERE nome = p_federacao;
        
        UPDATE nacao SET federacao = p_federacao WHERE nome = p_nome_nacao;
        
         IF SQL%NOTFOUND THEN 
            RAISE e_naoEncontrado; 
        END IF;
        
    EXCEPTION
    
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20000, 'Essa federação não existe');
            
        WHEN e_naoEncontrado THEN
            RAISE_APPLICATION_ERROR(-20021, 'Essa nação não existe');
    END;
    

    -- Cria uma federação e relaciona a nova federação com uma nação
    PROCEDURE criar_federacao_com_nacao (
        p_nome_federacao VARCHAR2,
        p_nome_nacao VARCHAR2,
        p_data_fund DATE DEFAULT SYSDATE
    ) IS
        
        e_naoEncontrado EXCEPTION;
    
    BEGIN
    
        INSERT INTO FEDERACAO (NOME, DATA_FUND) VALUES (p_nome_federacao, p_data_fund);
        UPDATE nacao SET federacao = p_nome_federacao WHERE nome = p_nome_nacao;
        
         IF SQL%NOTFOUND THEN 
            RAISE e_naoEncontrado; 
        END IF;
    
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20031, 'Federação Já Existe');
            
        WHEN e_naoEncontrado THEN
            RAISE_APPLICATION_ERROR(-20031, 'Nação não encontrada');
    
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002, 'Erro:' || SQLERRM);    
    END;

    -- Insere nova dominância de um planeta que não está sendo dominado por ninguém, dado um planeta, nação. Para isso se checa se o planeta está sem dominancia ativa.
    PROCEDURE dominancia_planeta (
        p_planeta PLANETA.ID_ASTRO%TYPE,
        p_nacao NACAO.nome%TYPE,
        p_data_ini DATE DEFAULT SYSDATE
    ) IS
    
    v_count NUMBER;
    e_ja_dominado EXCEPTION;
    
    BEGIN
        
        SELECT count(*) into v_count FROM dominancia WHERE planeta = p_planeta AND data_fim IS NULL;
        
        IF v_count >= 0 THEN
            RAISE e_ja_dominado;
        END IF;
        
        INSERT INTO dominancia VALUES (p_planeta, p_nacao, p_data_ini, NULL);
        
        UPDATE nacao SET qtd_planetas = qtd_planetas + 1 WHERE nome = p_nacao;
        
    EXCEPTION
    
        WHEN NO_DATA_FOUND THEN 
            RAISE_APPLICATION_ERROR(-20041, 'Planeta já dominado');
            
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002, 'Erro:' || SQLERRM);
    END;
END GerenciamentoComandante;
