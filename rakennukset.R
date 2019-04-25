## Hae rakennustiedot

print("Lataa rakennusdata...")

"data/suomi_osoitteet_2019-02-19.zip"
download.file("https://www.avoindata.fi/data/dataset/cf9208dc-63a9-44a2-9312-bbd2c3952596/resource/d265962a-9f12-4152-8914-cca63c0f1e44/download/suomi_osoitteet_2019-02-15.zip",
              "data/suomi_osoitteet_2019-02-19.zip")

rakennukset <-
  read_delim("data/suomi_osoitteet_2019-02-19.zip", delim = ";", trim_ws = TRUE, col_types = "ccciiicccccccccc",
    col_names = c(
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
      "poiminta.pvm"
    )
)

kuntano2nimi <- function(kuntano, numero2nimi=readRDS(file = "map_and_names/kuntano2kuntanimi.2018.rds")) 
  plyr::mapvalues(kuntano, from = numero2nimi$kuntano, to = numero2nimi$kuntanimi, warn_missing = FALSE)

rakennukset <- mutate(rakennukset,
  kadunnimi.fi = iconv(kadunnimi.fi, "latin1", "utf-8"),
  kadunnimi.se = iconv(kadunnimi.se, "latin1", "utf-8"),
  aanestysalue.nimi.fi = iconv(aanestysalue.nimi.fi, "latin1", "utf-8"),
  aanestysalue.nimi.se = iconv(aanestysalue.nimi.se, "latin1", "utf-8"),
  kayttotarkoitus = plyr::mapvalues(kayttotarkoitus, c(0, 1, 2), c(NA, "asunto/toimitila", "tuotanto/muu")),
  kuntanimi = kuntano2nimi(kunta)
)

saveRDS(rakennukset, file = "data/rakennukset.rds")
