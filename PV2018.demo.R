# asenna paketteja tarpeen mukaan...
#library(plyr) 
library(dplyr)
library(readr) 
library(tidyr)
library(ggplot2)

# Haetaan ja talletetaan rakennustiedot

if (!file.exists("rakennukset.rds")) source("rakennukset.R")

# Muodostetaan painot äänestysalueilta postinumeroalueille: tuloksena 
# dataframen map.pono.aanestysalue jolla muunnoksen voi tehdä
if (!file.exists("map.pono.aanestysalue.rds")) source("aanestysalueet_postinumerot.R")

## Demo 1: haetaan presidentinvaalin tulokset ja painotetaan ne postinumeroalueille
## Painotuksen teko, ks. presidentinvaali.2018.aanet.R

if(!file.exists("PV.aanet.postinumero.rds")) source("presidentinvaali.2018.aanet.R")

PV.aanet.postinumeroittain <- readRDS("PV.aanet.postinumero.rds")

# Demo 2 yhdistetään paavo dataan
# Paavo 2018 aineisto (todellisuudessa v. 2015-2016 lopusta); haettu ja muokattu Paavo -karttatiedoista
# ks. Tilastokeskus, Paavo-aineisto

paavo.2018 <- readRDS("paavo.2018.rds")

# Esimerkki: postinumeroalueen 18 täyttäneet vs. (arvioitu) Niinistön äänimäärä postinumeroalueella

left_join(PV.aanet.postinumeroittain %>% 
            select(postinumero, ehdokas, aania) %>% 
            spread(., ehdokas, aania), 
          paavo.2018, 
          by="postinumero") %>% 
  ggplot(aes(y=Niinistö, x=ko_ika18y, weight=ko_ika18y))+geom_point()+geom_smooth()


# Esimerkki: Haaviston ääniosuus vs. postinumeroalueen keskitulot. Koko: täysi-ikäisten määrä

left_join(PV.aanet.postinumeroittain %>% 
            select(postinumero, ehdokas, aanten.osuus) %>% 
            spread(., ehdokas, aanten.osuus), 
          paavo.2018, 
          by="postinumero") %>% 
  ggplot(aes(y=Haavisto, x=hr_ktu, size=ko_ika18y))+geom_point()
