-- Pacote para gerenciamento de criação dos usuários(ID, senha, segurança)
CREATE OR REPLACE PACKAGE app_user_security AS

    FUNCTION get_hash (p_password  IN  VARCHAR2)
        RETURN VARCHAR2;
    
    PROCEDURE add_user (p_username  IN  VARCHAR2,
                      p_password  IN  VARCHAR2);

    PROCEDURE change_password (p_username      IN  VARCHAR2,
                             p_old_password  IN  VARCHAR2,
                             p_new_password  IN  VARCHAR2);

    PROCEDURE valid_user (p_username  IN  VARCHAR2,
                        p_password  IN  VARCHAR2);

    FUNCTION validate_user (p_username  IN  VARCHAR2,
                       p_password  IN  VARCHAR2)
        RETURN BOOLEAN;

END app_user_security;

CREATE OR REPLACE PACKAGE BODY app_user_security AS

    -- Retorna Hash de uma dada senha
    FUNCTION get_hash (p_password  IN  VARCHAR2) RETURN VARCHAR2 AS

        v_hash VARCHAR2(40);

    BEGIN

        SELECT STANDARD_HASH(p_password, 'MD5') INTO v_hash FROM dual;
        RETURN v_hash;  

    END get_hash;

    -- Cria usuário dado username e senha
    PROCEDURE add_user (p_username IN  VARCHAR2,
                      p_password  IN  VARCHAR2) AS
                      
    BEGIN
    
        INSERT INTO app_users (
            userID,
            password,
            IdLider
        )
        VALUES (
            app_users_seq.NEXTVAL,
            get_hash(p_password),
            UPPER(p_username)
        );
    
        COMMIT;
        
    EXCEPTION
    
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20000, 'idLider já registrado');
        
    END add_user;

    -- Alterar senha de usuário
    PROCEDURE change_password (p_username      IN  VARCHAR2,
                             p_old_password  IN  VARCHAR2,
                             p_new_password  IN  VARCHAR2) AS
        v_rowid  ROWID;
    
    BEGIN
    
        SELECT rowid INTO v_rowid FROM app_users    
        WHERE IdLider = UPPER(p_username) AND password = get_hash(p_old_password)
        FOR UPDATE;
        
        UPDATE app_users SET password = get_hash(p_new_password) WHERE rowid = v_rowid;
    
        COMMIT;
        
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20000, 'Invalid username/password.');
                
    END change_password;

    -- Procedure auxiliar de validate_user que checa credenciais do usuário
    PROCEDURE valid_user (p_username  IN  VARCHAR2,
                        p_password  IN  VARCHAR2) AS
                        
        v_dummy  VARCHAR2(1);
        
    BEGIN
        SELECT '1' INTO v_dummy FROM app_users
        WHERE IdLider = UPPER(p_username) AND password = get_hash(p_password);
  
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20000, 'Invalid username/password.');
            
    END valid_user;
    
    -- Valida login do usuário
    FUNCTION validate_user (p_username  IN  VARCHAR2,
                            p_password  IN  VARCHAR2) 
        RETURN BOOLEAN AS
  
    BEGIN
        valid_user(p_username, p_password);
        RETURN TRUE;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END validate_user;
  
END app_user_security;

-- Insere nos logs ações do usuário
CREATE OR REPLACE PROCEDURE log_user_action (
    p_userID IN NUMBER,
    p_message IN VARCHAR2
) AS
BEGIN

    INSERT INTO LOG_TABLE (userID, log_time, message) VALUES (p_userID, SYSTIMESTAMP, p_message);

END log_user_action;



CREATE OR REPLACE PROCEDURE insert_liders_into_users AS
    TYPE t_cpi IS TABLE OF lider.cpi%TYPE;
    info_lider t_cpi;

BEGIN 
    -- Coleta os CPIs que não existem em app_users
    SELECT L.cpi BULK COLLECT INTO info_lider 
    FROM lider L
    LEFT JOIN app_users A ON A.idLider = L.cpi
    WHERE A.idLider IS NULL;
    
    -- Adiciona os novos registros usando FORALL
    IF info_lider.COUNT > 0 THEN
        FORALL i IN INDICES OF info_lider
            INSERT INTO app_users (userID, password, IdLider) VALUES (app_users_seq.NEXTVAL, app_user_security.get_hash('a' || info_lider(i)), UPPER(info_lider(i)));
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Erro:' || SQLERRM); 
        
END insert_liders_into_users;
