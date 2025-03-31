library(sf)
library(xml2)
library(dplyr)
library(tidyr)
library(stringr)
library(curl)
library(readr)
library(XML)
diretorio<-"D:/Projetos/São francisco v2/Data/Reservatórios/"


tables <- readHTMLTable("D:/Projetos/São francisco v2/Data/Reservatórios/reservatorio_12001_estado_21.xls")
data <- tables[[1]]
# Get all files in the directory
files <- list.files(diretorio, full.names = TRUE)

# Initialize an empty list to store data frames
all_data <- list()

# Loop through each file
for (file in files) {
  # Read HTML table
  tables <- readHTMLTable(file)
  
  # Assuming the first table is the one you want, you can adjust if needed
  data <- tables[[1]]
  
  # Add data to the list
  all_data[[file]] <- data
}
estados<-data.frame(
  Estado=c("Paraíba","Ceará","Pernambuco","Rio Grande do Norte", "Alagoas"),
  UF=c("PB","CE","PE","RN","AL")
)

# Combine all data frames into one
combined_data <- do.call(rbind, all_data)
combined_data<-combined_data %>%
  mutate(cota=as.numeric(gsub(",",".",`Cota (m)`)),
         proporcao_volume_util=as.numeric(gsub(",",".",`Volume (%)`)),
         capacidade=as.numeric(gsub(",",".",`Capacidade (hm³)`)),
         volume_util=as.numeric(gsub(",",".",`Volume Útil (hm³)`)),
         data=as.Date(`Data da Medição`, "%d/%m/%Y")) %>%
  inner_join(estados,by="Estado")

write_csv(combined_data,"D:/Projetos/São francisco v2/Data/Reservatorios_nordeste_ana.csv")
