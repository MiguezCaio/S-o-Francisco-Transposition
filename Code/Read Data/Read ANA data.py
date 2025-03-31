import basedosdados as bd
import pandas as pd
import numpy as np

# Para carregar o dado direto no pandas
#df = bd.read_table(dataset_id='br_tse_eleicoes',table_id='candidatos',billing_project_id="proposal-political")
#candidatos=df
diretorio = r'D:\Projetos\São francisco v2\Data\\'

query="""SELECT * FROM `basedosdados.br_ana_reservatorios.sin` """

microdados_reservatorios=bd.read_sql(query,billing_project_id="proposal-political")
microdados_reservatorios.to_csv(diretorio + 'reservatorios_capacidade.csv', index=False)


