import basedosdados as bd
import pandas as pd
import numpy as np

# Para carregar o dado direto no pandas
#df = bd.read_table(dataset_id='br_tse_eleicoes',table_id='candidatos',billing_project_id='proposal-political')
#candidatos=df
diretorio = r'D:\Projetos\São francisco v2\Data\\'

query="""SELECT * FROM `basedosdados.br_ibge_pam.lavoura_permanente`
"""

producao_agricola_perm=bd.read_sql(query,billing_project_id='proposal-political')
producao_agricola_perm.to_csv(diretorio + 'producao_agricola_perm.csv', index=False)


query="""SELECT * FROM `basedosdados.br_ibge_pam.lavoura_temporaria`
"""

producao_agricola_temp=bd.read_sql(query,billing_project_id='proposal-political')
producao_agricola_temp.to_csv(diretorio + 'producao_agricola_temp.csv', index=False)



