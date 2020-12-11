# Grabbing data from News API

## Loading packages
library(tidyverse)
library(stringr)
library(httr)
library(jsonlite)
library(lubridate)

## Constructing the GET request for News API
key <- "7372ec69f63043d9ba39f296bb6973a5"
base_url <- "https://newsapi.org/v2/everything?"
search_term <- "K-pop"

news_kpop <- GET(base_url, query = list('q' = search_term, 'apiKey' = key,
                                        'from' = 2020-01-01, 'language' = "en"))


## Parsing the response
news_response <- httr::content(news_kpop, "text")

# Convert to dataframe
response_df <- fromJSON(news_response, simplifyDataFrame = TRUE, flatten = TRUE)
names(response_df)
response_df$totalResults # We have 1867 total results
hits <- 1867

# Pulling the articles data
response_df <- response_df$articles
names(response_df)
response_df <- response_df %>%
  select(author, title, url, publishedAt, content, source.name) # Columns we want


## Iteration
# We want all 1860 results, and can pull 20 at a time.
pages <- ceiling(hits/100) # We have to iterate 19 times

# Writing a function for iteration
newsapi <- function(n){
  base_url <- "https://newsapi.org/v2/everything?"
  
  # GET request
  get <- GET(base_url, query = list('q' = search_term, 'apiKey' = key,
                                          'from' = 2020-01-01, 'language' = "en",
                                    'pageSize' = 100, 'page' = n))
  
  # Parse to JSON
  response <- httr::content(get, "text")
  response_df <- fromJSON(response, simplifyDataFrame = TRUE, flatten = TRUE)
  response_df <- response_df$articles
  
  Sys.sleep(1)
  return(response_df)
}


# Iterate over pages
news <- map((1:pages), newsapi)
# Unfortunately, I am limited to 100 requests a day, so I can only get 100 articles. Oops.
news_df <- bind_rows(news)
write.csv(news_df, file = "news.csv")
