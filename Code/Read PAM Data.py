import basedosdados as bd
import pandas as pd
import numpy as np

# Para carregar o dado direto no pandas
#df = bd.read_table(dataset_id='br_tse_eleicoes',table_id='candidatos',billing_project_id="proposal-political")
#candidatos=df
diretorio = r'D:\Projetos\São francisco v2\Data\\'

query="""SELECT 
    id_municipio,
    ano,
    produto,
    MAX(CASE WHEN tipo = 'temp' THEN quantidade_produzida END) AS temp_quantidade_produzida,
    MAX(CASE WHEN tipo = 'perm' THEN quantidade_produzida END) AS perm_quantidade_produzida
FROM (
    SELECT 
        'temp' AS tipo,
        id_municipio,
        ano, produto,
        quantidade_produzida
    FROM basedosdados.br_ibge_pam.municipio_lavouras_temporarias
    WHERE id_municipio IN ('2503704', '2509701') 
    AND ano >= 2008 
    AND quantidade_produzida IS NOT NULL

    UNION ALL

    SELECT 
        'perm' AS tipo,
        id_municipio,
        ano, produto,
        quantidade_produzida
    FROM `basedosdados.br_ibge_pam.municipio_lavouras_permanentes`
    WHERE id_municipio IN ('2503704', '2509701') 
    AND ano >= 2008 
    AND quantidade_produzida IS NOT NULL
) AS dados_combinados
GROUP BY id_municipio, ano,  produto;
"""

producao_agricola=bd.read_sql(query,billing_project_id="proposal-political")
producao_agricola.to_csv(diretorio + 'producao_agricola.csv', index=False)



