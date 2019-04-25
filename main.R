# asenna paketteja tarpeen mukaan...
#library(plyr) 
library(dplyr)
library(readr) 
library(tidyr)
library(ggplot2)

# Haetaan ja talletetaan rakennustiedot
if (!file.exists("data/rakennukset.rds")) source("rakennukset.R")

# Muodostetaan painot äänestysalueilta postinumeroalueille: tuloksena 
# dataframen map.pono.aanestysalue jolla muunnoksen voi tehdä
if (!file.exists("data/aanestysalue2postinumero.rds")) source("aanestysalue2postinumero.R")

# Haetaan eduskuntavaalien 2019 tulokset ja painotetaan ne postinumeroalueille
if(!file.exists("data/EKV2019_aanet_postinumeroittain.rds")) source("EKV2019_aanet.R")

