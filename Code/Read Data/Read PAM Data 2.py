import basedosdados as bd
import pandas as pd
import numpy as np

# Para carregar o dado direto no pandas
#df = bd.read_table(dataset_id='br_tse_eleicoes',table_id='candidatos',billing_project_id="proposal-political")
#candidatos=df
diretorio = r'D:\Projetos\Transposição São Francisco\Data\\'

query="""SELECT * FROM `basedosdados.br_seeg_emissoes.municipio` 
WHERE id_municipio IN ('2503704', '2509701');"""

PAM=bd.read_sql(query,billing_project_id="proposal-political")
PAM.to_csv(diretorio + 'PAM_transpo.csv', index=False)

