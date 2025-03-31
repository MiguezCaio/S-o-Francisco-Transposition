source("Read_Reservatorios.R")
library(readr)
library(tidyverse)
library(geobr)
library(sf)
library(leaflet)
bacia_sf <- st_read(dsn = "D:/Projetos/São francisco v2/Data/GEOFT_BHO_HIDRONIMO")
bacia_sf_simplified <- st_simplify(bacia_sf, preserveTopology = TRUE, dTolerance = 0.1)
chuva_v2 <- read_csv("D:/Projetos/São francisco v2/Data/chuva_v2.csv")
chuva_v2<-chuva_v2 %>%
  select(id_municipio,estacao,longitude,latitude,data,hora,precipitacao_total) %>%
  filter(!is.na(precipitacao_total)) %>%
  rename(code_muni=id_municipio)

Inaugurações_2<-Inaugurações %>%
  group_by(code_muni) %>%
  slice(1) %>%
  arrange(Data)
dados<-chuva_v2 %>%
  inner_join(Inaugurações_2, by="code_muni") %>%
  mutate(pre_treat=if_else(data<=Data,1,0),
         post_treat=if_else(data>Data,1,0))

ggplot(dados, aes(x = data, y = precipitacao_total, color = Municipio)) +
  geom_line() +
  geom_vline(aes(xintercept = as.numeric(Data)), linetype = "dashed", color = "brown") +
  labs(title = "Precipitação Total por Cidade",
       x = "Data",
       y = "Precipitação Total") +
  scale_x_date(date_labels = "%d/%m/%Y") +
  theme_minimal()

estacoes <- read_csv("D:/Projetos/São francisco v2/Data/estacoes.csv") %>%
  rename(code_muni=id_municipio)
estacoes <-estacoes %>%
  inner_join(as.data.frame((br_data), by="code_muni")) %>%
  filter(abbrev_state %in% c("CE", "PE", "PB", "RN"))
estacoes_meteorologicas_sf <- st_as_sf(estacoes, coords = c("longitude", "latitude"), crs = 4326)

library(readxl)
Inaugurações <- read_xlsx("D:/Projetos/São francisco v2/Data/Inaugurações.xlsx")

Inaugurações$Municipio <-limpar_texto(Inaugurações$Municipio)

Inaugurações<- Inaugurações %>%
  inner_join(br_data, by="code_muni")

Inaugurações_sf <- st_as_sf(Inaugurações)

reservatorios <- dados_completos %>%
  st_as_sf(wkt = "geometry")
mapa <- leaflet() %>%
  addTiles()

mapa <- mapa %>% 
  addPolygons(data = bacia_sf_simplified, color = "blue", fillOpacity = 0.2, weight = 2)

# Adicionar as estações meteorológicas ao mapa
mapa <- mapa %>% 
  addCircleMarkers(data = estacoes_meteorologicas_sf, popup = ~estacao, color = "red", radius = 5)

# Adicionar os reservatórios ao mapa
mapa <- mapa %>% 
  addCircleMarkers(data = reservatorios, color = "green", radius = 2)

mapa <- mapa %>% 
  addPolygons(data = Inaugurações_sf, color = "purple", fillOpacity = 0.2, weight = 2) %>%
  addMarkers(data = estacoes_meteorologicas_sf, 
             popup = ~estacao, 
             label = ~estacao, 
             group = "Estações Meteorológicas") %>%
  addMarkers(data = reservatorios, 
             popup = ~Name, 
             label = ~Name, 
             group = "Reservatórios")
mapa <- addLayersControl(mapa, 
                         baseGroups = c("Estações Meteorológicas", "Reservatórios"),
                         options = layersControlOptions(collapsed = FALSE))

mapa
library(htmlwidgets)
mapa_html <- saveWidget(mapa, file = "D:/Projetos/São francisco v2/Results/mapa_completo.html", selfcontained = TRUE)
