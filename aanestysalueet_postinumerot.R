
kuntano2kuntanimi<-readRDS(file="kuntano2kuntanimi.2018.rds")
rakennukset <- readRDS(rakennukset, file="rakennukset.rds")

# Äänestysalueet <=> tilastointipostinumeroalueet
# pudotetaan ei-tilastoitavia pois - ehkä hyvä, ehkä huono

tilastointipostinumerot.2018 <- readRDS(file="tilastointipostinumerot.2018.rds")

# huom: ääsestysalueen uniikki tunnus äänestysalueen numero _ja_ kuntanumero  
map.pono.aanestysalue <-group_by(rakennukset %>% 
                                filter(kayttotarkoitus == "asunto/toimitila" & !is.na(aanestysalue.nro) & 
                                         postinumero %in% tilastointipostinumerot.2018), 
                              kunta, aanestysalue.nro, postinumero) %>% 
  summarise(rakennukset.aanestysalue.pono=n()) %>% 
  ungroup %>%
  group_by(kunta, aanestysalue.nro) %>% 
  mutate(rakennukset.aanestysalue=sum(rakennukset.aanestysalue.pono)) %>% 
  ungroup %>% 
  group_by(postinumero) %>% 
  mutate(rakennukset.pono = sum(rakennukset.aanestysalue.pono)) %>% 
  ungroup %>% 
  mutate(w.aanestysalue2pono = rakennukset.aanestysalue.pono/rakennukset.aanestysalue, 
         w.pono2aanestysalue= rakennukset.aanestysalue.pono/rakennukset.pono)

saveRDS(map.pono.aanestysalue, file="map.pono.aanestysalue.rds")

# tekstinä
#write.table(map.pono.aanestysalue, row.names = FALSE, file="map.pono.aanestysalue.csv", sep=";")
#R.utils::gzip("map.pono.aanestysalue.csv", overwrite=TRUE)

