--Gerenciamento Cientista (CRUD)

CREATE OR REPLACE PACKAGE gerenciamento_cientista AS
    
    PROCEDURE cria_estrela (
        p_id_estrela estrela.id_estrela%TYPE,
        p_nome estrela.nome%TYPE,
        p_classificacao estrela.classificacao%TYPE,
        p_massa estrela.massa%TYPE,
        p_X estrela.X%TYPE,
        p_Y estrela.Y%TYPE,
        p_Z estrela.Z%TYPE 
    );
        
    PROCEDURE cria_sistema (
        p_id_estrela estrela.id_estrela%TYPE,
        p_sistema_nome sistema.nome%TYPE
    );
    
    PROCEDURE cria_orbita_estrela(
        p_id_orbitante estrela.id_estrela%TYPE,
        p_id_orbitada estrela.id_estrela%TYPE,
        p_dist_min orbita_estrela.dist_min%TYPE,
        p_dist_max orbita_estrela.dist_max%TYPE,
        p_periodo orbita_estrela.periodo%TYPE
    );
    
    PROCEDURE remove_estrela (
        p_id_estrela estrela.id_estrela%TYPE
    );
    
    PROCEDURE atualiza_estrela (
        p_id_estrela estrela.id_estrela%TYPE,
        p_nome estrela.nome%TYPE := NULL,
        p_classificacao estrela.classificacao%TYPE := NULL,
        p_massa estrela.massa%TYPE := NULL,
        p_X estrela.X%TYPE := NULL,
        p_Y estrela.Y%TYPE := NULL,
        p_Z estrela.Z%TYPE := NULL
    );
    
    PROCEDURE read_estrela_id (
        p_id_estrela estrela.id_estrela%TYPE,
        out_cursor OUT SYS_REFCURSOR
    );
    
    PROCEDURE read_estrela_nome (
        p_nome estrela.nome%TYPE,
        out_cursor OUT SYS_REFCURSOR
    );

END gerenciamento_cientista;

CREATE OR REPLACE PACKAGE BODY gerenciamento_cientista AS

    -- Insere estrela e checa se local de criação já existe caso sim retorna erro para aplicação
    PROCEDURE cria_estrela (
            p_id_estrela estrela.id_estrela%TYPE,
            p_nome estrela.nome%TYPE,
            p_classificacao estrela.classificacao%TYPE,
            p_massa estrela.massa%TYPE,
            p_X estrela.X%TYPE,
            p_Y estrela.Y%TYPE,
            p_Z estrela.Z%TYPE ) IS
            
            v_count number;
            e_atributo_not_null EXCEPTION;
            PRAGMA EXCEPTION_INIT(e_atributo_not_null, -01400); 
            
        BEGIN
        
            SELECT COUNT(*) INTO v_count FROM ESTRELA WHERE X = p_x and Y = p_y and Z = p_z;
            IF v_count > 0 THEN
                RAISE e_coor_duplicadas;
            END IF;
            
            INSERT INTO estrela VALUES(p_id_estrela, p_nome, p_classificacao, p_massa, p_X, p_Y, p_Z);
    
            COMMIT;
        
        EXCEPTION
            WHEN e_coor_duplicadas THEN
                    RAISE_APPLICATION_ERROR(-20004, 'Coordenadas duplicadas');
            WHEN e_atributo_not_null THEN
                    RAISE_APPLICATION_ERROR(-20004, 'Atributo deve ser não nulo');
            WHEN DUP_VAL_ON_INDEX THEN
                RAISE_APPLICATION_ERROR(-20004, 'Estrela j? inserida');
                    
    END cria_estrela;
    
    PROCEDURE cria_sistema (
            p_id_estrela estrela.id_estrela%TYPE,
            p_sistema_nome sistema.nome%TYPE ) IS
        
        BEGIN
            INSERT INTO sistema VALUES(p_id_estrela, p_sistema_nome);
            COMMIT;
        
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                RAISE_APPLICATION_ERROR(-20004, 'Estrela j? inserida');
                    
    END cria_sistema;

    PROCEDURE cria_orbita_estrela(
            p_id_orbitante estrela.id_estrela%TYPE,
            p_id_orbitada estrela.id_estrela%TYPE,
            p_dist_min orbita_estrela.dist_min%TYPE,
            p_dist_max orbita_estrela.dist_max%TYPE,
            p_periodo orbita_estrela.periodo%TYPE) IS
        
        e_atributo_not_null EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_atributo_not_null, -01400); 
        
        BEGIN
            INSERT INTO ORBITA_ESTRELA VALUES (p_id_orbitante, p_id_orbitada, p_dist_min, p_dist_max, p_periodo);
            COMMIT;
            
        EXCEPTION
            WHEN e_atributo_not_null THEN
                RAISE_APPLICATION_ERROR(-20004, 'Atributo deve ser não nulo');
            WHEN DUP_VAL_ON_INDEX THEN
                RAISE_APPLICATION_ERROR(-20006, 'Estrela ja existente!');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20000, 'Erro numero: ' || SQLCODE || '. Mensagem: ' || SQLERRM);
                
    END cria_orbita_estrela;

    PROCEDURE remove_estrela (
        p_id_estrela estrela.id_estrela%TYPE) IS
    
        e_not_removed EXCEPTION;
            
        BEGIN
        
            DELETE FROM estrela WHERE id_estrela = p_id_estrela;
            
            IF SQL%NOTFOUND THEN
                RAISE e_not_removed;
            ELSE
                COMMIT;
            END IF;
        
        EXCEPTION
            WHEN e_not_removed THEN
                RAISE_APPLICATION_ERROR(-20007, 'Nenhuma Estrela removida');
               
    END remove_estrela;
    
    PROCEDURE atualiza_estrela (
            p_id_estrela estrela.id_estrela%TYPE,
            p_nome estrela.nome%TYPE := NULL,
            p_classificacao estrela.classificacao%TYPE := NULL,
            p_massa estrela.massa%TYPE := NULL,
            p_X estrela.X%TYPE := NULL,
            p_Y estrela.Y%TYPE := NULL,
            p_Z estrela.Z%TYPE := NULL) IS
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
                RAISE_APPLICATION_ERROR(-20006, 'Nenhuma Estrela encontrada para atualizaï¿½ï¿½o');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20007, 'Erro desconhecido: ' || SQLERRM);
                
    END atualiza_estrela;
    
    PROCEDURE read_estrela_id (
            p_id_estrela estrela.id_estrela%TYPE,
            out_cursor OUT SYS_REFCURSOR) IS

        BEGIN
            OPEN out_cursor FOR 
            SELECT NOME, CLASSIFICACAO, MASSA, X, Y, Z
            FROM estrela
            WHERE id_estrela = p_id_estrela;
            
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20001, 'Estrela nï¿½o encontrada com o ID: ' || p_id_estrela);
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20002, 'Erro desconhecido: ' || SQLERRM);
    END read_estrela_id;
    
    PROCEDURE read_estrela_nome (
        p_nome estrela.nome%TYPE,
        out_cursor OUT SYS_REFCURSOR ) IS
        
        BEGIN
            
            OPEN out_cursor FOR 
            SELECT NOME, CLASSIFICACAO, MASSA, X, Y, Z
            FROM estrela
            WHERE nome = p_nome;
            
        EXCEPTION
        
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20001, 'Estrela nï¿½o encontrada com o nome: ' || p_nome);
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20002, 'Erro desconhecido: ' || SQLERRM);
            
    END read_estrela_nome;
        
END gerenciamento_cientista;
