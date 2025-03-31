import basedosdados as bd
import pandas as pd
import numpy as np

# Para carregar o dado direto no pandas
#df = bd.read_table(dataset_id='br_tse_eleicoes',table_id='candidatos',billing_project_id='proposal-political')
#candidatos=df
diretorio = r'D:\Projetos\São francisco v2\Data\\'

query="""SELECT 
    id_municipio,
    ano,
    produto,
    MAX(CASE WHEN tipo = 'temp' THEN quantidade_produzida END) AS temp_quantidade_produzida,
    MAX(CASE WHEN tipo = 'perm' THEN quantidade_produzida END) AS perm_quantidade_produzida,
    MAX(CASE WHEN tipo = 'temp' THEN area_destinada_colheita END) AS temp_area_destinada_colheita,
    MAX(CASE WHEN tipo = 'perm' THEN area_destinada_colheita END) AS perm_area_destinada_colheita,
    MAX(CASE WHEN tipo = 'temp' THEN area_colhida END) AS temp_area_colhida
FROM (
    SELECT 
        'temp' AS tipo,
        id_municipio,
        ano, produto,
        quantidade_produzida,
        area_plantada AS area_destinada_colheita,
        area_colhida,
        rendimento_medio_producao,
        valor_producao
    FROM basedosdados.br_ibge_pam.lavoura_temporaria
    WHERE id_municipio IN ('2300101','2301703','2301901','2302008','2302503','2304202','2305704','2307106',
    '2307205','2308104',
 '2308302','2308401','2310605','2311108','2500205','2500700','2500734','2502102','2502201','2502409',
 '2503308','2503704','2503902','2504108','2504405','2504702','2505303','2505600','2506608','2507002',
'2509602','2509701','2510006','2510600','2512200','2513356','2513505','2514107','2514305','2514503',
 '2514800','2515203','2515500','2515708','2516300','2517407','2600104','2601201','2601607','2601805',
 '2602803','2603009','2603405','2603900','2603926','2604304','2605103','2605608','2605707','2606309',
'2606606','2606903','2607000','2607109','2607406','2607703','2608057','2609303','2609808','2610400',
 '2610905','2611002','2611200','2611533','2612208','2612604','2613503','2613602','2613909','2614006',
 '2614105','2614303','2614600','2614808','2615201','2615805','2615904','2616100','2705002','2706422',
 '2900207','2907707','2909901','2911402','2919900','2927101') 
    AND ano >= 2008 
    AND quantidade_produzida IS NOT NULL

    UNION ALL

    SELECT 
        'perm' AS tipo,
        id_municipio,
        ano, produto,
        quantidade_produzida,
        area_destinada_colheita,
        area_colhida,
        rendimento_medio_producao,
        valor_producao
    FROM `basedosdados.br_ibge_pam.lavoura_permanente`
    WHERE id_municipio IN ('2503704', '2509701') 
    AND ano >= 2008 
    AND quantidade_produzida IS NOT NULL
) AS dados_combinados
GROUP BY id_municipio, ano,  produto;
"""

producao_agricola=bd.read_sql(query,billing_project_id='proposal-political')
producao_agricola.to_csv(diretorio + 'producao_agricola.csv', index=False)



