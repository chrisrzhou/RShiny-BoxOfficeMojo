shinyUI(fluidPage(
    tags$head(tags$link(rel="stylesheet", type="text/css", href="app.css")),
    
    titlePanel("Box Office Mojo Explorer"),
    
    sidebarLayout(
        sidebarPanel(
            p(class="text-small",
              a(href="../", "by chrisrzhou"),
              a(href="https://github.com/chrisrzhou/RShiny-BoxOfficeMojo", target="_blank", icon("github")), " | ",
              a(href="http://bl.ocks.org/chrisrzhou", target="_blank", icon("th")), " | ",
              a(href="https://www.linkedin.com/in/chrisrzhou", target="_blank", icon("linkedin"))),
            hr(),
            p(class="text-small", "Data visualizations on movie box office rankings based on various dimensions (e.g. studios, actors, etc).  All data is derived from the IMDB Box Office Mojo website: ",
              a(href="http://www.boxofficemojo.com/", target="_blank", "http://www.boxofficemojo.com/")),
            hr(),
            
            conditionalPanel(
                condition="input.tabset == 'Studios'",
                h3("Filters"),
                selectInput(inputId="studios_studio1", label="Highlight Studio 1:", choices=choices$studios, selected=choices$studios[[1]]),
                selectInput(inputId="studios_studio2", label="Highlight Studio 2:", choices=choices$studios, selected=choices$studios[[2]]),
                selectInput(inputId="studios_studio3", label="Highlight Studio 3:", choices=choices$studios, selected=choices$studios[[3]]),
                sliderInput(inputId="studios_years_min", label="Years", min=min(choices$studios_years), max=max(choices$studios_years), value=min(choices$studios_years), step=1, format="####"),
                sliderInput(inputId="studios_years_max", label="", min=min(choices$studios_years), max=max(choices$studios_years), value=max(choices$studios_years), step=1, format="####")
            ),
            
            conditionalPanel(
                condition="input.tabset == 'Oscars'",
                h3("Filters"),
                selectInput(inputId="oscars_metric", label="Select Metric", choices=choices$oscars_metric, selected=choices$oscars_metric[[1]]),
                sliderInput(inputId="oscars_years_min", label="Years", min=min(choices$oscars_years), max=max(choices$oscars_years), value=min(choices$oscars_years), step=1, format="####"),
                sliderInput(inputId="oscars_years_max", label="", min=min(choices$oscars_years), max=max(choices$oscars_years), value=max(choices$oscars_years), step=1, format="####")
            ),
            
            conditionalPanel(
                condition="input.tabset == 'Actors'",
                selectInput(inputId="actors_movies_metric", label="Select Movies Metric", choices=choices$movies_metric, selected=choices$movies_metric[[1]]),
                selectInput(inputId="actors_actor1", label="Highlight Actor 1:", choices=choices$actors, selected=choices$actors[[1]]),
                selectInput(inputId="actors_actor2", label="Highlight Actor 2:", choices=choices$actors, selected=choices$actors[[2]]),
                selectInput(inputId="actors_actor3", label="Highlight Actor 3:", choices=choices$actors, selected=choices$actors[[3]])
            ),
            
            conditionalPanel(
                condition="input.tabset == 'Directors'",
                selectInput(inputId="directors_movies_metric", label="Select Movies Metric", choices=choices$movies_metric, selected=choices$movies_metric[[1]]),
                selectInput(inputId="directors_director1", label="Highlight Director 1:", choices=choices$directors, selected=choices$directors[[1]]),
                selectInput(inputId="directors_director2", label="Highlight Director 2:", choices=choices$directors, selected=choices$directors[[2]]),
                selectInput(inputId="directors_director3", label="Highlight Director 3:", choices=choices$directors, selected=choices$directors[[3]])
            ),
            
            conditionalPanel(
                condition="input.tabset == 'Producers'",
                selectInput(inputId="producers_movies_metric", label="Select Movies Metric", choices=choices$movies_metric, selected=choices$movies_metric[[1]]),
                selectInput(inputId="producers_producer1", label="Highlight Producer 1:", choices=choices$producers, selected=choices$producers[[1]]),
                selectInput(inputId="producers_producer2", label="Highlight Producer 2:", choices=choices$producers, selected=choices$producers[[2]]),
                selectInput(inputId="producers_producer3", label="Highlight Producer 3:", choices=choices$producers, selected=choices$producers[[3]])
            ),
            
            width=3
        ),
        
        mainPanel(
            tabsetPanel(id="tabset",
                        tabPanel("Studios",
                                 h2("Top 10 Studios"),
                                 p(class="text-small", "This section displays visualizations of the Top 10 studio rankings by box office over time, as well as a facet plot of movies produced by studios over time.  You can use the highlight filters to the left to highlight specific studios listed in the legends of the plots shown below."),
                                 hr(),
                                 
                                 h3("Box Office Time Series"),
                                 p(class="text-small", "Visualization of Top 10 Rankings of studios by box office over the years."),
                                 p(class="text-small", "Observe how some recent studios have overtaken older studios over time."),
                                 plotOutput("studios_box_office_timeseries", height=400, width="auto"),
                                 hr(),
                                 
                                 h3("Movie Produced Facet Plot"),
                                 p(class="text-small", "Visualization of Top 10 Rankings of studios by movies produced over the years."),
                                 p(class="text-small", "Note that producing more movies does not correlate directly with box office success."),
                                 plotOutput("studios_movies_facet", height=400, width="auto"),
                                 hr(),
                                 
                                 h3("Data", downloadButton("studios_download", label="")),
                                 p(class="text-small", "Tabular searchable data display similar to that found in the original source ",
                                   a(href="http://www.boxofficemojo.com/studio/", target="_blank", "http://www.boxofficemojo.com/studio/")),
                                 p(class="text-small", "Box office units are in million dollars ($M)."),
                                 p(class="text-small", "You can download the data with the download button above."),
                                 dataTableOutput("studios_datatable"),
                                 hr()
                        ),
                        
                        tabPanel("Oscars",
                                 h2("Oscars"),
                                 p(class="text-small", "This section displays a timeline of Oscars winners.  Select a metric (box office, Oscar Nominations, Oscar Wins, Oscar Nominations-Win ratio) to view the results with more details."),
                                 hr(),
                                 
                                 h3("Timeline"),
                                 plotOutput("oscars_timeline", height=600, width="auto"),
                                 hr(),
                                 
                                 h3("Correlations"),
                                 p(class="text-small", "Visualizes the correlation matrix between 'Wins', 'Nominations', 'Win Percentage', and 'Box Office' sales of Oscars winners."),
                                 plotOutput("oscars_correlations", height=400, width="auto"),
                                 hr(),
                                 
                                 h3("Data", downloadButton("oscars_download", label="")),
                                 p(class="text-small", "Tabular searchable data display similar to that found in the original source ",
                                   a(href="http://www.boxofficemojo.com/oscar/", target="_blank", "http://www.boxofficemojo.com/oscar/")),
                                 p(class="text-small", "Box office units are in million dollars ($M)."),
                                 p(class="text-small", "You can download the data with the download button above."),
                                 dataTableOutput("oscars_datable"),
                                 hr()
                        ),
                        
                        tabPanel("Actors",
                                 h2("Top 50 Actors"),
                                 p(class="text-small", "This section displays visualizations of the top 50 actors rankings by box office and movies acted.  You can use the highlight filters to the left to highlight specific actors listed in the legends of the plots shown below."),
                                 hr(),
                                 
                                 h3("Rankings"),
                                 p(class="text-small", "Visualizes the rankings of actors.  Choose between total, average, or best movie box office earnings, or total movies acted"),
                                 p(class="text-small", "Box office units are in million dollars ($M)."),
                                 plotOutput("actors_boxoffice", height=600, width="auto"),
                                 hr(),
                                 
                                 h3("Data", downloadButton("actors_download", label="")),
                                 p(class="text-small", "Tabular searchable data display similar to that found in the original source ",
                                   a(href="http://www.boxofficemojo.com/people/?view=Actor&sort=sumgross&order=DESC&p=.htm", target="_blank", "http://www.boxofficemojo.com/people/?view=Actor&sort=sumgross&order=DESC&p=.htm")),
                                 p(class="text-small", "Box office units are in million dollars ($M)."),
                                 p(class="text-small", "You can download the data with the download button above."),
                                 dataTableOutput("actors_datatable"),
                                 hr()
                        ),
                        
                        tabPanel("Directors",
                                 h2("Top 50 Directors"),
                                 p(class="text-small", "This section displays visualizations of the top 50 directors rankings by box office and movies directred.  You can use the highlight filters to the left to highlight specific directors listed in the legends of the plots shown below."),
                                 hr(),
                                 
                                 h3("Rankings"),
                                 p(class="text-small", "Visualizes the rankings of directors.  Choose between total, average, or best movie box office earnings, or total movies directed"),
                                 p(class="text-small", "Box office units are in million dollars ($M)."),
                                 plotOutput("directors_boxoffice", height=600, width="auto"),
                                 hr(),
                                 
                                 h3("Data", downloadButton("directors_download", label="")),
                                 p(class="text-small", "Tabular searchable data display similar to that found in the original source ",
                                   a(href="http://www.boxofficemojo.com/people/?view=Director&sort=sumgross&order=DESC&p=.htm", target="_blank", "http://www.boxofficemojo.com/people/?view=Director&sort=sumgross&order=DESC&p=.htm")),
                                 p(class="text-small", "Box office units are in million dollars ($M)."),
                                 p(class="text-small", "You can download the data with the download button above."),
                                 dataTableOutput("directors_datatable"),
                                 hr()
                        ),
                        
                        tabPanel("Producers",
                                 h2("Top 50 Producers"),
                                 p(class="text-small", "This section displays visualizations of the top 50 producers rankings by box office and movies produced.  You can use the highlight filters to the left to highlight specific producers listed in the legends of the plots shown below."),
                                 hr(),
                                 
                                 h3("Rankings"),
                                 p(class="text-small", "Visualizes the rankings of producers.  Choose between total, average, or best movie box office earnings, or total movies produced."),
                                 p(class="text-small", "Box office units are in million dollars ($M)."),
                                 plotOutput("producers_boxoffice", height=600, width="auto"),
                                 hr(),
                                 
                                 h3("Data", downloadButton("producers_download", label="")),
                                 p(class="text-small", "Tabular searchable data display similar to that found in the original source ",
                                   a(href="http://www.boxofficemojo.com/people/?view=Producer&sort=sumgross&order=DESC&p=.htm", target="_blank", "http://www.boxofficemojo.com/people/?view=Producer&sort=sumgross&order=DESC&p=.htm")),
                                 p(class="text-small", "Box office units are in million dollars ($M)."),
                                 p(class="text-small", "You can download the data with the download button above."),
                                 dataTableOutput("producers_datatable"),
                                 hr()
                        )
            ),
            width=9
        )
    )
))