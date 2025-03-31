import basedosdados as bd
import pandas as pd
import numpy as np

# Para carregar o dado direto no pandas
#df = bd.read_table(dataset_id='br_tse_eleicoes',table_id='candidatos',billing_project_id="proposal-political")
#candidatos=df
diretorio = r'D:\Projetos\São francisco v2\Data\\'

query="""SELECT *
FROM basedosdados.br_inmet_bdmep.estacao AS estacao
JOIN basedosdados.br_inmet_bdmep.microdados AS microdados
ON estacao.id_estacao = microdados.id_estacao
WHERE estacao.id_municipio IN ('2603009',
'2603009',
'2509701',
'2616100',
'2307205',
'2308401',
'2306801',
'2503704',
'2406106',
'2503704', '2509701')
AND microdados.data BETWEEN '2015-01-01' AND '2023-10-10';"""

microdados_chuva=bd.read_sql(query,billing_project_id="proposal-political")
microdados_chuva.to_csv(diretorio + 'chuva_v2.csv', index=False)


microdados_chuva

query="""SELECT *
FROM basedosdados.br_inmet_bdmep.estacao;"""

estacoes=bd.read_sql(query,billing_project_id="proposal-political")
estacoes.to_csv(diretorio + 'estacoes.csv', index=False)
