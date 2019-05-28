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
    

if (!file.exists("data/ehdokkaiden_aanet_postinumeroittain.rds")) {
  print("Lasketaan ehdokkaiden äänet postinumeroalueilla ja tallenetaan - kestää 1. kerralla n. minuutin!")
  ehdokkaiden_aanet_postinumeroittain <- 
    purrr::map(unique(ehdokkaat$vaalipiiri), .f=
                 function(x) left_join(aanet, 
                                       ehdokkaat,
                                       by = c("ehdokasnumero", "vaalipiiri")) %>% 
                 select(postinumero, 
                        vaalipiiri, 
                        ehdokasnumero,
                        aanet = ehdokkaan_aanet_postinumeroalueella, 
                        puolue) %>% 
                 group_by(postinumero, ehdokasnumero, vaalipiiri) %>% 
                 summarise(aanet = sum(aanet, na.rm=TRUE)) %>% 
                 left_join(., kokonaisaanimaara_postinumeroittain, by="postinumero") %>% 
                 filter(!is.na(postinumero) & vaalipiiri == x) %>% 
                 left_join(., select(ehdokkaat, vaalipiiri, ehdokasnumero, sukunimi, etunimi, puolue), 
                           by=c("ehdokasnumero","vaalipiiri")) %>% 
                 as_tibble)
  saveRDS(file = "data/ehdokkaiden_aanet_postinumeroittain.rds", ehdokkaiden_aanet_postinumeroittain)
} else
  ehdokkaiden_aanet_postinumeroittain <- readRDS(file = "data/ehdokkaiden_aanet_postinumeroittain.rds")

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

#tarkeimmat <- c("he_vakiy","he_kika","ko_ika18y","hr_tuy","hr_ktu","hr_mtu","hr_ovy","te_taly","tr_kuty",
#"ra_raky","pt_vakiy","pt_tyoll","pt_tyott","pt_0_14","pt_opisk","pt_elakel","pt_muut","pt_tyovy",
#"pt_tyovu","he_naiset_osuus","he_miehet_osuus","he_0_2_osuus","he_3_6_osuus","he_7_12_osuus",
#"he_13_15_osuus","he_16_17_osuus","he_18_19_osuus","he_20_24_osuus","he_25_29_osuus",
#"he_30_34_osuus","he_35_39_osuus","he_40_44_osuus","he_45_49_osuus","he_50_54_osuus","he_55_59_osuus",
#"he_60_64_osuus","he_65_69_osuus","he_70_74_osuus","he_75_79_osuus","he_80_84_osuus",
#"he_85__osuus","ko_perus_osuus","ko_koul_osuus","ko_yliop_osuus","ko_ammat_osuus",
#"ko_al_kork_osuus","ko_yl_kork_osuus","hr_pi_tul_osuus","hr_ke_tul_osuus","hr_hy_tul_osuus",
#"te_nuor_osuus","te_eil_np_osuus","te_laps_osuus","te_plap_osuus","te_aklap_osuus",
#"te_klap_osuus","te_teini_osuus","te_aik_osuus","te_elak_osuus","te_omis_as_osuus",
#"te_vuok_as_osuus","te_muu_as_osuus","tr_pi_tul_osuus","tr_ke_tul_osuus","tr_hy_tul_osuus",
#"ra_ke_osuus","ra_muut_osuus","ra_asrak_osuus","ra_pt_as_osuus","ra_kt_as_osuus",
#"pt_tyoll_osuus","pt_tyott_osuus","pt_0_14_osuus","pt_opisk_osuus","pt_elakel_osuus",
#"pt_muut_osuus","pt_tyovy_osuus","pt_tyovu_osuus","KAIKKI",
#"EOP_osuus","FP_osuus","IP_osuus","KD_osuus","KESK_osuus",
#"KOK_osuus","KP_osuus","KTP_osuus","LIB_osuus","MUUT_osuus",
#"NYT_osuus","PIR_osuus","PS_osuus","RKP_osuus","SDP_osuus",
#"SIN_osuus","SKE_osuus","SKP_osuus","STL_osuus","VAS_osuus",
#"VIHR_osuus","vaestotiheys")
#koodit <- koodit[koodit %in% tarkeimmat]

ix <- order(names(koodit))
nimet <- names(koodit)[ix]
koodit <- koodit[ix]


vaalipiirit <- seq(length(unique(ehdokkaat$vaalipiiri)))
names(vaalipiirit)<-unique(ehdokkaat$vaalipiiri)







