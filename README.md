# aanestysalue2postinumero
Äänestysalueittainen data postinumeroalueille avoimen rakennustiedon avulla.

# Heuristiikka

R:llä toteutettu heuristiikka jolla voi arvioida äänten määriä postinumeroalueilla. Haetaan rakennustiedot https://www.avoindata.fi/data/en/dataset/rakennusten-osoitetiedot-koko-suomi joissa rakennuksista on tiedossa sekä postinumero että äänestysalue. Rajoitutaan asuin- ja toimistorakennuksiin. Avoimessa datassa ei ole tämän tarkempaa tietoa rakennuksien laadusta tai koosta. Lasketaan kullekin Paavo-aineiston tilastointipostinumerolle osuudet sen rakennuksista eri äänestysalueilla. Näillä voi laskea postinumeroalueen äänimäärän äänestysalueiden painotettuna summana. 

Rakennustiedoissa on rakennuksia postinumeroilla joita ei ole yleensä tilastokäytössä ja nämä on yksinkertaisesti jätetty pois. Jotkin äänestysalueet (esim. ulkosuomalaiset) jäävät tässä toki myös pois. 

Huom: Rakennustietokannan lähdedata vaihtuu: skriptin avoimen datan hakuosoitetta täytyy muuttaa tarvittaessa

# Käyttö

Käyttö: `PV2018.demo.R`: toteuttaa koko prosessin ajamalla R-skriptejä ja hakee paitsi rakennustiedot myös 2018 presidentinvaalien tulokset (http://tulospalvelu.vaalit.fi/TPV-2018_1/en/ladattavat_tiedostot.html), joita käytetään esimerkkinä. 

Ainakin seuraavat R-paketit tarvitaan: `plyr`, `dplyr`, `tidyr`, `readr`, `ggplot2`

# Painotus

Painotus on syntyy dataframeen `map.pono.aanestysalue`joka tallentuu myös tiedostoon `map.pono.aanestysalue.rds`
(`map.pono.aanestysalue.csv.gz` sisältää valmiin esimerkin tuloksesta.)

* kunta: kuntanumero
* aanestysalue.nro: kunta + aanestysalue.nro on äänestysalueen uniikki tunnus
* postinumero                  
* rakennukset.aanestysalue.pono: asuin/toimistorakennukset äänestysalueen (kunta+aanestysalue.nro ja postinumeron leikkauksessa
* rakennukset.aanestysalue: äänestysalueen (kunta+aanestysalue.nro) asuin/toimistorakennusten määrä 
* rakennukset.pono: postinumeroalueen asuin/toimistorakennusten määrä
* w.aanestysalue2pono: rakennukset.aanestysalue.pono / rakennukset.aanestysalue
* w.pono2aanestysalue: rakennukset.aanestysalue.pono / rakennukset.pono          

# Valmiiksi ladatut aineistot

`paavo2018.rds` sisältää valmiiksi Tilastokeskuksen avoimen Paavo-aineiston: https://tilastokeskus.fi/tup/rajapintapalvelut/paavo.html. 

`kuntano2kuntanimi.2018.rds` sisältää kuntanumeroinnin ja `tilastointipostinumerot.2018.rds` Paavo-aineistossa käytössä olevat postinumerot, joilla olevia rakennuksia käytetään. 
