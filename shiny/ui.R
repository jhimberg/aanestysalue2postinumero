#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Define UI for application that draws a histogram
shinyUI(
  #Koetekstiä tähän#,
    navbarPage("Alueet",
               tabPanel("Talukko: Puolueet postinumeroittain",
                        # Show a plot of the generated distribution
                        DTOutput("puolueiden_aanet_postinumeroittain")),
               tabPanel("Kartta", 
                        sidebarLayout(
                          sidebarPanel(
                            fluidRow(
                                selectInput("muuttuja", "Muuttuja:", koodit),
                                textInput("alue_kartta", "Rajoita postinumero alkamaan:", value = "00")
                                ), width = 3
                            ),
                            mainPanel(
                                girafeOutput("postinumerokartta")
                                )
                          )
                        ),
               tabPanel("Graafi",
                        sidebarLayout(
                          sidebarPanel(
                            fluidRow(
                                textInput("alue_graafi", "Rajoita postinumero alkamaan:", value = "00"),
                                numericInput("vakiluku", "Asukkaita vähintään", value = 200),
                                selectInput("muuttuja_x", "X-akseli:", koodit, selected = "hr_mtu"),
                                selectInput("muuttuja_y", "Y-akseli:", koodit, selected = "KOK_osuus"),
                                selectInput("muuttuja_z", "Väri:", koodit, selected = "vaentiheys")),
                            width = 4),
                            mainPanel( fluidRow(
                                plotlyOutput("XYZ", height = "800px", width = "100%")
                            ))
                        )
                        )
               )
    )
