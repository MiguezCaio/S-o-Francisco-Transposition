import basedosdados as bd
import pandas as pd
import numpy as np

# Para carregar o dado direto no pandas
#df = bd.read_table(dataset_id='br_tse_eleicoes',table_id='candidatos',billing_project_id="proposal-political")
#candidatos=df
diretorio = r'D:\Projetos\São francisco v2\Data\\'

query="""SELECT id_municipio,situacao_setor,situacao_domicilio,V0208  FROM `basedosdados.br_ibge_censo_demografico.microdados_domicilio_2010`"""

agua_censo_2010=bd.read_sql(query,billing_project_id="proposal-political")
agua_censo_2010.to_csv(diretorio + 'agua_censo_2010.csv', index=False)

