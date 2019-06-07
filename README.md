# aanestysalue2postinumero
Äänestysalueittainen data postinumeroalueille avoimen rakennustiedon avulla. Postinumeroittaisen vaalien tulosdatan visualisointia.

# Heuristiikka

R:llä toteutettu heuristiikka jolla voi arvioida äänten määriä postinumeroalueilla. Rakennustiedot löytyvät
https://www.avoindata.fi/data/en/dataset/rakennusten-osoitetiedot-koko-suomi, joissa rakennuksista on tiedossa sekä postinumero että äänestysalue. Rajoitutaan asuin- ja toimistorakennuksiin. Avoimessa datassa ei ole tämän tarkempaa tietoa rakennuksien laadusta tai koosta. Lasketaan kullekin Paavo-aineiston tilastointipostinumerolle osuudet sen rakennuksista eri äänestysalueilla. Näillä voi laskea postinumeroalueen äänimäärän äänestysalueiden painotettuna summana. 

Rakennustiedoissa on rakennuksia postinumeroilla, joita ei ole yleensä tilastokäytössä ja nämä on yksinkertaisesti jätetty pois. Jotkin äänestysalueet (esim. ulkosuomalaiset) jäävät tässä toki myös pois. 

Huom: Rakennustietokannan lähdedatatiedosto ja sen osoite vaihtuu ajoittain. Skripteissä on tällä hetkellä käytössä AWS S3 -kansioon kopioitu versio 19.2. 2019, jotta käytössä olisi eduskuntavaaleja 2019 oleva tieto. (Rakennusten osoitetiedot ja äänestysalue - koko Suomi by Väestörekisterikeskus is licensed under a Creative Commons Attribution 4.0 International License)

# Painotus

Painotus syntyy dataframeen `aanestysalue2postinumero` joka tallentuu myös tiedostoon `aanestysalue2postinumero.rds`

* kunta: kuntanumero
* aanestysalue.nro: kunta + aanestysalue.nro on äänestysalueen uniikki tunnus
* postinumero                  
* rakennukset.aanestysalue.pono: asuin/toimistorakennukset äänestysalueen (kunta+aanestysalue.nro ja postinumeron leikkauksessa
* rakennukset.aanestysalue: äänestysalueen (kunta+aanestysalue.nro) asuin/toimistorakennusten määrä 
* rakennukset.pono: postinumeroalueen asuin/toimistorakennusten määrä
* w.aanestysalue2pono: rakennukset.aanestysalue.pono / rakennukset.aanestysalue
* w.pono2aanestysalue: rakennukset.aanestysalue.pono / rakennukset.pono          

# Käyttöesimerkkejä

## Skriptinä 

`main.Rmd`: toteuttaa koko prosessin R-skripteillä ja hakee, paitsi rakennustiedot, myös 2019 eduskuntavaalien tulokset (https://tulospalvelu.vaalit.fi/EKV-2019), joita käytetään esimerkkinä. Aliskirptejä ovat
  - `data_rakennukset.R`: hakee ja käsittelee rakennustiedot 
  - `data_aanestysalue2postinumero.R`: muodostaa heuristiikassa tarvittavat painotukset äänestysalueelta postinumeroille ja päin vastoin
  - `data_EKV2019_aanet.R`: hakee käsittelee 2019 eduskuntavaalien tulokset

Ainakin seuraavat R-paketit tarvitaan: `plyr`, `dplyr`, `tidyr`, `readr`, `stringr`. `ggplot2`,`DT` ja `ggiraph` tarvitaan lisäksi `main.Rmd`:n visualisointi- ja taulukko-osuuksissa. 

## Shiny-sovellus

`global.R`, `server.R` ja `ui.R` ovat pieni esimerkki interaktiivista visualisoinneista Shinyllä. Tarvitaan myös paketit `shiny` ja `plotly`. *Jotta esimerkki toimii, on `main.Rmd` ajettava ensin!*

# Valmiiksi ladatut aineistot

Hakemistossa `map_and_names` on valmiina erilaisia kartta, demografia ja nimitietoja.
- `paavodata.rds` sisältää valmiiksi Tilastokeskuksen avoimen Paavo-aineiston vuosi 2018 ja 2019 käsiteltynä tibbleksi. Paavo-data ja Postinumeroaluerajat, Tilastokeskus. Aineisto on ladattu Tilastokeskuksen rajapintapalvelusta 23.4.2019 lisenssillä CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/deed.fi) https://tilastokeskus.fi/tup/rajapintapalvelut/paavo.html 
- `kuntano2kuntanimi.2018.rds`  sisältää kuntanumeroinnin ja kuntanimen mäppäyksen
- `statfi_reduced_ziparea_map_2019.rds` postimumeroaluekartta redusoituna. Aineisto on ladattu Tilastokeskuksen rajapintapalvelusta 23.4.2019 lisenssillä CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/deed.fi) ja redusoitu, ks. https://github.com/jhimberg/paavodata
- `EKV2019_puoluekoodaus.csv` niputtaa muutamia yhteislistoja joilla on eri vaalipiireissä eri nimi, esim. Liike NYT 
