CREATE OR REPLACE PROCEDURE LIDER_RELATORIO(
    lider_cpi IN CHAR,
    p_group_by IN VARCHAR2,
    cur OUT SYS_REFCURSOR
) IS
    v_sql VARCHAR2(4000);
BEGIN
    IF p_group_by = 'NACAO' THEN
        v_sql := 
        'SELECT
            d.nacao AS nacao,
            EXTRACT(YEAR FROM h.data_ini) AS ano,
            SUM(c.qtd_habitantes) AS populacao
        FROM 
            lider l 
            JOIN dominancia d ON d.nacao = l.nacao
            JOIN habitacao h ON d.planeta = h.planeta
            JOIN comunidade c ON c.especie = h.especie AND c.nome = h.comunidade
            JOIN ORBITA_PLANETA op ON op.PLANETA = h.PLANETA
            JOIN SISTEMA s ON s.ESTRELA = op.ESTRELA
        WHERE
            l.cpi = ''' || lider_cpi || '''
            AND h.data_ini IS NOT NULL
        GROUP BY
            d.nacao,
            EXTRACT(YEAR FROM h.data_ini)
        
        UNION ALL
        
        SELECT
            d.nacao AS nacao,
            EXTRACT(YEAR FROM h.data_fim) AS ano,
            -SUM(c.qtd_habitantes) AS populacao
        FROM 
            lider l 
            JOIN dominancia d ON d.nacao = l.nacao
            JOIN habitacao h ON d.planeta = h.planeta
            JOIN comunidade c ON c.especie = h.especie AND c.nome = h.comunidade
            JOIN ORBITA_PLANETA op ON op.PLANETA = h.PLANETA
            JOIN SISTEMA s ON s.ESTRELA = op.ESTRELA
        WHERE
            l.cpi = ''' || lider_cpi || '''
            AND h.data_fim IS NOT NULL
        GROUP BY
            d.nacao,
            EXTRACT(YEAR FROM h.data_fim)
        )
        GROUP BY
            nacao,
            ano
        ORDER BY
            nacao,
            ano';

    ELSIF p_group_by = 'ESPECIE' THEN
        v_sql := 
        'SELECT
            c.especie AS especie,
            EXTRACT(YEAR FROM h.data_ini) AS ano,
            SUM(c.qtd_habitantes) AS populacao
        FROM 
            lider l 
            JOIN dominancia d ON d.nacao = l.nacao
            JOIN habitacao h ON d.planeta = h.planeta
            JOIN comunidade c ON c.especie = h.especie AND c.nome = h.comunidade
            JOIN ORBITA_PLANETA op ON op.PLANETA = h.PLANETA
            JOIN SISTEMA s ON s.ESTRELA = op.ESTRELA
        WHERE
            l.cpi = ''' || lider_cpi || '''
            AND h.data_ini IS NOT NULL
        GROUP BY
            c.especie,
            EXTRACT(YEAR FROM h.data_ini)
        
        UNION ALL
        
        SELECT
            c.especie AS especie,
            EXTRACT(YEAR FROM h.data_fim) AS ano,
            -SUM(c.qtd_habitantes) AS populacao
        FROM 
            lider l 
            JOIN dominancia d ON d.nacao = l.nacao
            JOIN habitacao h ON d.planeta = h.planeta
            JOIN comunidade c ON c.especie = h.especie AND c.nome = h.comunidade
            JOIN ORBITA_PLANETA op ON op.PLANETA = h.PLANETA
            JOIN SISTEMA s ON s.ESTRELA = op.ESTRELA
        WHERE
            l.cpi = ''' || lider_cpi || '''
            AND h.data_fim IS NOT NULL
        GROUP BY
            c.especie,
            EXTRACT(YEAR FROM h.data_fim)
        )
        GROUP BY
            especie,
            ano
        ORDER BY
            especie,
            ano';

    ELSIF p_group_by = 'PLANETA' THEN
        v_sql := 
        'SELECT
            h.planeta AS planeta,
            EXTRACT(YEAR FROM h.data_ini) AS ano,
            SUM(c.qtd_habitantes) AS populacao
        FROM 
            lider l 
            JOIN dominancia d ON d.nacao = l.nacao
            JOIN habitacao h ON d.planeta = h.planeta
            JOIN comunidade c ON c.especie = h.especie AND c.nome = h.comunidade
            JOIN ORBITA_PLANETA op ON op.PLANETA = h.PLANETA
            JOIN SISTEMA s ON s.ESTRELA = op.ESTRELA
        WHERE
            l.cpi = ''' || lider_cpi || '''
            AND h.data_ini IS NOT NULL
        GROUP BY
            h.planeta,
            EXTRACT(YEAR FROM h.data_ini)
        
        UNION ALL
        
        SELECT
            h.planeta AS planeta,
            EXTRACT(YEAR FROM h.data_fim) AS ano,
            -SUM(c.qtd_habitantes) AS populacao
        FROM 
            lider l 
            JOIN dominancia d ON d.nacao = l.nacao
            JOIN habitacao h ON d.planeta = h.planeta
            JOIN comunidade c ON c.especie = h.especie AND c.nome = h.comunidade
            JOIN ORBITA_PLANETA op ON op.PLANETA = h.PLANETA
            JOIN SISTEMA s ON s.ESTRELA = op.ESTRELA
        WHERE
            l.cpi = ''' || lider_cpi || '''
            AND h.data_fim IS NOT NULL
        GROUP BY
            h.planeta,
            EXTRACT(YEAR FROM h.data_fim)
        )
        GROUP BY
            planeta,
            ano
        ORDER BY
            planeta,
            ano';

    ELSIF p_group_by = 'SISTEMA' THEN
        v_sql := 
        'SELECT
            s.nome AS sistema,
            EXTRACT(YEAR FROM h.data_ini) AS ano,
            SUM(c.qtd_habitantes) AS populacao
        FROM 
            lider l 
            JOIN dominancia d ON d.nacao = l.nacao
            JOIN habitacao h ON d.planeta = h.planeta
            JOIN comunidade c ON c.especie = h.especie AND c.nome = h.comunidade
            JOIN ORBITA_PLANETA op ON op.PLANETA = h.PLANETA
            JOIN SISTEMA s ON s.ESTRELA = op.ESTRELA
        WHERE
            l.cpi = ''' || lider_cpi || '''
            AND h.data_ini IS NOT NULL
        GROUP BY
            s.nome,
            EXTRACT(YEAR FROM h.data_ini)
        
        UNION ALL
        
        SELECT
            s.nome AS sistema,
            EXTRACT(YEAR FROM h.data_fim) AS ano,
            -SUM(c.qtd_habitantes) AS populacao
        FROM 
            lider l 
            JOIN dominancia d ON d.nacao = l.nacao
            JOIN habitacao h ON d.planeta = h.planeta
            JOIN comunidade c ON c.especie = h.especie AND c.nome = h.comunidade
            JOIN ORBITA_PLANETA op ON op.PLANETA = h.PLANETA
            JOIN SISTEMA s ON s.ESTRELA = op.ESTRELA
        WHERE
            l.cpi = ''' || lider_cpi || '''
            AND h.data_fim IS NOT NULL
        GROUP BY
            s.nome,
            EXTRACT(YEAR FROM h.data_fim)
        )
        GROUP BY
            sistema,
            ano
        ORDER BY
            sistema,
            ano';

    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Invalid group by parameter');
    END IF;

    OPEN cur FOR v_sql;
END LIDER_RELATORIO;
/
