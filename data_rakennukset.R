## Hae rakennustiedot

print("Lataa rakennusdata...")


# Rakennusdata löytyy https://www.avoindata.fi/data/fi/dataset/rakennusten-osoitetiedot-koko-suomi
# CC BY 4.0 

# Helmikuu 2019 kopio:

if (!file.exists("data/suomi_osoitteet_2019-02-19.zip")) 
  download.file("http://datakerho.s3.amazonaws.com/suomi_osoitteet_2019-02-19.zip", 
              "data/suomi_osoitteet_2019-02-19.zip")

rakennukset <-
  readr::read_delim("data/suomi_osoitteet_2019-02-19.zip", delim = ";", trim_ws = TRUE, col_types = "ccciiicccccccccc",
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
