# Load libraries
library(XML)
library(dplyr)
options(warn=-1)  # turn off unneccessary NON-EXISTING NA warnings in the code from XML library


# =========================================================================
# function get_data_studio
#
# @description: calls scrape_table_studios to get studio data for all years from boxofficemojo
# @return: dataframe of studios and movies
# =========================================================================
get_data_studios <- function() {
    df <- data.frame(NULL)
    for (year in seq(2000, 2014, by=1)) {
        table <- scrape_table_studios(year)  # get data for each year
        df <- rbind_list(df, table)  # bind to final dataframe
    }
    df <- df %>%
        arrange(-YEAR, RANK)  # sort dataframe
    return(df)
}



# =========================================================================
# function get_data_oscars
#
# @description: get Oscar data for all years from boxofficemojo
# @return: dataframe of Oscar movies
# =========================================================================
get_data_oscars <- function() {
    url <- "http://www.boxofficemojo.com/oscar/?sort=studio&order=ASC&p=.htm"
    colNames <- c("ROW"="character",
                  "YEAR"="numeric",
                  "MOVIE"="character",
                  "STUDIO"="character",
                  "BOXOFFICE"="Currency",
                  "NOMINATIONS"="numeric",
                  "WINS"="numeric",
                  "RELEASEDATE"="character")
    
    # get data
    tables <- readHTMLTable(url, header=TRUE, stringsAsFactors=FALSE, colClasses=unname(colNames))
    df <- tables[[4]]  # data is in the 4th table
    
    # reshape data
    colnames(df) <- names(colNames)
    df <- df %>%
        select(-ROW) %>%
        mutate(BOXOFFICE = round(BOXOFFICE / 1000000, 2),
               WIN_PERCENTAGE = round(WINS / NOMINATIONS, 4)) %>%
        arrange(-YEAR)
    return(df)
}



# =========================================================================
# function get_data_actors
#
# @description: calls scrape_people to get top 50 actors data from boxofficemojo
# @return: dataframe of top 50 actors and movies
# =========================================================================
get_data_actors <- function() {
    df <- scrape_people("Actor")
    return(df)
}



# =========================================================================
# function get_data_directors
#
# @description: calls scrape_people to get top 50 directors data for all years from boxofficemojo
# @return: dataframe of directors and movies
# =========================================================================
get_data_directors <- function() {
    df <- scrape_people("Director")
    return(df)
}



# =========================================================================
# function get_data_producers
#
# @description: calls scrape_people to get top 50 producers data for all years from boxofficemojo
# @return: dataframe of producers and movies
# =========================================================================
get_data_producers <- function() {
    df <- scrape_people("Producer")
    return(df)
}



# =========================================================================
# helper function scrape_table_studios
#
# @description: scrapes the boxofficemojo website for studio data given a year input
# @param year: integer year value
# @return: dataframe of table
# =========================================================================
scrape_table_studios <- function(year) {
    url <- sprintf("http://www.boxofficemojo.com/studio/?view=majorstudio&view2=yearly&yr=%s&p=.htm", year)
    colNames <- c("RANK"="integer",
                  "STUDIO"="character",
                  "MARKETSHARE"="Percent",
                  "BOXOFFICE"="Currency",
                  "MOVIES_COUNT"="integer",
                  "MOVIES_YEAR"="integer")
    
    # get data
    tables <- readHTMLTable(url, header=TRUE, stringsAsFactors=FALSE, colClasses=unname(colNames))
    df <- tables[[4]]  # data is in the 4th table
    
    
    # reshape data
    colnames(df) <- names(colNames)
    df <- df %>%
        mutate(YEAR = year) %>%
        filter(RANK <= 10)  # limit data to top 10 studios
    return(df)
}



# =========================================================================
# helper function scrape_people
#
# @description: scrapes the boxofficemojo website for people data given a role input
# @param role: string value
# @return: dataframe of table
# =========================================================================
scrape_people <- function(role) {
    url <- sprintf("http://www.boxofficemojo.com/people/?view=%s&sort=sumgross&order=DESC&p=.htm", role)
    colNames <- c("RANK"="numeric",
                  "PERSON"="character",
                  "TOTAL_BO"="Currency",
                  "MOVIES_COUNT"="numeric",
                  "AVERAGE_BO"="Currency",
                  "BEST_PICTURE"="character",
                  "BEST_BO"="Currency")
    
    # get data
    tables <- readHTMLTable(url, header=TRUE, stringsAsFactors=FALSE, colClasses=unname(colNames))
    df <- tables[[4]]  # data is in the 4th table
    
    # reshape data
    colnames(df) <- names(colNames)
    return(df)
}