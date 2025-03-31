library(tidyverse)
library(geobr)
library(sf)
me <- st_read(dsn = "D:/Projetos/São francisco v2/Data/GEOFT_BHO_TRECHO_DRENAGEM")
??qtm
tmap::qtm(me)

library(brclimr)
library(stringr)

Reservatorios<-st_read(dsn = "D:/Projetos/São francisco v2/Data/Reservatórios do Nordeste.kml")
campo_html<-Reservatorios$Description[1]
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
dados_pivot <- pivot_wider(dados, names_from = Campo, values_from = Valor) %>%
  select(Bacia,Municipio,UF)
dados_pivot$Name<-Reservatorios$Name[1]

final_data<-Reservatorios %>%
  inner_join(dados_pivot,by="Name")


# Exibir os dados pivotados
print(dados_pivot)

#Voltar para o original

### Separar uma lista de municipios que receberam a transposição e quando

#### Puxar dados de todos eles

##Pivotar e gerar uma base final

br_data<-geobr::read_municipality()
data_chuva<-brclimr::fetch_data(
  code_muni = 2505105,
  product = "brdwgd",
  indicator = "pr",
  statistics = "mean",
  date_start = as.Date("2010-05-15"),
  date_end = as.Date("2020-05-21")
)
data_chuva$name<-"Chuva"
data_chuva$log_value=log(data_chuva$value+1)
test<-product_info("brdwgd")

ggplot(data =data_chuva, aes(x = date, y = log_value, color = name)) +
  geom_line() +
  scale_x_date(date_breaks = "2 months", date_labels =  "%m/%y") +
  ylim(0, NA) +
  labs(
    title = "Cuité - PB",
    x = "Date", 
    y = "Rain Fall",
    color = ""
  ) +
  theme_bw() +
  theme(legend.position = "bottom", legend.direction = "horizontal")

