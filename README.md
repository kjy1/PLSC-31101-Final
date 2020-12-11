# PLSC-31101-Final
## Short Description
This project analyzes news articles and tweets about K-pop, comparing sentiments between K-pop fans and non-K-pop fans towards South Korea. I first compared articles from popular K-pop news website AllKpop.com with articles that mention K-pop from News API. Then, I compared tweets replying to @allkpop with the keywords "South Korea" and "Korea" to more general tweets about South Korea. The analysis visualizes the data through bar graphs of top 5 positive & negative words and word clouds.

## Dependencies
1. R, 4.0.2
2. Packages used: RSelenium, wdman, tidyverse, rvest, stringr, purrr, lubridate, httr, jsonlite, rtweet, tm, ggplot2, wordcloud, textdata, tidytext.

## Files
/ 
1. Narrative.Rmd: Provides a narrative of the project, main challenges, solutions, and results.
2. Narrative.pdf: A knitted pdf of 00_Narrative.Rmd.
3. Lightning_Talk.pptx: Slides for brief presentation of project.


Code/
1. kpop.R: Scrapes data from allkpop.com and exports data to the file kpop.csv.
2. news.R: Collects data from News API and exports data to the file news.csv.
3. article_analysis.R: Conducts descriptive analysis of the data from kpop.R and news.R, producing visualizations found in the Results directory.
4. twitter.R: Collects data from Twitter API and conducts analysis of the data, producing visualizations found in the Results directory

Data/
1. kpop.csv: Contains scraped data from top articles on allkpop.com.
2. news.csv: Contains data from News API. Includes information on all articles containing the term "K-pop" or any variation thereof, from 2020-01-01 to present.

Results/
1. 01_kpop_sent.png: Graphs the top 5 positive and negative words from AllKpop articles.
2. 02_kpop_wc.png: Word cloud of AllKpop articles.
3. 03_news_sent.png: Graphs the top 5 positive and negative words from general news articles about South Korea.
4. 04_news_wc.png: Word cloud of general articles about South Korea.
5. 05_akp_sent.png: Graphs the top 5 positive and negative words from tweets replying to @allkpop.
6. 06_akp_wc.png: Word cloud of tweets replying to @allkpop.
7. 07_gen_sent.png: Graphs the top 5 positive and negative words from tweets containing the term "South Korea."
8. 08_gen_wc.png: Word cloud of general tweets mentioning South Korea.
9. 09_means_bar.png: Graphs the mean sentiment score of each dataset.

## More Information
Project by Dianne Kim, jiyoonk@uchicago.edu.
