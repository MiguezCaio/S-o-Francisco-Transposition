source("Setup all Data.R")
library(ggplot2)
##########GET PAM
pam<-read_csv("D:/Projetos/São francisco v2/Data/pam_final.csv") 
pam<-pam %>%
  filter(!is.na(area_destinada_colheita)) %>%
  mutate(if_else(is.na(valor_producao),0,valor_producao))%>%
  inner_join(ipca, by="ano")%>%
  mutate(valor_adj=valor_producao)%>%
  group_by(ano,id_municipio) %>%
  summarise(area_total=sum(area_destinada_colheita),
            mean_area=mean(area_destinada_colheita),
            rendimento_medio=mean(rendimento_medio_producao),
            valor_2021=sum(valor_adj)) %>%
  filter(ano>=2010)

full_data<-data_to_regress %>%
  left_join(pam,by=c("Municipalities"="id_municipio")) %>%
  group_by(Municipalities) %>%
  mutate(post=if_else(ano>=year_data_trat,1,0),
         trat_post=trat*post,
         first_treat=if_else(trat==1,year_data_trat,0))

names(full_data)
#####did
library(did)
model1<-att_gt(yname="area_total",
               idname = "index",
               tname="ano",
               gname = "first_treat",
               data=full_data,
               allow_unbalanced_panel = TRUE,
               anticipation = 1,
               control_group = "notyettreated")
summary(model1)
ggdid(model1)
test<-aggte(model1,na.rm=TRUE,type = "dynamic")
plot<-ggdid(test)
ggsave("avg_agr_dyn.png",plot)
group<-aggte(model1,na.rm=TRUE)
summary(group)
plot<-ggdid(group)
ggsave("avg_agr_gp.png",plot)
