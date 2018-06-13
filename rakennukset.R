## Hae rakennustiedot
download.file("https://www.avoindata.fi/data/dataset/cf9208dc-63a9-44a2-9312-bbd2c3952596/resource/e7e9fed1-b45b-41a3-af66-8cc09959882c/download/suomi_osoitteet_2017-11-15.zip",
              "suomi_osoitteet_2017-11-15.zip")

rakennukset <- read_delim("suomi_osoitteet_2017-11-15.zip", delim = ";", trim_ws = TRUE, col_types = "ccciiicccccccccc", 
                          col_names=c(
                            "rakennustunnus",
                            "kunta",
                            "maakunta",
                            "kayttotarkoitus",
                            "ETRS_TM35FIN_P",
                            "ETRS_TM35FIN_I",
                            "osoitenumero",
                            "kadunnimi.fi", 
                            "kadunnimi.se",
                            "katunumero",
                            "postinumero",
                            "aanestysalue.nro",
                            "aanestysalue.nimi.fi",
                            "aanestysalue.nimi.se",
                            "sijaintikiinteisto",
                            "poiminta.pvm")
)

kuntano2nimi <- function(kuntano, numero2nimi = readRDS(file = "kuntano2kuntanimi.2018.rds")) 
  plyr::mapvalues(kuntano, from = numero2nimi$kuntano, to = numero2nimi$kuntanimi, warn_missing = FALSE)

rakennukset <-mutate(rakennukset, 
                     kadunnimi.fi = iconv(kadunnimi.fi,"latin1","utf-8"),
                     kadunnimi.se = iconv(kadunnimi.se,"latin1","utf-8"),
                     aanestysalue.nimi.fi = iconv(aanestysalue.nimi.fi,"latin1","utf-8"),
                     aanestysalue.nimi.se = iconv(aanestysalue.nimi.se,"latin1","utf-8"),
                     kayttotarkoitus = plyr::mapvalues(kayttotarkoitus,c(0,1,2), c(NA, "asunto/toimitila", "tuotanto/muu")),
                     kuntanimi = kuntano2nimi(kunta))

saveRDS(rakennukset, file = "rakennukset.rds")

