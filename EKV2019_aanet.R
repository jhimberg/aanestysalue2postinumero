#### Eduskuntavaalien äänet postinumeroille 

print("Hae eduskuntavaalien tulokset...")

download.file("https://tulospalvelu.vaalit.fi/EKV-2019/ekv-2019_ehd_maa.csv.zip", 
              "data/ekv.2019.csv.zip")

# Ks. https://tulospalvelu.vaalit.fi/EKV-2019/ohje/Vaalien_tulostiedostojen_kuvaus_EKV-EPV-2019_FI.pdf

EKV <-
  read_csv2(
    "data/ekv.2019.csv.zip",
    col_names = FALSE,
    trim_ws = TRUE,
    col_types = paste0(rep("c", 46), collapse = "")
  ) %>%
  mutate_if(is.character, funs(iconv(., from = "latin1", to = "utf-8"))) %>%
  transmute(
    vaalipiiri = X2, 
    kunta = X3,
    aluejako = X4,
    alue = X5,
    puolue_numero = X9,
    puolue_lyhenne_alkuperainen = X12,
    alueen_nimi_FI = X16,
    ehdokasnumero = X15,
    etunimi = X18,
    sukunimi = X19,
    sukupuoli = plyr::revalue(X20, c("1"="mies", "2"="nainen")),
    ika = as.integer(X21),
    kieli = plyr::revalue(X26, c("FI"="suomi", "SV"="ruotsi", "SE"="saame", "98"="muu", "99"="muu")),
    kieli = ifelse(kieli=="","muu", kieli),
    kotikunta_numero = X23,
    kotikunta_nimi = X24,
    istuva_kansanedustaja = plyr::mapvalues(X28,c("1",NA),c(T,F)),
    kunnanvaltuutettu = plyr::mapvalues(X29,c("1",NA),c(T,F)),
    aanet_ennakko = as.integer(X33),
    aanet_vaalipaiva = as.integer(X34),
    aanet_yhteensa = as.integer(X35),
    aanten_osuus = as.integer(X38), # Prosenttia alueen hyväksytyistä äänistä.
    valittu = plyr::mapvalues(X39, c("1","2","3","4"), c(T,F,F,F))
  ) %>%
  filter(!(aluejako %in% c("M", "V"))) %>%
  mutate(
    aluejako = plyr::mapvalues(aluejako, c("K", "A"), c("kunta", "äänestysalue")),
    alue = ifelse(aluejako == "kunta", kunta, alue)
  )

# puolueiden lyhenteiden yhdistämistä: tiedot haettu ja yhdistelty vaalipalvelusta
# esim. Nyt-liikkeellä tai Reformilistalla on 2019 eri vaalipiireissä eri lyhenne!

puoluekoodaus<-readr::read_csv2("map_and_names/EKV2019_puoluekoodaus.csv") %>% 
  group_by(lyhenne, koodi) %>% 
  slice(1) 

EKV <- left_join(EKV, 
                 select(puoluekoodaus, lyhenne, puolue = koodi), 
                 by=c("puolue_lyhenne_alkuperainen" = "lyhenne"))

saveRDS(EKV, file = "data/EKV2019_ehdokkaat.rds")

