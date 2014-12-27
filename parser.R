# Load libraries
library(XML)
library(dplyr)



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
    tables <- readHTMLTable(url, header=TRUE, stringsAsFactors=FALSE)
    df <- tables[[4]]  # data is in the 4th table
    
    # reshape data
    colnames(df) <- c("ROW", "YEAR", "MOVIE", "STUDIO", "BOXOFFICE", "NOMINATIONS", "WINS", "RELEASEDATE")  # rename columns
    df <- df %>%
        select(YEAR, MOVIE, STUDIO, BOXOFFICE, NOMINATIONS, WINS, RELEASEDATE) %>%
        mutate(BOXOFFICE = round(sapply(BOXOFFICE, convert_gross_sales) / 1000000, 1),
               YEAR = as.integer(YEAR),
               NOMINATIONS = as.numeric(NOMINATIONS),
               WINS = as.numeric(WINS),
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
    tables <- readHTMLTable(url, header=TRUE, stringsAsFactors=FALSE)
    table <- tables[[4]]  # data is in the 4th table
    
    # reshape data
    colnames(table) <- c("RANK", "STUDIO", "MARKETSHARE", "BOXOFFICE", "MOVIES_COUNT", "MOVIES_YEAR")  # rename columns
    table <- table %>%
        select(RANK, STUDIO, BOXOFFICE, MOVIES_COUNT) %>%
        mutate(BOXOFFICE = sapply(BOXOFFICE, convert_gross_sales),
               RANK = as.integer(RANK),
               MARKETSHARE = BOXOFFICE / sum(BOXOFFICE),
               MOVIES_COUNT = as.integer(MOVIES_COUNT),
               YEAR = year) %>%
        filter(RANK <= 10)  # limit data to top 10 studios
    return(table)
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
    tables <- readHTMLTable(url, header=TRUE, stringsAsFactors=FALSE)
    df <- tables[[4]]  # data is in the 4th table
    
    # reshape data
    colnames(df) <- c("RANK", "PERSON", "TOTAL_BO", "MOVIES_COUNT", "AVERAGE_BO", "BEST_PICTURE", "BEST_BO")  # rename columns
    df <- df %>%
        select(RANK, PERSON, TOTAL_BO, MOVIES_COUNT, AVERAGE_BO, BEST_PICTURE, BEST_BO) %>%
        mutate(RANK = as.integer(RANK),
               TOTAL_BO = sapply(TOTAL_BO, convert_gross_sales),
               MOVIES_COUNT = as.integer(MOVIES_COUNT),
               AVERAGE_BO = sapply(AVERAGE_BO, convert_gross_sales),
               BEST_BO = sapply(BEST_BO, convert_gross_sales))
    return(df)
}



# =========================================================================
# helper function convert_gross_sales
#
# @description: Converts a string input and returns float value in units of million.
# @param value: string input
# @return: float value in units of million
# =========================================================================
convert_gross_sales <- function(value) {
    value <- gsub(",", "", value)  # remove financial formatting
    if(substr(value, nchar(value), nchar(value)) == "k") {  # if thousands, return result in millions
        value <- as.numeric(substr(value, 2, nchar(value) - 1)) / 1000
    } else {
        value <- as.numeric(substr(value, 2, nchar(value)))
    }
    return(value)
}