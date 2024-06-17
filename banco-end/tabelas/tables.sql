-- Tabela com informações para cada usuário do banco
CREATE TABLE app_users (
    userID NUMBER,
    password VARCHAR2(40),
    IdLider CHAR(14),
    CONSTRAINT PK_USERS_TABLE PRIMARY KEY (userID),
    CONSTRAINT FK_USERS_LIDER FOREIGN KEY (IdLider) REFERENCES LIDER(CPI) ON DELETE CASCADE,
    CONSTRAINT CK_USERS_TABLE_CPI CHECK (REGEXP_LIKE(IdLider, '^\d{3}\.\d{3}\.\d{3}-\d{2}$')),
    CONSTRAINT UN_USERS_CPI UNIQUE (IdLider)    
);

CREATE SEQUENCE app_users_seq;

-- Tabela de log das ações de cada usuário
CREATE TABLE log_table (
    userID NUMBER,
    log_time TIMESTAMP,
    message VARCHAR2(50),
    CONSTRAINT PK_LOG_TABLE PRIMARY KEY (userID),
    CONSTRAINT FK_USERS_LIDER FOREIGN KEY (userID) REFERENCES APP_USERS(userID)
);
