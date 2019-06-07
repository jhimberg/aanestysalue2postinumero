


paneeliteksti <- function()
  wellPanel(
    tags$a(href = "https://github.com/jhimberg/aanestysalue2postinumero/blob/master/README.md",
           "Laskentatavasta ja datalähteistä tarkemmin täällä."),
    "Puolueiden äänimäärät ja -osuudet estimoitu vuoden 2019 eduskuntavaalituloksesta. ",
    tags$a(
      "Paavo-data Tilastokeskuksen rajapintapalvelusta 23.4.2019 lisenssillä CC BY 4.0",
      href = "https://tilastokeskus.fi/tup/rajapintapalvelut/paavo.html"
    )
  )

shinyUI(
  navbarPage(
    "Eduskuntavaalit 2019 ja Paavo-data",
    tabPanel(
      "Graafi",
      h2("Postinumeroalueittaisen datan visualisointia"),
      paneeliteksti(),
      sidebarLayout(
        sidebarPanel(
          fluidRow(
            textInput("alue_graafi", "Rajoita postinumero alkamaan:", value = "00"),
            numericInput("vakiluku", "Asukkaita vähintään", value = 200),
            selectInput("muuttuja_x", "X-akseli:", koodit, selected = "hr_mtu"),
            radioButtons(
              "xscale",
              NULL,
              choices = c("lineaarinen", "log10"),
              inline = TRUE
            ),
            selectInput("muuttuja_y", "Y-akseli:", koodit, selected = "KOK_osuus"),
            radioButtons(
              "yscale",
              NULL,
              choices = c("lineaarinen", "log10"),
              inline = TRUE
            ),
            selectInput("muuttuja_z", "Väri:", koodit, selected = "vaestotiheys")
          ),
          wellPanel(tags$em(
            "Huom: Osuudet välillä 0...1, jossa 1 vastaa 100%"
          )),
          width = 4
        ),
        mainPanel(fluidRow(
          plotly::plotlyOutput("XYZ", height = "700px", width = "100%")
        ))
      )
    ),
    tabPanel(
      "Puoluekartta",
      h2("Postinumeroalueittaisen datan visualisointia"),
      paneeliteksti(),
      sidebarLayout(sidebarPanel(
        fluidRow(
          textInput("alue_puoluekartta", "Rajoita postinumero alkamaan:", value = "00"),
          selectInput("muuttuja", "Muuttuja:", koodit),
          wellPanel(tags$em(
            "Huom: Osuudet välillä 0...1, jossa 1 vastaa 100%"
          ))
        ), width = 3
      ),
      mainPanel(
        girafeOutput("puoluekartta", height = "700px")
      ))
    ),
    tabPanel(
      "Talukko: Puolueet postinumeroittain",
      h2("Postinumeroalueittaisen datan visualisointia"),
      paneeliteksti(),
      # Show a plot of the generated distribution
      DTOutput("puolueiden_aanet_postinumeroittain")
    )
)
)
