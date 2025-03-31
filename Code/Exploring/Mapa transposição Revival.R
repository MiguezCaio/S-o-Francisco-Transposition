library(sf)
library(xml2)
library(dplyr)
library(tidyr)
library(stringr)
library(curl)
library(readr)
library(lubridate)
Root<-"C:/Users/migue/OneDrive - Fundacao Getulio Vargas - FGV/Projetos/São francisco v2"
# Ler o mapa
st_layers(dsn = paste0(Root,"/Data/Transposição São Francisco.kml"))
Eixo_Leste <- st_read(dsn = paste0(Root,"/Data/Transposição São Francisco.kml"), layer="Eixo Leste")
Eixo_Norte<- st_read(dsn = paste0(Root,"/Data/Transposição São Francisco.kml"), layer="Eixo Norte")
Reservatorios_Norte<- st_read(dsn = paste0(Root,"/Data/Transposição São Francisco.kml"), layer="Reservatórios Norte")
res_Leste<- st_read(dsn = paste0(Root,"/Data/Transposição São Francisco.kml"), layer="Reservatórios Leste")

##Ler dados de reservatórios
res<- st_read(dsn = paste0(Root,"/Data/Reservatórios do Nordeste.kml"))
### Ver distâncias de reservatório a cada eixo
Metas <- Eixo_Leste %>%
  bind_rows(Eixo_Norte) %>% 
  filter(str_detect(Name, "Meta")) 

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
##Pegar o mapa hidrológico
map_hidro <- st_read(dsn = paste0(Root,"/Data/DispH_v27nov20_Snirh.shp"))
st_crs(map_hidro) <- 4674

# Agora pode transformar para outro CRS ou usar normalmente
test <- map_hidro %>%
  select(OBJECTID, noriocomp, geometry) %>%
  st_transform(st_crs(Metas))
distance_rios_metas <- st_distance(test,Metas)

df <- as.data.frame(distance_rios_metas)
colnames(df)<-Metas$Name
row.names(df)<-test$OBJECTID
df$rio<-test$OBJECTID

distance_rios_metas_long <- pivot_longer(df, 
                                  cols = -rio,
                                  names_to = "Metas", 
                                  values_to = "Distance")

library(arrow)
write_parquet(distance_rios_metas_long, "distance_rios_metas_long.parquet")
##Definir o grupo de controle
#Controle se mais de 10km
#Tratamento se menos

closest_res<-distance_rios_metas_long %>%
  mutate(distance_num=as.numeric(Distance)) %>%
  group_by(rio) %>%
  summarise(min_dist = min(distance_num),
            min_meta = Metas[which.min(distance_num)])

##Pegar agr os cursos dágua só a 30km da transposição e plotar:
close_res<-closest_res %>%
  filter(min_dist<=30000)

rivers_transpo<-map_hidro %>%
  st_transform(st_crs(Metas))%>%
  filter(OBJECTID %in% close_res$rio)

library(leaflet)

br_data <- geobr::read_municipality() %>%
  mutate(name_muni = limpar_texto(name_muni))

# Reprojetar os municípios para o mesmo CRS dos Metas
br_data <- st_transform(br_data, st_crs(Metas))

# Agora, calcular as distâncias entre as metas e os municípios
Metas_2d <- st_zm(Metas, drop = TRUE, what = "ZM")
# Criar o mapa interativo com leaflet
mapa<-leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  # Adiciona os municípios
  addPolygons(data = br_data,
              color = "#444444", weight = 1, fillOpacity = 0.05,
              popup = ~name_muni) %>%
  addPolylines(data = rivers_transpo,
                         color = "red", weight = 2, opacity = 0.05,
                         popup = ~noriocomp)%>%
  addPolylines(data = Metas_2d,
               color = "purple", weight = 2, opacity = 0.8,
               popup = ~Name) %>%
  # Adiciona os reservatórios
  addCircleMarkers(data = geores,
                   color = "green", radius = 5,
                   popup = ~Name) 
mapa
library(htmlwidgets)
mapa_html <- saveWidget(mapa, file = paste0(Root,"/Data/mapa_interativo.html"), selfcontained = TRUE)

