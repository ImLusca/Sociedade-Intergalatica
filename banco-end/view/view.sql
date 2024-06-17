/*
View utilizada para melhorar a performance no cálculo de distâncias entre estrelas. 
Por se tratar de uma view materializada, as distâncias entre duas estrelas são 
calculadas apenas uma vez e salvas no banco de dados. Diferentemente de uma view comum, 
que é recalculada toda vez que uma sessão é iniciada, a view materializada permite otimizar
a consulta. Por esse motivo, também decidimos criar um índice para `ID_ESTRELA2`, já que será 
preciso buscar tanto em `ID_ESTRELA1` quanto em `ID_ESTRELA2` ao procurar por uma estrela. 
Calculamos apenas uma vez a distância entre as estrelas X e Y, evitando recalcular a distância entre Y e X.
*/

CREATE MATERIALIZED VIEW MV_DISTANCIAS_ESTRELAS
BUILD IMMEDIATE
REFRESH COMPLETE ON COMMIT
AS
SELECT 
    e1.ID_ESTRELA AS ID_ESTRELA1, 
    e2.ID_ESTRELA AS ID_ESTRELA2,
    calcular_distancia(e1.X, e1.Y, e1.Z, e2.X, e2.Y, e2.Z) AS DISTANCIA
FROM ESTRELA e1
JOIN ESTRELA e2 ON e1.ID_ESTRELA < e2.ID_ESTRELA;
