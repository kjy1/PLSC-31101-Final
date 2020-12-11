# Grabbing data from allkpop.com, the most popular Kpop fan-oriented news site

## Loading packages
library(RSelenium)
library(wdman)
library(tidyverse)
library(rvest)
library(stringr)
library(purrr)
library(lubridate)


## Making a function to scrape information from an individual article URL ##
scrape_akp <- function(URL){
  html <- read_html(URL)
  
  title <- html_nodes(html, "#article-title") %>%
    html_text()
  
  author <- html_nodes(html, ".author") %>%
    html_text()
  
  content <- html_nodes(html, "#article-content p") %>%
    html_text()
  
  content <- str_c(content, collapse = "\n\n")
  
  comments <- html_nodes(html, "#article-info span:nth-child(1)") %>%
    html_text() %>%
    str_trim("left") # Delete white space before the number
  
  upvotes <- html_nodes(html, ".upvote_stat") %>%
    html_text() %>%
    str_extract("\\d+%") # Only get the percentage
  
  all_info <- list(Title = title, Author = author, Content = content,
                   Comments_No = comments, Upvote_Percentage = upvotes)
  
  return(all_info)
  Sys.sleep(5) # Slow it down just in case
}


## Making a function to grab all article URLs on the top articles page ##
akp_urls <- function(html){
  
  urls <- html_nodes(html, "#more_stories_scr .title .h_a_i") %>%
    html_attr("href")
  
  full_urls <- str_c("https://allkpop.com", urls) # Attaching first part of URL
  
  return(full_urls)
  
}


## Getting the URLs
# Now, the only problem is that the top articles page has infinite scroll. To 
# work around this, I will use the RSelenium package.

# Building the Selenium Server
remDr <- remoteDriver(remoteServerAddr = "localhost", port = 4444L, 
                      browserName = "firefox")

remDr$getStatus() # check if server is running
remDr$open()

# Navigating to the webpage
remDr$navigate("https://www.allkpop.com/?view=s&feed=n&sort=b")

# Scrolling:
# To work around the infinite scroll, I will use a for loop that will simulate
# scrolling down the page until I see enough results.
# I want to see 1000 articles. After some trial and error, it seems like the page
# stops scrolling after 912 articles. This is close enough, so I will work with this.
for(i in 1:50){      
  remDr$executeScript(paste("scroll(0,",i*10000,");"))
  Sys.sleep(5)    
}

# This code will scroll back up to the top in case I have to reset
# webElem <- remDr$findElement("css", "body")
# webElem$sendKeysToElement(list(key = "home"))

## Reading the html
page_source <- remDr$getPageSource()
page_html <- read_html(page_source[[1]])

## Closing the Selenium session
remDr$close()

## Getting all 912 article URLs
akp_articles <- akp_urls(page_html)

## Getting data from all 912 articles
akp_data <- map_dfr(akp_articles, scrape_akp)

str(akp_data) # Checking structure, looks ok

write.csv(akp_data, file = "allkpop.csv")

