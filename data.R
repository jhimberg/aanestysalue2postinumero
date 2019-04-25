# asenna paketteja tarpeen mukaan...

#library(plyr) 
#library(DT) 
library(dplyr)
library(stringr)
library(readr) 
library(tidyr)
library(ggplot2)

# Move columns in a data frame
order_columns <- function(df, first_names) 
  select(df, one_of(c(first_names, setdiff(names(df), first_names))))

# kuntanumerosta kuntanimeksi
kuntano2nimi <- function(kuntano) {
  if(!exists("kuntano2kuntanimi_df")) kuntano2kuntanimi_df <<- readRDS(file = "map_and_names/kuntano2kuntanimi.2018.rds")
  plyr::mapvalues(kuntano, kuntano2kuntanimi_df$kuntano, kuntano2kuntanimi_df$kuntanimi, warn_missing = FALSE)
}

# Haetaan ja talletetaan rakennustiedot
if (!file.exists("data/rakennukset.rds")) source("rakennukset.R")

# Muodostetaan painot äänestysalueilta postinumeroalueille: tuloksena 
# dataframen map.pono.aanestysalue jolla muunnoksen voi tehdä
if (!file.exists("data/aanestysalue2postinumero.rds")) source("aanestysalue2postinumero.R")

# Haetaan eduskuntavaalien 2019 tulokset ja painotetaan ne postinumeroalueille
if(!file.exists("data/EKV2019_aanet_postinumeroittain.rds")) source("EKV2019_aanet.R")

