## Hae rakennustiedot

print("Lataa rakennusdata...")


# Viimeisin Väestörekisterikeskuksen avoin rakennustieto data löytyy 
# https://www.avoindata.fi/data/fi/dataset/rakennusten-osoitetiedot-koko-suomi, lisenssi 
# CC BY 4.0. Tässä on käytössä helmikuu datan 15.2. 2019 kopio haettu 1.3. 
# https://www.avoindata.fi/data/fi/dataset/rakennusten-osoitetiedot-koko-suomi lisenssi CC BY 4.0

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
      "kadunnimi_fi",
      "kadunnimi_se",
      "katunumero",
      "postinumero",
      "aanestysalue_nro",
      "aanestysalue_nimi_fi",
      "aanestysalue_nimi_se",
      "sijaintikiinteisto",
      "poiminta_pvm"
    )
)

kuntano2nimi <- function(kuntano, numero2nimi=readRDS(file = "map_and_names/kuntano2kuntanimi.2018.rds")) 
  plyr::mapvalues(kuntano, from = numero2nimi$kuntano, to = numero2nimi$kuntanimi, warn_missing = FALSE)

rakennukset <- mutate(rakennukset,
  kadunnimi_fi = iconv(kadunnimi_fi, "latin1", "utf-8"),
  kadunnimi_se = iconv(kadunnimi_se, "latin1", "utf-8"),
  aanestysalue_nimi_fi = iconv(aanestysalue_nimi_fi, "latin1", "utf-8"),
  aanestysalue_nimi_se = iconv(aanestysalue_nimi_se, "latin1", "utf-8"),
  kayttotarkoitus = plyr::mapvalues(kayttotarkoitus, c(0, 1, 2), c(NA, "asunto/toimitila", "tuotanto/muu"))
)

saveRDS(rakennukset, file = "data/rakennukset.rds")
