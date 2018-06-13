#### Presidentinvaalien äänet postinumeroille 

download.file("http://tulospalvelu.vaalit.fi/TPV-2018_1/tpv-2018_1_ehd_maa.csv.zip", 
              "tpv-2018_1_ehd_maa.csv.zip")

PV <- read_csv2("tpv-2018_1_ehd_maa.csv.zip", 
                col_names=FALSE, trim_ws=TRUE, 
                col_types=paste0(rep("c",46),
                                 collapse="")) %>% 
  mutate_if(is.character, funs(iconv(., from="latin1", to="utf-8"))) %>% 
  select(kunta=X3,
         aluejako=X4, 
         alue=X5, 
         alueen.nimi.FI=X16, 
         ehdokas=X19, 
         aania=X35, 
         aanten.osuus=X38) %>% 
  mutate(aania=as.numeric(aania), 
         aanten.osuus=as.numeric(aanten.osuus)/10) %>% 
  filter(!(aluejako %in% c("M","V"))) %>%
  mutate(aluejako=plyr::mapvalues(aluejako, c("K","A"), c("kunta", "äänestysalue")), 
         alue=ifelse(aluejako == "kunta", kunta, alue))

saveRDS(PV, file="presidentinvaalien.aanet.rds")

## Levitetään äänet postinumeroalueille
# N.postinumero = postinumeroalueille levitettyjen äänien summa

aanet.postinumero <- left_join(
  filter(PV, aluejako == "äänestysalue") %>% rename(aanestysalue.nro=alue), 
  map.pono.aanestysalue,
  by=c("kunta", "aanestysalue.nro")
) %>% 
  mutate(aania = aania*w.aanestysalue2pono) %>% 
  group_by(ehdokas, postinumero) %>% 
  summarise(aania=sum(aania, na.rm=TRUE)) %>% 
  ungroup %>% 
  group_by(postinumero) %>%
  mutate(N.postinumero=sum(aania, na.rm=TRUE), aanten.osuus=aania/N.postinumero) %>%
  ungroup

saveRDS(aanet.postinumero, file="PV.aanet.postinumero.rds")

# tarkistuksia: osoittautuu että n. 20 000 ääntä jää valtakunnallisesti pois (esim. ex-patit jne.)
# Paavo-aineiston postinumeroalueet ja kuntarajat eivät noudata toisiaan (kuten äänestysalueet) joten kun 
# vertaa kunnan äänimäärää ponoalueista saaduilla luvuilla 
# esim. Kaskisen kunnan ponoalueen kunta on Närpiö, Kaskinen katoaa kokonaan - Tammelaan tulee runsaasti ääniä Forssasta jne. 
# pääosin näyttää kuitenkin menevän hyvin. 
#left_join(filter(PV, aluejako=="kunta") %>% group_by(kuntano=alue) %>% summarise(aania.oikeat=sum(aania)),
#          left_join(aanet.postinumero, select(paavo.2018, postinumero, kuntano), by="postinumero") %>% group_by(kuntano) %>% summarise(aania.pono=sum(aania)) ,
#          by="kuntano") %>% mutate(diff=aania.oikeat-aania.pono) %>% View

