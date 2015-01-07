# =========================================================================
# Load libraries and scripts
# =========================================================================
library(shiny)
library(ggplot2)
library(scales)
library(grid)
library(reshape2)
source("./parser.R")


# =========================================================================
# GET parsed data from parser.R script into dataframes
# =========================================================================
dataframes <- list(
    studios = as.data.frame(get_data_studios()),
    oscars = as.data.frame(get_data_oscars()),
    actors = as.data.frame(get_data_actors()),
    directors = as.data.frame(get_data_directors()),
    producers = as.data.frame(get_data_producers())
)


# =========================================================================
# ui.R variables
# =========================================================================
choices <- list(
    studios = unique(dataframes$studios$STUDIO),
    studios_years = unique(dataframes$studios$YEAR),
    actors = unique(dataframes$actors$PERSON),
    oscars_years = unique(dataframes$oscars$YEAR),
    directors = unique(dataframes$directors$PERSON),
    producers = unique(dataframes$producers$PERSON),
    oscars_metric = c("BOXOFFICE", "NOMINATIONS", "WINS", "WIN_PERCENTAGE"),
    movies_metric = c("BEST_BO", "TOTAL_BO", "AVERAGE_BO", "MOVIES_COUNT")
)


# =========================================================================
# server.R variables and functions
# =========================================================================
COLORMAP <- c("#1f77b4", "#ff7f0e", "#2ca02c")
D3COLORMAP20 <- c("#1f77b4", "#aec7e8", "#ff7f0e", "#ffbb78", "#2ca02c",
                  "#98df8a", "#d62728", "#ff9896", "#9467bd", "#c5b0d5",
                  "#8c564b", "#c49c94", "#e377c2", "#f7b6d2", "#7f7f7f",
                  "#c7c7c7", "#bcbd22", "#dbdb8d", "#17becf", "#9edae5")

# Helper function helper.colormapper
#
# @param array: an array to be assigned colors based on its index values
# @param conditions: condition array to determine which color is assigned (these are basically shiny input UI selections)
# @return: returns a named vector mapping colors to the original array.
helper.colormapper <- function(array, conditions) {
    colors <- sapply(array, function(element) {
        color <- "gray80"
        for (i in seq_along(conditions)) {
            if (element == conditions[[i]]) color <- COLORMAP[[i]]
        }
        return(color)
    })
    colormap <- setNames(colors, array)
    return(colormap)
}

helper.plotPeople <- function() {
    
}