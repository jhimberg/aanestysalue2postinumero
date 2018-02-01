
kuntano2kuntanimi<-readRDS(file="kuntano2kuntanimi.2018.rds")
rakennukset <- readRDS(rakennukset, file="rakennukset.rds")

# Äänestysalueet <=> tilastointipostinumeroalueet
# pudotetaan ei-tilastoitavia pois - ehkä hyvä, ehkä huono

tilastointipostinumerot.2018 <- readRDS(file="tilastointipostinumerot.2018.rds")

map.pono.aanestysalue <-count(rakennukset %>% 
                            filter(kayttotarkoitus == "asunto/toimitila" & !is.na(aanestysalue.nro) & 
                                     postinumero %in% tilastointipostinumerot.2018), kunta, aanestysalue.nro, postinumero) %>% 
  group_by(kunta, aanestysalue.nro) %>% 
  mutate(n.aanestysalue=sum(n)) %>% 
  ungroup %>% 
  group_by(postinumero) %>% 
  mutate(n.pono=sum(n)) %>% 
  ungroup %>% 
  mutate(w.aanestysalue2pono = n/n.aanestysalue, 
         w.pono2aanestysalue= n/n.pono) 

saveRDS(map.pono.aanestysalue, file="map.pono.aanestysalue.rds")

