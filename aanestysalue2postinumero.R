
print("Tee aluepainotus...")
rakennukset <- readRDS(file="data/rakennukset.rds")

# Käytössä olevat postinumerot, niiden pääasiallinen kunta ja alueen nimi
# Tässä esimerkissä käyetään vuoden 2019 Paavo-datan postinumeroita.
# Rakennukset jotka ovat tilastoimattomilla alueilla jätetään huomiotta - ratkaisu on ehkä hyvä, 
# ehkä huono. Osa äänestysalueiden äänistä katoaa tämän seurauksena, esim. ulkosuomalaiset jne. 

tilastointipostinumerot <- readRDS("map_and_names/paavodata.rds")$data %>% 
  select(vuosi, postinumero = pono, kuntano, pono_level, nimi) %>%
  filter(pono_level == 5 & vuosi == 2019) %>% 
  select(-pono_level, -vuosi) %>% 
  distinct

saveRDS(tilastointipostinumerot, file="data/tilastointipostinumerot.rds")

# huom: ääsestysalueen uniikki tunnus äänestysalueen numero _ja_ kuntanumero  
aanestysalue2postinumero <- 
  rakennukset %>%
  filter(kayttotarkoitus == "asunto/toimitila" & 
           !is.na(aanestysalue.nro) & 
           !is.na(kunta) &
           postinumero %in% tilastointipostinumerot$postinumero) %>%
  group_by(kunta, 
           aanestysalue.nro, 
           postinumero) %>%
  summarise(rakennukset.aanestysalue.pono = n()) %>% 
  ungroup %>%
  group_by(kunta, 
           aanestysalue.nro) %>%
  mutate(rakennukset.aanestysalue = sum(rakennukset.aanestysalue.pono)) %>%
  ungroup %>%
  group_by(postinumero) %>%
  mutate(rakennukset.pono = sum(rakennukset.aanestysalue.pono)) %>%
  ungroup %>%
  mutate(
    w.aanestysalue2pono = rakennukset.aanestysalue.pono / rakennukset.aanestysalue,
    w.pono2aanestysalue = rakennukset.aanestysalue.pono / rakennukset.pono
  )

aanestysalue_nimet <- select(rakennukset, kunta, aanestysalue.nro, aanestysalue.nimi.fi) %>% 
  filter(!is.na(kunta) & !is.na(aanestysalue.nro)) %>% 
  mutate(kuntanimi = kuntano2nimi(kunta)) %>%
  distinct %>% 
  group_by(kunta, aanestysalue.nro) %>% 
  summarise(kuntanimi = paste0(kuntanimi, collapse=""), 
            aanestysalue.nimi.fi = paste0(aanestysalue.nimi.fi, collapse="")) %>%
  mutate(aanestysalue.nimi.fi = 
           ifelse(aanestysalue.nimi.fi=="NA", as.character(aanestysalue.nro), aanestysalue.nimi.fi))
  
aanestysalue2postinumero <- left_join(aanestysalue2postinumero, 
                                      aanestysalue_nimet, by=c("kunta", "aanestysalue.nro")) %>% 
  left_join(., select(tilastointipostinumerot, postinumero, nimi), by=c("postinumero"))

saveRDS(aanestysalue2postinumero, 
        file = "data/aanestysalue2postinumero.rds")



