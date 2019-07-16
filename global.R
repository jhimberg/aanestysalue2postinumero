library(shiny)
library(dplyr)
library(stringr)
library(readr) 
library(tidyr)
library(ggplot2)
library(DT)
library(ggiraph)
#library(plotly)


# To move a column in a data frame
order_columns <- function(df, first_names) 
  select(df, one_of(c(first_names, setdiff(names(df), first_names))))

# kuntanumero nimeksi
kuntano2nimi <- function(kuntano) {
  if(!exists("kuntano2kuntanimi_df")) kuntano2kuntanimi_df <<- readRDS(file = "./map_and_names/kuntano2kuntanimi.2018.rds")
  plyr::mapvalues(kuntano, kuntano2kuntanimi_df$kuntano, kuntano2kuntanimi_df$kuntanimi, warn_missing = FALSE)
}

# Data
paavo <- readRDS("./map_and_names/paavodata.rds")
aanet <- readRDS(file = "./data/EKV2019_aanet_postinumeroittain.rds")
postinumerot <- readRDS(file = "./data/tilastointipostinumerot.rds")

eduskuntavaalit <- readRDS(file = "./data/EKV2019_ehdokkaat.rds") %>% 
  filter(aluejako == "äänestysalue") %>% 
  rename(aanestysalue.nro = alue)

ehdokkaat <- eduskuntavaalit %>% 
  select(vaalipiiri, 
         puolue_lyhenne_alkuperainen, 
         puolue, 
         ehdokasnumero, 
         etunimi, 
         sukunimi, 
         sukupuoli, 
         ika, 
         kieli, 
         kotikunta_nimi) %>% 
  distinct() %>% 
  mutate(puolue = ifelse(grepl("^X", puolue) | puolue %in% c("ASYL","REF","AFÅ","RLI", "FÅ"), "MUUT", puolue))

puoluekoodit <- c("EOP", "FP","IP", "KD", "KESK","KOK", "KP", "KTP", "LIB", "MUUT","NYT", 
                  "PIR", "PS","RKP", "SDP", "SIN", "SKE", "SKP", "STL", "VAS", "VIHR")

kokonaisaanimaara_postinumeroittain <- 
  select(aanet, 
         postinumero, 
         KAIKKI = postinumeroalueen_kokonaisaanimaara) %>%
  distinct %>%
  filter(!is.na(postinumero))

if (!file.exists("data/puolueiden_aanet_postinumeroittain.rds")) {
  print("Lasketaan puolueiden äänet postinumeroalueilla ja tallenetaan!")
  puolueiden_aanet_postinumeroittain <- 
    left_join(aanet, 
              ehdokkaat,
              by = c("ehdokasnumero", "vaalipiiri")) %>% 
    select(postinumero, 
           aanet = ehdokkaan_aanet_postinumeroalueella, 
           puolue) %>% 
    group_by(postinumero, puolue) %>% 
    summarise(aanet = sum(aanet, na.rm=TRUE)) %>% 
    left_join(., kokonaisaanimaara_postinumeroittain, by="postinumero") %>% 
    spread(puolue, aanet, fill=0) %>% 
    ungroup %>%
    filter(!is.na(postinumero))
  saveRDS(file = "data/puolueiden_aanet_postinumeroittain.rds", puolueiden_aanet_postinumeroittain)
} else
  puolueiden_aanet_postinumeroittain <- readRDS(file = "data/puolueiden_aanet_postinumeroittain.rds")
    
paavodata <- paavo$data %>% 
  filter(vuosi == 2019, pono_level == 5) %>% 
  rename(postinumero = pono) %>% 
  select(-pono_level, -vuosi)

aanet_ja_paavodata <- left_join(paavodata, 
                                puolueiden_aanet_postinumeroittain, 
                                by = "postinumero") 
  

aanet_ja_paavodata <- mutate_at(aanet_ja_paavodata, .vars=vars(EOP:VIHR), .funs = list(osuus = ~ (./KAIKKI)))  %>%
  as_tibble

aanet_ja_paavodata <- mutate(aanet_ja_paavodata, 
                             vaestotiheys = he_vakiy/(pinta_ala/1e6))


puoluenimet <- 
  c("Eläinoikeuspuolue", 
    "Feministinen puolue", 
    "Itsenäisyyspuolue", 
    "Kristillisdemokraatit", 
    "Keskusta", 
    "Kokoomus", 
    "Kansalaispuolue", 
    "Kommunistinen Työväenpuolue", 
    "Liberaalipuolue", 
    "Muut", 
    "Liike Nyt", 
    "Piraattipuolue", 
    "Perussuomalaiset", 
    "RKP", 
    "Sosialidemokraatit",
    "Sininen tulevaisuus", 
    "Suomen Kansa Ensin", 
    "Suomen Kommunistinen Puolue", 
    "Seitsemän tähden liike", 
    "Vasemmistoliitto", 
    "Vihreät")

paavonimet <- 
  gsub("(.+) (HE|RA|PT|HR|TR|TP|KO|TE)$", "\\2 \\1", paavo$vars$nimi, perl=TRUE) %>% 
  gsub("(.+) (HE|RA|PT|HR|TR|TP|KO|TE)(, Osuus)$", "\\2 \\1 \\3", ., perl=TRUE) %>% 
  gsub(" , ",", ", .)

koodit <- c(paavo$vars$koodi, 
            "vaestotiheys",
            "KAIKKI", 
            puoluekoodit, 
            paste0(puoluekoodit, "_osuus"))

nimet <- c(paste(paavonimet, 2019+paavo$vars$paavo.vuosi.offset), 
           "HE_ Väestötiheys 2017", 
           "EKV2019 Alueen estimoitu kokonaisäänimäärä", 
           paste0("EKV2019 ", puoluenimet, ", äänimäärä"),
           paste0("EKV2019 ", puoluenimet, ", ääniosuus"))


names(koodit) <- nimet 
koodit <- koodit[8:length(koodit)]

ix <- order(names(koodit))
nimet <- names(koodit)[ix]
koodit <- koodit[ix]

vaalipiirit <- seq(length(unique(ehdokkaat$vaalipiiri)))
names(vaalipiirit)<-unique(ehdokkaat$vaalipiiri)







