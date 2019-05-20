#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

source("../map_and_names/paavo_functions.R")

shinyServer(function(input, output, session) {

    output$puolueiden_aanet_postinumeroittain <- renderDT({
        DT::datatable(puolueiden_aanet_postinumeroittain %>% 
                          mutate_at(., vars(EOP:VIHR), .funs = ~round((. / KAIKKI), 5)) %>% 
                          mutate_at(., vars(KAIKKI), round) %>% 
                          left_join(postinumerot, by="postinumero") %>%
                          mutate(kunta = kuntano2nimi(kuntano)) %>%  
                          select(-kuntano) %>%
                          order_columns(first_names = c("kunta", "postinumero", "nimi")),
                      colnames = c('Ääniä' = 'KAIKKI'),
                      caption = "Karkea arvio äänistä puolueittain ja postinumeroalueittain",
                      selection = "none",
                      filter = "none",
                      rownames = FALSE) %>%
            formatPercentage(puoluekoodit, 1) %>% 
            formatStyle(puoluekoodit,
                background = styleColorBar(c(0,1), 'lightblue'),
                backgroundSize = '80% 70%',
                backgroundRepeat = 'no-repeat',
                backgroundPosition = 'center'
            )
    },
    server=TRUE)
    
    kartta <- function(muuttuja, alue) {
        df <-   select(aanet_ja_paavodata,
                       postinumero, 
                       nimi,
                       muuttuja_ = muuttuja,
                       kuntano) %>% 
            filter(grepl(alue, postinumero))
        
        df <- transmute(df, 
                        pono = postinumero,
                        muuttuja_ = muuttuja_,
                        tooltip = paste0(pono, " ", 
                                         kuntano2nimi(kuntano), 
                                         "\n", 
                                         nimi, 
                                         "\n", 
                                         muuttuja_)
                        ) 
        
        map_fi_zipcode_interactive(df,
                                   title_label = plyr::mapvalues(muuttuja, paavo$vars$koodi, paavo$vars$nimi, warn_missing = FALSE),
                                   map = "2019",
                                   colorscale = scale_fill_distiller, 
                                   type = "seq", 
                                   palette = "YlOrRd",
                                   direction = 1) %>% 
            girafe(ggobj = .) %>% 
            girafe_options(x=., opts_zoom(min = .5, max = 5), opts_sizing(rescale = TRUE, width = 1))
    }
        
    
    output$postinumerokartta_y <- renderGirafe({ 
        kartta(input$muuttuja_y, alue = paste0("^", input$alue_kartta))
        })
    
    output$postinumerokartta_x <- renderGirafe({ 
        kartta(input$muuttuja_x, alue = paste0("^", input$alue_kartta))
    })
    
    output$postinumerokartta <- renderGirafe({ 
      kartta(input$muuttuja, alue = paste0("^", input$alue_kartta))
    })
    
      output$XYZ <- renderPlotly({
        print(input$vakiluku)
        p <- ggplot(data = aanet_ja_paavodata %>% 
                      filter(grepl(paste0("^",input$alue_graafi), postinumero) &
                               he_vakiy >= as.numeric(input$vakiluku)) %>%  
                      mutate(Alue = paste0(postinumero, 
                                              " ", 
                                              nimi, 
                                              "\n",
                                              kuntano2nimi(kuntano))), 
                    mapping = aes_string(x = input$muuttuja_x, 
                                         y = input$muuttuja_y, 
                                         colour = input$muuttuja_z,
                                         size = "he_vakiy",
                                         weight = "he_vakiy",
                                         label = "Alue")) + 
          geom_smooth(method = "gam", formula = y ~ s(x, bs = "cs", k=4), fullrange=FALSE, size=.5)  + 
          geom_point(na.rm = TRUE) + 
          theme_minimal() + 
          scale_color_distiller(palette = "Spectral") +
          xlab(plyr::mapvalues(input$muuttuja_x, koodit, nimet, warn_missing = FALSE)) +
          ylab(plyr::mapvalues(input$muuttuja_y, koodit, nimet, warn_missing = FALSE)) 
          
        ggplotly(p, tooltip=c("label", "x", "y", "colour"))
        
      })
      
})
