import basedosdados as bd
import pandas as pd
import numpy as np

# Para carregar o dado direto no pandas
#df = bd.read_table(dataset_id='br_tse_eleicoes',table_id='candidatos',billing_project_id="proposal-political")
#candidatos=df
diretorio = r'D:\Projetos\São francisco v2\Data\\'

query="""SELECT 
    transicao.*, 
    classe_de.*, 
    classe_para.*
FROM 
    basedosdados.br_mapbiomas_estatisticas.transicao_municipio_de_para_anual AS transicao
JOIN 
    basedosdados.br_mapbiomas_estatisticas.classe AS classe_de
ON 
    transicao.id_classe_de = classe_de.chave
JOIN 
    basedosdados.br_mapbiomas_estatisticas.classe AS classe_para
ON 
    transicao.id_classe_para = classe_para.chave
WHERE 
    transicao.id_municipio = '2509701' OR transicao.id_municipio ="2516607";
"""

transicao=bd.read_sql(query,billing_project_id="proposal-political")
transicao.to_csv(diretorio + 'transicao.csv', index=False)


# Para carregar o dado direto no pandas
#df = bd.read_table(dataset_id='br_tse_eleicoes',table_id='candidatos',billing_project_id="proposal-political")
#candidatos=df
diretorio = r'D:\Projetos\São francisco v2\Data\\'

query="""SELECT 
    transicao.*, 
    classe_de.*, 
    classe_para.*
FROM 
    basedosdados.br_mapbiomas_estatisticas.transicao_municipio_de_para_anual AS transicao
JOIN 
    basedosdados.br_mapbiomas_estatisticas.classe AS classe_de
ON 
    transicao.id_classe_de = classe_de.chave
JOIN 
    basedosdados.br_mapbiomas_estatisticas.classe AS classe_para
ON 
    transicao.id_classe_para = classe_para.chave
WHERE 
    transicao.id_municipio IN ('2603009',
'2603009',
'2509701',
'2616100',
'2307205',
'2308401',
'2306801',
'2503704',
'2406106',
'2503704', '2509701');
"""

transicao=bd.read_sql(query,billing_project_id="proposal-political")
transicao.to_csv(diretorio + 'transicaov2.csv', index=False)











