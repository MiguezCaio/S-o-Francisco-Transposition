library(sf)
library(xml2)
library(dplyr)
library(tidyr)
library(stringr)
library(curl)
library(readr)
library(lubridate)
# Ler o mapa
st_layers(dsn = "D:/Projetos/São francisco v2/Data/Transposição São Francisco.kml")
Eixo_Leste <- st_read(dsn = "D:/Projetos/São francisco v2/Data/Transposição São Francisco.kml", layer="Eixo Leste")
Eixo_Norte<- st_read(dsn = "D:/Projetos/São francisco v2/Data/Transposição São Francisco.kml", layer="Eixo Norte")
Reservatorios_Norte<- st_read(dsn = "D:/Projetos/São francisco v2/Data/Transposição São Francisco.kml", layer="Reservatórios Norte")
res_Leste<- st_read(dsn = "D:/Projetos/São francisco v2/Data/Transposição São Francisco.kml", layer="Reservatórios Leste")

##Ler dados de reservatórios
res<- st_read(dsn = "D:/Projetos/São francisco v2/Data/Reservatórios do Nordeste.kml")

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
geores <- res %>%
  rowwise() %>%
  mutate(dados_html = extract_and_pivot(Description)) %>%
  select(-Description) %>%
  unnest(dados_html)


### Ver distâncias de reservatório a cada eixo
Metas <- Eixo_Leste %>%
  bind_rows(Eixo_Norte) %>% 
  filter(str_detect(Name, "Meta")) 


distance_res_leste<-st_distance(Metas,geores)

df <- as.data.frame(distance_res_leste)
colnames(df)<-geores$Name
row.names(df)<-Metas$Name
df$Metas<-Metas$Name

distance_res_long <- pivot_longer(df, 
                                  cols = -Metas,
                                  names_to = "reservatorios", 
                                  values_to = "Distance")


##Definir o grupo de controle
#Controle se mais de 10km
#Tratamento se menos

closest_res<-distance_res_long %>%
  mutate(distance_num=as.numeric(Distance)) %>%
  group_by(reservatorios) %>%
  summarise(min_dist = min(distance_num),
            min_meta = Metas[which.min(distance_num)])

treat_dist<-15000
buffer_dist<-25000
control_dist<-60000
tratamento<-closest_res %>%
  mutate(status=if_else(min_dist<=treat_dist,3,
                if_else(min_dist<=buffer_dist,2,
                if_else(min_dist<=control_dist,1,0))),
         trat=if_else(min_dist<=treat_dist,1,0))

check<- tratamento %>%
  group_by(status) %>%
  summarise(n=n())


data_to_regress<-tratamento %>%
  filter(status!=0 & status!=2) %>%
  rename(Meta=min_meta)%>%
  mutate(index = row_number())
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
data_to_regress$reservatorios<-limpar_texto(data_to_regress$reservatorios)

###Get time of treatment and data on volume
library(readxl)
metas_time <- read_excel("D:/Projetos/São francisco v2/Data/Inaugurações.xlsx", 
                           sheet = "Finalização de Metas") %>%
  mutate(data_trat=as.Date(`Finalização`)) %>%
  select(Meta,data_trat)


data_to_regress <-data_to_regress %>%
  inner_join(metas_time,by="Meta")
Reservatorios_nordeste_ana <- read_csv("D:/Projetos/São francisco v2/Data/Reservatorios_nordeste_ana.csv")
Reservatorios_nordeste_ana$Nome<-limpar_texto(Reservatorios_nordeste_ana$Nome)
Reservatorios_nordeste_ana<- Reservatorios_nordeste_ana %>%
  rename(reservatorios=Nome)
full_data<-data_to_regress %>%
  inner_join(Reservatorios_nordeste_ana,by="reservatorios")


full_data<-full_data %>%
  mutate(post=if_else(data>data_trat,1,0),
         trat_post=trat*post)

library(fixest)

outcome<-"proporcao_volume_util"
formula_basica<-paste0(outcome," ~ ","trat_post + volume_util")
fe<-"| reservatorios + data"

formula<-as.formula(paste0(formula_basica,fe))
model0<-feols(as.formula(formula_basica),full_data)
model1<-feols(formula,full_data)
etable(model0,model1)

##########DID
teste <- full_data %>% arrange(data)
min_obs <- 1000
obs_counts <- full_data %>%
  group_by(index) %>%
  summarise(count = n()) %>%
  filter(count>min_obs)



data_limite<-as.Date("2010-01-01")

combinations_to_keep <- full_data %>%
  inner_join(obs_counts,by="index") %>%
  filter(data>data_limite)



common_dates <- teste %>%
  group_by(data) %>%
  summarise(count = n_distinct(index))
unique(full_data$index)

###Usando o modelo did
first_date <- full_data %>%
  slice(1) %>%
  pull(data)

dates<-combinations_to_keep %>%
  select(data) %>%
  distinct() %>%
  arrange() %>%
  mutate(t=row_number())

data_did<-combinations_to_keep %>%
  inner_join(dates,by="data") %>%
  rename(period=t)%>%
  left_join(dates, by = c("data_trat" = "data")) %>%
  rename(period_treat=t) %>%
  mutate(first_treat = if_else(trat == 1, period_treat, 0))
library(did)
#####Unbalanced
model3<-did::att_gt(yname=outcome,
            tname="period",
            idname="index",
            gname="first_treat",
            data=data_did
            ,allow_unbalanced_panel = TRUE
            )

ggdid(model3)
test<-aggte(model3,na.rm=TRUE,type = "dynamic")
ggdid(test)
group<-aggte(model3,na.rm=TRUE)
ggdid(group)
group
### Unbalanced Month never treated

data_did_months <- combinations_to_keep %>%
  mutate(first_of_month = floor_date(data, "month")) %>%
  group_by(index, first_of_month) %>%
  summarise(proporcao_volume_util = mean(proporcao_volume_util, na.rm = TRUE),
            trat=mean(trat),
            post=if_else(mean(post)<1,0,1),
            trat_post=if_else(mean(trat_post)<1,0,1),
            data_trat=floor_date(unique(data_trat), "month")
            , .groups = 'drop')
months_periods <- combinations_to_keep %>%
  mutate(first_of_month = floor_date(data, "month")) %>%
  select(first_of_month) %>%
  distinct() %>%
  arrange(first_of_month) %>%  # Explicitly arrange by first_of_month
  mutate(t = row_number())


data_did_months <-data_did_months %>%
  inner_join(months_periods,by="first_of_month")%>%
  rename(period=t)%>%
  left_join(months_periods, by = c("data_trat" = "first_of_month")) %>%
  rename(period_treat=t) %>%
  mutate(first_treat = if_else(trat == 1, period_treat, 0))
model4<-did::att_gt(yname=outcome,
                    tname="period",
                    idname="index",
                    gname="first_treat",
                    data=data_did_months
                    ,allow_unbalanced_panel = TRUE
)
library(did)
summary(model4)
ggdid(model4)
test<-aggte(model4,na.rm=TRUE,type = "dynamic")
ggdid(test)
group<-aggte(model4,na.rm=TRUE)
ggdid(group)
##Unbalanced not yet treated
model4<-did::att_gt(yname=outcome,
                    tname="period",
                    idname="index",
                    gname="first_treat",
                    data=data_did_months
                    ,allow_unbalanced_panel = TRUE
)
##########modelo de trimestre
data_did_tri<-combinations_to_keep %>%
  mutate(first_of_month = floor_date(data, "quarter")) %>%
  group_by(index, first_of_month) %>%
  summarise(proporcao_volume_util = mean(proporcao_volume_util, na.rm = TRUE),
            trat=mean(trat),
            post=if_else(mean(post)<1,0,1),
            trat_post=if_else(mean(trat_post)<1,0,1),
            data_trat=floor_date(unique(data_trat), "quarter")
            , .groups = 'drop')
months_periods <- combinations_to_keep %>%
  mutate(first_of_month = floor_date(data, "quarter")) %>%
  select(first_of_month) %>%
  distinct() %>%
  arrange(first_of_month) %>%  # Explicitly arrange by first_of_month
  mutate(t = row_number())


data_did_tri <-data_did_tri %>%
  inner_join(months_periods,by="first_of_month")%>%
  rename(period=t)%>%
  left_join(months_periods, by = c("data_trat" = "first_of_month")) %>%
  rename(period_treat=t) %>%
  mutate(first_treat = if_else(trat == 1, period_treat, 0))

filtered_data <- data_did_tri %>%
  group_by(index) %>%
  filter(period >= (period[which.min(abs(first_of_month - data_trat))] - 8) & 
           period <= (period[which.min(abs(first_of_month - data_trat))] + 8)) %>%
  ungroup()

print(filtered_data)

model_tri<-did::att_gt(yname=outcome,
                    tname="period",
                    idname="index",
                    gname="first_treat",
                    data=filtered_data,
                    control_group="notyettreated",
                    allow_unbalanced_panel = TRUE
)

summary(model_tri)
ggdid(model_tri)
test<-aggte(model_tri,na.rm=TRUE,type = "dynamic")
ggdid(test)
group<-aggte(model_tri,na.rm=TRUE)
ggdid(group)








model5<-did::att_gt(yname=outcome,
                    tname="period",
                    idname="index",
                    gname="first_treat",
                    data=data_did_months,
                    control_group="notyettreated",
                    allow_unbalanced_panel = TRUE
)

summary(model5)
ggdid(model5)
ggsave("avg_res.png")
test<-aggte(model5,na.rm=TRUE,type = "dynamic")
ggdid(test)
group<-aggte(model5,na.rm=TRUE)
ggdid(group)
ggsave("avg_res_gp.png")

###Unbalanced with antecipation of a year
model6<-did::att_gt(yname=outcome,
                    tname="period",
                    idname="index",
                    gname="first_treat",
                    data=data_did_months,
                    anticipation=12,
                    control_group="notyettreated",
                    allow_unbalanced_panel = TRUE
)

summary(model6)
ggdid(model6)
ggsave("avg_res_anti.png")
test<-aggte(model6,na.rm=TRUE,type = "dynamic")
ggdid(test)
group<-aggte(model6,na.rm=TRUE)
ggdid(group)
ggsave("avg_res_anti_gp.png")

####Unbalanced with year
data_did_year <- combinations_to_keep %>%
  mutate(first_of_year = floor_date(data, "year")) %>%
  group_by(index,first_of_year) %>%
  summarise(proporcao_volume_util = mean(proporcao_volume_util, na.rm = TRUE),
            trat=mean(trat),
            post=if_else(mean(post)>0,1,0),
            trat_post=if_else(mean(trat_post)>0,1,0),
            data_trat=floor_date(unique(data_trat), "year")
            , .groups = 'drop')
year_periods <- combinations_to_keep %>%
  mutate(first_of_year = floor_date(data, "year")) %>%
  select(first_of_year) %>%
  distinct() %>%
  arrange(first_of_year) %>%  # Explicitly arrange by first_of_year
  mutate(t = row_number())


data_did_year <-data_did_year %>%
  inner_join(year_periods,by="first_of_year")%>%
  rename(period=t)%>%
  left_join(year_periods, by = c("data_trat" = "first_of_year")) %>%
  rename(period_treat=t) %>%
  mutate(first_treat = if_else(trat == 1, period_treat, 0))
model7<-did::att_gt(yname=outcome,
                    tname="period",
                    idname="index",
                    gname="first_treat",
                    data=data_did_year
                    ,allow_unbalanced_panel = TRUE
)
summary(model7)
ggdid(model7)
test<-aggte(model7,na.rm=TRUE,type = "dynamic")
ggdid(test)
group<-aggte(model7,na.rm=TRUE)
ggdid(group)
