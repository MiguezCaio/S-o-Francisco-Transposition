transicao <- read_csv("D:/Projetos/São francisco v2/Data/transicaov2.csv") %>%
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
  mutate(pct_area = sum(pct_area)) %>%
  inner_join(Inaugurações_2, by="code_muni")
    
    
stacked_bar_plot <- ggplot(df, aes(x = ano, y = pct_area, fill = valor_en_1)) +
  geom_bar(stat = "identity") +
  labs(x = "Year", y = "Área (%)", fill = "Use of Land") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +  # Rotacionar os rótulos do eixo x
  ggtitle("Use of land on municipality")+
  facet_wrap(~Municipio.x)
# Exibir o gráfico
print(stacked_bar_plot)

