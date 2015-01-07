shinyServer(function(input, output) {
    
    # =========================================================================
    # Reactive resources
    # =========================================================================
    resource.studios <- reactive({
        df <- dataframes$studios %>%  # subset/filter df_base based on user selections
            filter(YEAR >= input$studios_years_min,
                   YEAR <= input$studios_years_max)
        return(df)
    })
    
    resource.oscars <- reactive({
        df <- dataframes$oscars %>%  # subset/filter df_base based on user selections
            filter(YEAR >= input$oscars_years_min,
                   YEAR <= input$oscars_years_max)
        return(df)
    })
    
    resource.actors <- reactive({
        df <- dataframes$actors
        return(df)
    })
    
    resource.directors <- reactive({
        df <- dataframes$directors
        return(df)
    })
    
    resource.producers <- reactive({
        df <- dataframes$producers
        return(df)
    })
    
    
    
    # =========================================================================
    # Server outputs : Datatables
    # =========================================================================
    output$studios_datatable <- renderDataTable({
        return(resource.studios())
    }, options=list(pageLength=10, autoWidth=FALSE))
    
    output$oscars_datable <- renderDataTable({
        return(resource.oscars())
    }, options=list(pageLength=10, autoWidth=FALSE))
    
    output$actors_datatable <- renderDataTable({
        return(resource.actors())
    }, options=list(pageLength=10, autoWidth=FALSE))
    
    output$directors_datatable <- renderDataTable({
        return(resource.directors())
    }, options=list(pageLength=10, autoWidth=FALSE))
    
    output$producers_datatable <- renderDataTable({
        return(resource.producers())
    }, options=list(pageLength=10, autoWidth=FALSE))
    
    
    
    
    # =========================================================================
    # Server outputs : Plots
    # =========================================================================
    output$studios_box_office_timeseries <- renderPlot({
        # get data from dataframe
        df <- resource.studios() %>%
            arrange(-YEAR, RANK) %>%  # order by rank
            mutate(STUDIO = factor(STUDIO, levels=unique(STUDIO)))  # convert to factor for fixing plot sort ordering
        
        # Build colormap
        studios <- unique(df$STUDIO)  # get list of unique studios in filtered dataframe
        colormap <- helper.colormapper(studios, c(input$studios_studio1, input$studios_studio2, input$studios_studio3))
        
        # plotting
        plot <- ggplot(df, aes(x=YEAR, y=BOXOFFICE, group=STUDIO, color=STUDIO)) + 
            geom_point(size=3) + 
            geom_line(size=1.2, alpha=0.5) + 
            geom_text(data=subset(df, YEAR == input$studios_years_max),  # hack to label only at end of visualization
                      aes(x=YEAR, y=BOXOFFICE, label=STUDIO),
                      size=5,
                      hjust=1) + 
            scale_color_manual(values=colormap) + 
            scale_x_continuous(breaks=seq(min(df$YEAR), max(df$YEAR), by=1)) + 
            scale_y_continuous(labels=dollar) + 
            labs(title="Annual Top 10 Studio Rankings by Box Office",
                 x="YEAR",
                 y="BOX OFFICE ($M)") + 
            theme(panel.background = element_blank())
        return(plot)
    })
    
    
    output$studios_movies_facet <- renderPlot({
        # get data from dataframe
        df <- resource.studios() %>%
            arrange(-YEAR, -MOVIES_COUNT) %>%  # order by most movies_count
            mutate(STUDIO = factor(STUDIO, levels=unique(STUDIO)))  # convert to factor for fixing plot sort ordering
        
        # Build colormap
        studios <- unique(df$STUDIO)  # get list of unique studios in filtered dataframe
        colormap <- helper.colormapper(studios, c(input$studios_studio1, input$studios_studio2, input$studios_studio3))
        
        # plotting
        plot <- ggplot(df, aes(x=YEAR, y=MOVIES_COUNT, group=STUDIO, fill=STUDIO)) + 
            facet_wrap(~ STUDIO, nrow=4) + 
            geom_bar(stat="identity") + 
            scale_fill_manual(values=colormap) + 
            scale_x_continuous(breaks=as.integer(seq(min(df$YEAR), max(df$YEAR), length.out=3))) + 
            labs(title="Annual Top 10 Studio Rankings by Movies Produced",
                 x="YEAR",
                 y="MOVIES PRODUCED") + 
            theme(panel.background = element_blank(),
                  panel.margin = unit(2, "lines"))
        return(plot)
    })
    
    
    output$oscars_timeline <- renderPlot({
        # get data from dataframe
        metric <- input$oscars_metric
        df <- resource.oscars() %>%
            arrange(YEAR) %>%  # order by year
            mutate(MOVIE = sprintf("%s (%s)", MOVIE, YEAR),
                   MOVIE = factor(MOVIE, levels=unique(MOVIE)))  # concatenate movie and year for plot display
        # convert to factor for fixing plot sort ordering
        
        # plotting
        mean_value = round(mean(df[, metric]), 2)
        plot <- ggplot(df, aes_string(x="MOVIE", y=metric, fill="STUDIO")) + 
            geom_bar(stat="identity", alpha=0.5) + 
            geom_text(aes_string(label=metric),
                      size=3.5, hjust=0, fontface="italic") + 
            geom_hline(yintercept=mean_value, linetype="longdash", color="steelblue") + 
            scale_fill_manual(values=D3COLORMAP20) + 
            scale_y_continuous(breaks=pretty_breaks(5)) + 
            labs(title=sprintf("Annual Oscar Winners\n(by %s, mean: %s)", metric, mean_value),
                 x="OSCARS",
                 y=metric) + 
            theme(panel.background = element_blank())
        plot <- plot + coord_flip()  # flip plot coordinates
        return(plot)
    })
    
    
    output$oscars_correlations <- renderPlot({
        # get data from dataframe
        df <- resource.oscars() %>%  # select numeric columns for generating correlation matrix using reshape2's melt function
            select(BOXOFFICE, NOMINATIONS, WINS, WIN_PERCENTAGE)
        
        # plotting
        plot <- ggplot(melt(cor(df)), aes(x=Var1, y=Var2, fill=value)) + 
            geom_tile() + 
            geom_text(aes(label=formatC(value, digits=2, format="f")), size=4) + 
            scale_fill_gradient(low="white", high="steelblue") + 
            labs(title="Oscars Correlation Matrix", x="", y="")
        return(plot)
    })
    
    
    output$actors_boxoffice <- renderPlot({
        # get data from dataframe
        metric <- input$actors_movies_metric
        df <- resource.actors() %>%
            arrange_(metric) %>%  # dplyr arrange_ is arrange but allowing passing strings, in our case we pass a dynamic reactive variable
            mutate(PERSON = factor(PERSON, levels=unique(PERSON)))  # convert to factor for fixing plot sort ordering
        
        # Build colormap
        actors <- unique(df$PERSON)  # get list of unique actors in filtered dataframe
        colormap <- helper.colormapper(actors, c(input$actors_actor1, input$actors_actor2, input$actors_actor3))
        
        # plotting
        mean_value = round(mean(df[, metric]), 2)
        plot <- ggplot(df, aes_string(x="PERSON", y=metric, fill="PERSON")) + 
            geom_bar(stat="identity", alpha=0.75) + 
            geom_text(aes_string(label=metric),
                      size=3.5, hjust=0, fontface="italic") + 
            geom_hline(yintercept=mean_value, linetype="longdash", color="steelblue") + 
            scale_fill_manual(values=colormap) + 
            scale_y_continuous(breaks=pretty_breaks(5)) + 
            labs(title=sprintf("Top 50 Actors\n(by %s, mean: %s)", metric, mean_value),
                 x="ACTORS",
                 y=sprintf("%s", metric)) + 
            theme(panel.background = element_blank(),
                  legend.position = "none")
        # conditional best movie name layer
        if(metric == "BEST_BO") {
            plot <- plot + geom_text(aes(y=0, label=BEST_PICTURE), size=3.5, color="gray40", hjust=0, fontface="italic")
        }
        plot <- plot + coord_flip()  # flip plot coordinates
        return(plot)
    })
    
    
    output$directors_boxoffice <- renderPlot({
        # get data from dataframe
        metric <- input$directors_movies_metric
        df <- resource.directors() %>%
            arrange_(metric) %>%  # dplyr arrange_ is arrange but allowing passing strings, in our case we pass a dynamic reactive variable
            mutate(PERSON = factor(PERSON, levels=unique(PERSON)))  # convert to fdirector for fixing plot sort ordering
        
        # Build colormap
        directors <- unique(df$PERSON)  # get list of unique directors in filtered dataframe
        colormap <- helper.colormapper(directors, c(input$directors_director1, input$directors_director2, input$directors_director3))
        
        # plotting
        mean_value = round(mean(df[, metric]), 2)
        plot <- ggplot(df, aes_string(x="PERSON", y=metric, fill="PERSON")) + 
            geom_bar(stat="identity", alpha=0.75) + 
            geom_text(aes_string(label=metric),
                      size=3.5, hjust=0, fontface="italic") + 
            geom_hline(yintercept=mean_value, linetype="longdash", color="steelblue") + 
            scale_fill_manual(values=colormap) + 
            scale_y_continuous(breaks=pretty_breaks(5)) + 
            labs(title=sprintf("Top 50 Directors\n(by %s, mean: %s)", metric, mean_value),
                 x="DIRECTORS",
                 y=sprintf("%s", metric)) + 
            theme(panel.background = element_blank(),
                  legend.position = "none")
        # conditional best movie name layer
        if(metric == "BEST_BO") {
            plot <- plot + geom_text(aes(y=0, label=BEST_PICTURE), size=3.5, color="gray40", hjust=0, fontface="italic")
        }
        plot <- plot + coord_flip()  # flip plot coordinates
        return(plot)
    })
    
    
    output$producers_boxoffice <- renderPlot({
        # get data from dataframe
        metric <- input$producers_movies_metric
        df <- resource.producers() %>%
            arrange_(metric) %>%  # dplyr arrange_ is arrange but allowing passing strings, in our case we pass a dynamic reactive variable
            mutate(PERSON = factor(PERSON, levels=unique(PERSON)))  # convert to fproducer for fixing plot sort ordering
        
        # Build colormap
        producers <- unique(df$PERSON)  # get list of unique producers in filtered dataframe
        colormap <- helper.colormapper(producers, c(input$producers_producer1, input$producers_producer2, input$producers_producer3))
        
        # plotting
        mean_value = round(mean(df[, metric]), 2)
        plot <- ggplot(df, aes_string(x="PERSON", y=metric, fill="PERSON")) + 
            geom_bar(stat="identity", alpha=0.75) + 
            geom_text(aes_string(label=metric),
                      size=3.5, hjust=0, fontface="italic") + 
            geom_hline(yintercept=mean_value, linetype="longdash", color="steelblue") + 
            scale_fill_manual(values=colormap) + 
            scale_y_continuous(breaks=pretty_breaks(5)) + 
            labs(title=sprintf("Top 50 Producers\n(by %s, mean: %s)", metric, mean_value),
                 x="PRODUCERS",
                 y=sprintf("%s", metric)) + 
            theme(panel.background = element_blank(),
                  legend.position = "none")
        # conditional best movie name layer
        if(metric == "BEST_BO") {
            plot <- plot + geom_text(aes(y=0, label=BEST_PICTURE), size=3.5, color="gray40", hjust=0, fontface="italic")
        }
        plot <- plot + coord_flip()  # flip plot coordinates
        return(plot)
    })
    
    
    
    # =========================================================================
    # Server outputs : Downloads
    # =========================================================================
    output$studios_download <- downloadHandler(
        filename <- function() {
            sprintf("studios_%s.csv", Sys.Date())
        },
        content <- function(filename) {
            df <- resource.studios()
            write.csv(df, file=filename, row.names=FALSE)
        }
    )
    
    output$oscars_download <- downloadHandler(
        filename <- function() {
            sprintf("oscars_%s.csv", Sys.Date())
        },
        content <- function(filename) {
            df <- resource.oscars()
            write.csv(df, file=filename, row.names=FALSE)
        }
    )
    
    output$actors_download <- downloadHandler(
        filename <- function() {
            sprintf("actors_%s.csv", Sys.Date())
        },
        content <- function(filename) {
            df <- resource.actors()
            write.csv(df, file=filename, row.names=FALSE)
        }
    )
    
    output$directors_download <- downloadHandler(
        filename <- function() {
            sprintf("directors_%s.csv", Sys.Date())
        },
        content <- function(filename) {
            df <- resource.directors()
            write.csv(df, file=filename, row.names=FALSE)
        }
    )
    
    output$producers_download <- downloadHandler(
        filename <- function() {
            sprintf("producers_%s.csv", Sys.Date())
        },
        content <- function(filename) {
            df <- resource.producers()
            write.csv(df, file=filename, row.names=FALSE)
        }
    )
})