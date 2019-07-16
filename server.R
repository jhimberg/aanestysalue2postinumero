
source("./map_and_names/paavo_functions.R")

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
    
    puoluekartta <- function(muuttuja, alue) {
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
                                   title_label = plyr::mapvalues(muuttuja, koodit, nimet, warn_missing = FALSE),
                                   map = "2019",
                                   colorscale = scale_fill_distiller, 
                                   type = "seq", 
                                   palette = "Blues",
                                   #colorscale = scale_fill_viridis_c,
                                   #option = "D",
                                   direction = 1) %>% 
            girafe(ggobj = .) %>% 
            girafe_options(x=., opts_zoom(min = .5, max = 5), opts_sizing(rescale = TRUE, width = 1))
    }
      
    output$puoluekartta <- renderGirafe({ 
      puoluekartta(input$muuttuja, alue = paste0("^", input$alue_puoluekartta))
    })
    
    output$ehdokas <- renderUI({
      ehdokkaat <- transmute(filter(ehdokkaat, 
                                    vaalipiiri == names(which(vaalipiirit == as.numeric(input$vaalipiiri)))), 
                             ehdokasnumero,
                             txt = paste0(sukunimi, ", ", etunimi, " (", ehdokasnumero, ")"))
        labels <- ehdokkaat$ehdokasnumero
        names(labels)<-ehdokkaat$txt
      selectInput("ehdokas", "Ehdokas:", labels)

    })
        
      xscale <- reactive({if (input$xscale == "lineaarinen") scale_x_continuous() else scale_x_log10()})
      yscale <- reactive({if (input$yscale == "lineaarinen") scale_y_continuous() else scale_y_log10()}) 
    
      output$XYZ <- plotly::renderPlotly({
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
          geom_smooth(method = "gam", 
                      #formula = y ~ s(x, bs = "cs", k = 3),
                      formula = y ~ x, 
                      fullrange=FALSE, 
                      size= .25, 
                      color="gray",
                      linetype=NA)  + 
          geom_point(na.rm = TRUE) + 
          theme_minimal() + 
          xscale() + 
          yscale() + 
          scale_color_viridis_c(direction = -1, alpha=.7, option="C") +
          xlab(plyr::mapvalues(input$muuttuja_x, koodit, nimet, warn_missing = FALSE)) +
          ylab(plyr::mapvalues(input$muuttuja_y, koodit, nimet, warn_missing = FALSE)) 
          
        plotly::ggplotly(p, tooltip=c("label", "x", "y", "colour"))
        
      })
      
})
