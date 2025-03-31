library(sf)
library(xml2)
library(dplyr)
library(tidyr)
library(stringr)
library(curl)

# Ler a base de dados de reservatórios
Reservatorios <- st_read(dsn = "D:/Projetos/São francisco v2/Data/Reservatórios do Nordeste.kml")

# Função para extrair e pivotar os dados de um campo HTML
extract_and_pivot <- function(campo_html) {
  # Parse do HTML
  doc <- read_html(campo_html)
  
  # Extrair as células da tabela
  cells <- xml_find_all(doc, "//td")
  
  # Extrair texto das células
  campos_valores <- xml_text(cells)
  
  # Remover o primeiro e segundo elementos (não são campos e valores)
  campos_valores <- campos_valores[-c(1, 2)]
  
  # Dividir os campos e valores
  campos <- campos_valores[seq(1, length(campos_valores), by = 2)]
  valores <- campos_valores[seq(2, length(campos_valores), by = 2)]
  
  # Construir um data frame
  dados <- data.frame(Campo = campos, Valor = valores, stringsAsFactors = FALSE)
  
  # Pivotar os dados
  dados_pivot <- pivot_wider(dados, names_from = Campo, values_from = Valor) %>%
    select(Bacia, Municipio, UF)
  
  return(dados_pivot)
}

# Aplicar a função a todos os reservatórios
dados_completos <- Reservatorios %>%
  rowwise() %>%
  mutate(dados_html = extract_and_pivot(Description)) %>%
  select(-Description) %>%
  unnest(dados_html)

# Exibir o resultado
# Limpar e padronizar a coluna dados_completos$Municipio
limpar_texto <- function(coluna) {
  # Remover espaços em branco extras, converter para maiúsculo e cortar se necessário
  coluna <- toupper(str_trim(coluna))
  coluna <- str_sub(coluna, end = -1) # Se precisar cortar algo específico no final
  
  # Função para remover acentos e pontuações
  remover_acentos_pontuacoes <- function(texto) {
    texto <- iconv(texto, to = "ASCII//TRANSLIT")
    texto <- str_replace_all(texto, "[[:punct:]]", "")
    return(texto)
  }
  
  # Remover acentos e pontuações
  coluna <- remover_acentos_pontuacoes(coluna)
  
  return(coluna)
}

dados_completos$Municipio <-limpar_texto(dados_completos$Municipio)
##Agora vamos pegar todas as inaugurações
library(readxl)
Inaugurações <- read_excel("D:/Projetos/São francisco v2/Data/Inaugurações.xlsx")

Inaugurações$Municipio <-limpar_texto(Inaugurações$Municipio)


##Agora pegar o código desses municípios
br_data <- geobr::read_municipality() %>%
  mutate(name_muni=limpar_texto(name_muni)) %>%
  rename(Municipio=name_muni) %>%
  select(Municipio,code_muni,code_state,abbrev_state)

data<-dados_completos %>%
  inner_join(Inaugurações,by="Municipio") %>%
  inner_join(as.data.frame(br_data),by="Municipio")

library(readr)
chuva_v1 <- read_csv("D:/Projetos/São francisco v2/Data/chuva_v1.csv")
print(chuva_v1)
dados_municipio<-chuva_v1
dados_municipio$nome_mes <- month.name[dados_municipio$mes]
ggplot(dados_municipio, aes(x = data, y = precipitacao_total, color = factor(ano))) +
  geom_line() +
  labs(x = "Data", y = "Precipitação Total", color = "Ano") +
  scale_color_discrete(name = "Ano") +
  theme_minimal() +
  ggtitle("Precipitação Diária ao Longo dos Anos")

ar2 <- read_csv("D:/Projetos/São francisco v2/Data/PB-20240325T153047Z-001/PB/ar2.csv") %>%
  pivot_longer(cols = -c("Setor de emissão", "Categoria emissora", "Sub-categoria emissora",
                         "Produto ou sistema", "Detalhamento", "Recorte",
                         "Atividade geral", "Bioma", "Emissão/Remoção/Bunker", "Gás", "Cidade"),
               names_to = "Ano", 
               values_to = "Emissões") %>%
  mutate(Municipio = limpar_texto(str_extract(Cidade, "^[^(]+")),
         Estado = str_extract(Cidade, "\\([^\\)]+\\)")
  )

co2_monteiro<-ar2 %>%
  filter(Municipio=="MONTEIRO",
         Ano>=2013) %>%
  group_by(Ano,`Atividade geral`) %>%
  summarize(total=sum(Emissões)) %>%
  filter(`Atividade geral`!="Vegetação nativa")

library(ggplot2)
co2_monteiro$ano <- as.Date(paste0(co2_monteiro$Ano, "-01-01"))

# Data para a linha vertical
data_vertical <- as.Date("2017-03-10")

# Plot
ggplot(co2_monteiro, aes(x = ano, y = total, color = `Atividade geral`)) +
  geom_line() +
  geom_point() +
  geom_vline(xintercept = data_vertical, linetype = "dashed", color = "red") +
  labs(title = "Emissions by category",
       x = "Year",
       y = "Total Emissions",
       color = "Category") +
  theme_minimal()

producao_agricola <- read_csv("D:/Projetos/São francisco v2/Data/producao_agricola.csv") %>%
  mutate(temp_quantidade_produzida = replace_na(temp_quantidade_produzida, 0),
         perm_quantidade_produzida = replace_na(perm_quantidade_produzida, 0)) %>%
  mutate(total_qualidade_produzida = temp_quantidade_produzida + perm_quantidade_produzida)

plot_producao_agricola<-producao_agricola %>%
  filter(produto=="Tomate" | produto == "Milho (em grão)" | produto == "Coco-da-baía"|produto=="Feijão (em grão)",
         id_municipio==2509701)
plot_producao_agricola$ano <- as.Date(paste0(plot_producao_agricola$ano, "-01-01"))

ggplot(plot_producao_agricola, aes(x = ano, y = total_qualidade_produzida, color = produto)) +
  geom_line() +
  geom_point() +
  geom_vline(xintercept = data_vertical, linetype = "dashed", color = "red") +
  labs(title = "Quantity produced by Year",
       x = "Year",
       y = "Total Quantity",
       color = "Product") +
  theme_minimal()

transicao <- read_csv("D:/Projetos/São francisco v2/Data/transicao.csv") %>%
  group_by(ano,id_municipio) %>%
  mutate(pct_area=area/sum(area)) %>%
  mutate(transicao=paste(valor_en,"->",valor_en_1))

#remotes::install_github("davidsjoberg/ggsankey")
library(ggsankey)

df <- transicao %>%
  filter(ano>=2010) %>%
  rename(code_muni=id_municipio) %>%
  inner_join(br_data, by="code_muni") %>%
  group_by(ano,Municipio,valor_en_1) %>%
  summarise(pct_area = sum(pct_area)) %>%
  ungroup()

stacked_bar_plot <- ggplot(df, aes(x = ano, y = pct_area, fill = valor_en_1)) +
  geom_bar(stat = "identity") +
  labs(x = "Year", y = "Área (%)", fill = "Use of Land") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +  # Rotacionar os rótulos do eixo x
  ggtitle("Use of land on municipality")+
  facet_wrap(~Municipio)

# Visualizar o gráfico
print(stacked_bar_plot)

SIM <- read_csv("D:/Projetos/São francisco v2/Data/SIM.csv") %>%
  group_by(ano, id_municipio) %>%
  summarize(n=sum(numero_obitos))
SIM$ano<-as.Date(paste0(SIM$ano, "-01-01"))
ggplot(SIM, aes(x = ano, y = n)) +
  geom_line() +
  geom_point() +
  geom_vline(xintercept = data_vertical, linetype = "dashed", color = "red") +
  labs(title = "Fatalities of Infants",
       x = "Year",
       y = "Total Deaths",
       color = "Category") +
  theme_minimal()
