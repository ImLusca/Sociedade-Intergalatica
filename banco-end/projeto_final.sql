CREATE TABLE app_users (
    synthetic_id NUMBER,
    password VARCHAR2(40),
    IdLider CHAR(14),
    salt VARCHAR2(40),
    CONSTRAINT PK_USERS_TAB?E PRIMARY KEY (synthetic_id),
    CONSTRAINT FK_USERS_LIDER FOREIGN KEY (IdLider) REFERENCES LIDER(CPI),
  	CONSTRAINT CK_USERS_TABLE_CPI CHECK (REGEXP_LIKE(IdLider, '^\d{3}\.\d{3}\.\d{3}-\d{2}$')),
    CONSTRAINT UN_USERS_CPI UNIQUE (IdLider)    
);

CREATE SEQUENCE app_users_seq;

CREATE OR REPLACE PACKAGE app_user_security AS

    FUNCTION get_hash (p_password  IN  VARCHAR2,
                       p_salt  IN  VARCHAR2)
        RETURN VARCHAR2;
    
    PROCEDURE add_user (p_username  IN  VARCHAR2,
                      p_password  IN  VARCHAR2);

    PROCEDURE change_password (p_username      IN  VARCHAR2,
                             p_old_password  IN  VARCHAR2,
                             p_new_password  IN  VARCHAR2);

    PROCEDURE valid_user (p_username  IN  VARCHAR2,
                        p_password  IN  VARCHAR2);

    FUNCTION valid_user (p_username  IN  VARCHAR2,
                       p_password  IN  VARCHAR2)
        RETURN BOOLEAN;

END;

CREATE OR REPLACE PACKAGE BODY app_user_security AS

    FUNCTION get_hash (p_password  IN  VARCHAR2,
                       l_salt IN VARCHAR2)
        RETURN VARCHAR2 AS
  
    BEGIN
        RETURN DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(l_salt || UPPER(p_password)),DBMS_CRYPTO.HASH_SH1);
    END;

    PROCEDURE add_user (p_username  IN  VARCHAR2,
                      p_password  IN  VARCHAR2) AS
                      
        l_raw RAW(20);
        l_salt VARCHAR2(40);

    BEGIN
    
        l_raw := DBMS_CRYPTO.RANDOMBYTES(20);
        l_salt := RAWTOHEX(l_raw);
        
        INSERT INTO app_users (
            synthetic_id,
            password,
            CPI
        )
        VALUES (
            app_users_seq.NEXTVAL,
            get_hash(p_username, l_salt, p_password),
            UPPER(p_username),
            l_salt
        );
    
        COMMIT;
    END;
   
    PROCEDURE change_password (p_username      IN  VARCHAR2,
                             p_salt IN  VARCHAR2,
                             p_old_password  IN  VARCHAR2,
                             p_new_password  IN  VARCHAR2) AS
        v_rowid  ROWID;
        l_raw RAW(20);
        l_salt VARCHAR2(40);
    
    BEGIN
    
        SELECT rowid INTO v_rowid FROM app_users    
        WHERE username = UPPER(p_username) AND password = get_hash(p_username, p_salt, p_old_password)
        FOR UPDATE;
        
        l_raw := DBMS_CRYPTO.RANDOMBYTES(20);
        l_salt := RAWTOHEX(l_raw);
        
        UPDATE app_users SET password = get_hash(p_username, l_salt, p_new_password), salt = l_salt WHERE rowid = v_rowid;
    
        COMMIT;
            EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20000, 'Invalid username/password.');
    END;

    PROCEDURE valid_user (p_username  IN  VARCHAR2,
                        p_salt IN  VARCHAR2,
                        p_password  IN  VARCHAR2) AS
        v_dummy  VARCHAR2(1);
    BEGIN
        SELECT '1' INTO v_dummy FROM app_users
        WHERE username = UPPER(p_username) AND password = get_hash(p_username, p_salt, p_password);
  
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20000, 'Invalid username/password.');
    END;
  
    FUNCTION valid_user (p_username  IN  VARCHAR2,
                       p_password  IN  VARCHAR2) 
        RETURN BOOLEAN AS
  
    BEGIN
        valid_user(p_username, p_password);
        RETURN TRUE;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END;
  
END;

PROCEDURE insert_liders_into_users AS
    TYPE lider IS RECORD (
        cpi lider.cpi%TYPE
    );

    TYPE t_lider IS TABLE OF lider;
    info_lider t_lider;

    BEGIN 
        SELECT L.cpi BULK COLLECT INTO info_lider FROM lider L
        LEFT JOIN app_users A ON A.cpi = L.cpi
        WHERE A.cpi IS NULL;
        
        FORALL i IN info_lider.FIRST .. info_lider.LAST  
            app_user_security.add_user(i, 'a' || i);
        
    EXCEPTION
    
END;
    
/*

    COMANDANTE

*/

-- 3. A) i.

CREATE OR REPLACE PROCEDURE criar_federacao (
    p_nome_federacao VARCHAR2,
    p_data_fund DATE
) IS
BEGIN
    INSERT INTO FEDERACAO (NOME, DATA_FUND) 
    VALUES (p_nome_federacao, p_data_fund);
END;

CREATE OR REPLACE PROCEDURE criar_federacao_com_nacao (
    p_nome_federacao VARCHAR2,
    p_data_fund DATE,
    p_nome_nacao VARCHAR2,
    p_qtd_planetas NUMBER
) IS
    federacao_existente EXCEPTION;
    nacao_existente EXCEPTION;

    v_count INTEGER;
BEGIN
    -- Verificar se a federação já existe
    SELECT COUNT(*)
    INTO v_count
    FROM FEDERACAO
    WHERE NOME = p_nome_federacao;

    IF v_count > 0 THEN
        RAISE federacao_existente;
    END IF;

    -- Criar a federação
    criar_federacao(p_nome_federacao, p_data_fund);

EXCEPTION
    WHEN federacao_existente THEN
        RAISE_APPLICATION_ERROR(-20001, 'Federação Já Existe');

    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Erro ');
END;
        
        
        
        
        
        