--A	quantidade	de	na��es,	na	tabela	Faccao dever	estar	sempre	atualizada.	
CREATE OR REPLACE TRIGGER NroDeNacoes
    AFTER INSERT OR DELETE OR UPDATE ON NACAO_FACCAO
    FOR EACH ROW 
    
    BEGIN
    
        IF INSERTING THEN
            UPDATE faccao
            SET QTD_NACOES = QTD_NACOES + 1
            WHERE nome = :new.faccao;
        END IF;
        
        IF DELETING THEN
            UPDATE faccao
            SET QTD_NACOES = QTD_NACOES - 1
            WHERE nome = :old.faccao;
        END IF;
        
        IF UPDATING AND :old.faccao != :new.faccao THEN
            UPDATE faccao
            SET QTD_NACOES = QTD_NACOES - 1
            WHERE nome = :old.faccao;
            
            UPDATE faccao
            SET QTD_NACOES = QTD_NACOES + 1
            WHERE nome = :new.faccao;
        END IF;
    
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.put_line('Erro: ' || SQLERRM);
            
END NroDeNacoes; 

-- Na tabela	Nacao, o atributo qtd_planetas deve considerar somente domin�ncias atuais.
    
CREATE OR REPLACE TRIGGER NrodePlanetasNacao
    AFTER INSERT OR DELETE OR UPDATE OF DATA_FIM ON dominancia
    FOR EACH ROW 
    
    BEGIN
    
        IF INSERTING AND :new.DATA_FIM IS NULL THEN
            UPDATE nacao
            SET qtd_planetas = qtd_planetas + 1
            WHERE nome = :new.nacao;
        END IF;
        
        IF DELETING AND :old.DATA_FIM IS NULL THEN
            UPDATE nacao
            SET qtd_planetas = qtd_planetas - 1
            WHERE nome = :old.nacao;
        END IF;
        
        IF UPDATING AND :new.DATA_FIM IS NULL THEN
            UPDATE nacao
            SET qtd_planetas = qtd_planetas + 1
            WHERE nome = :new.nacao;
        END IF;
        
        IF UPDATING AND :new.DATA_FIM IS NOT NULL THEN
            UPDATE nacao
            SET qtd_planetas = qtd_planetas - 1
            WHERE nome = :new.nacao;
        END IF;
    
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.put_line('Erro: ' || SQLERRM);
            
END NrodePlanetasNacao;

--Somente espécies inteligentes formam comuniades
CREATE OR REPLACE TRIGGER ComunidadeInteligente
BEFORE INSERT OR UPDATE ON Comunidade
FOR EACH ROW
DECLARE
    v_inteligente ESPECIE.Inteligente%type;
BEGIN

    SELECT inteligente INTO v_inteligente
        FROM Especie
        WHERE Nome = :new.especie;

    IF v_inteligente = 'F' THEN
        RAISE_APPLICATION_ERROR(-20700,'Espécies burras não podem formar uma comunidade.');
    END IF;

END ComunidadeInteligente;
