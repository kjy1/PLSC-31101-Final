# Grabbing and analysing data from Twitter

## Loading packages
library(tidyverse)
library(rtweet)
library(lubridate)
library(tm)
library(ggplot2)
library(wordcloud)
library(textdata)
library(tidytext)

## Responses to @allkpop
kpop_replies <- search_tweets(q = "@allkpop", n = 5000, 
                             type = "recent",include_rts = FALSE, lang = "en")


## General responses
gen <- search_tweets(q = '"South Korea"', n = 5000, type = "recent",
                     include_rts= FALSE, lang = "en")


## Preprocessing the data
kpop_corp <- Corpus(VectorSource(kpop_replies$text))
# Removing terms that I already know are common
kpop_corp <- tm_map(kpop_corp, removeWords, c("kpop", "k-pop", "allkpop"))
kpop_dtm  <- DocumentTermMatrix(kpop_corp, control = list(stopwords = TRUE,
                                                        tolower = TRUE,
                                                        removeNumber = TRUE,
                                                        removePunctuation = TRUE))


gen_corp <- Corpus(VectorSource(gen$text))
# Again, removing common terms
gen_corp <- tm_map(gen_corp, removeWords, c("South", "Korea"))
gen_dtm  <- DocumentTermMatrix(gen_corp, control = list(stopwords = TRUE,
                                                        tolower = TRUE,
                                                        removeNumber = TRUE,
                                                        removePunctuation = TRUE)) 


## Term frequencies
kpop_freq <- colSums(as.matrix(kpop_dtm)) %>%
  sort(decreasing = TRUE)
head(kpop_freq)

gen_freq <- colSums(as.matrix(gen_dtm)) %>%
  sort(decreasing = TRUE)

## Wordclouds!!
set.seed (123) # for reproducibility

kpop_wc <- wordcloud(names(kpop_freq), akp_freq, max.words = 50,
                    scale = c(3, 0.1), colors = brewer.pal(9, "Set1"))

gen_wc <- wordcloud(names(gen_freq), gen_freq, max.words = 50,
                    scale = c(2.5, 0.1), colors = brewer.pal(9, "Set1"))


## Sentiment analysis
# Load dictionary
sent <- get_sentiments("afinn")

# Make dataframe of frequencies
kpop_words <- as.data.frame(kpop_freq, word = colnames (kpop_freq), stringsAsFactors = FALSE)
kpop_words <- tibble::rownames_to_column(kpop_words, "word")

gen_words <- as.data.frame(gen_freq, word = colnames(gen_freq), stringsAsFactors = FALSE)
gen_words <- tibble::rownames_to_column(gen_words, "word")

# Join with sentiment dictionary
kpop_sent <- kpop_words %>%
  left_join(sent, by = "word") %>%
  summarize(word = word, frequency = kpop_freq, value = replace_na(value, 0)) # Set NA to 0

kpop_sent <- kpop_sent %>%
  mutate(total = as.numeric(frequency*value)) %>% # Add total sentiment value column
  arrange(desc(total))
head(kpop_sent)

gen_sent <- gen_words %>%
  left_join(sent, by = "word") %>%
  summarize(word = word, frequency = gen_freq, value = replace_na(value, 0)) # Set NA to 0

gen_sent <- gen_sent %>%
  mutate(total = as.numeric(frequency*value)) %>%
  arrange(desc(total))
head(gen_sent)
  

## Time to visualize the sentiment analysis
# Prepare the data
kpop_top <- kpop_sent %>% # Get top 10 positive words
  summarize(word = word, total = total) %>%
  top_n(5) %>%
  mutate(sentiment = "positive")
kpop_bot <- kpop_sent %>% # Get top 10 negative words
  summarize(word = word, total = total) %>%
  top_n(-5) %>%
  mutate(sentiment = "negative")

kpop_dat <- full_join(kpop_top, kpop_bot) # Combine


gen_top <- gen_sent %>% # Get top 5 positive words
  summarize(word = word, total = total) %>%
  top_n(5) %>%
  mutate(sentiment = "positive")
gen_bot <- gen_sent %>% # Get top 5 negative words
  summarize(word = word, total = total) %>%
  top_n(-5) %>%
  mutate(sentiment = "negative")

gen_dat <- full_join(gen_top, gen_bot) # Combine

# Bar graph
kpop_bar <- ggplot(data = kpop_dat, aes(x = word, y = total, fill = sentiment)) +
  geom_bar(stat = "identity") +
  coord_flip() + 
  # Labels and titles
  xlab("Sentiment score") +
  ylab("Word") +
  ggtitle("Most positive and negative words in AllKpop responses") +
  ylim(-550, 550) 
ggsave("kpop_sent.png", plot = kpop_bar)

gen_bar <- ggplot(data = gen_dat, aes(x = word, y = total, fill = sentiment)) +
  geom_bar(stat = "identity") +
  coord_flip() + 
  # Labels and titles
  xlab("Sentiment score") +
  ylab("Word") +
  ggtitle("Most positive and negative words in tweets about South Korea") +
  theme(plot.title = element_text(size = 11)) +
  ylim(-2000, 1500)
gen_bar
ggsave("gen_sent.png", plot = gen_bar)


## Calculating mean of total sentiment score, out of curiosity
mean(kpop_sent$total) # 0.3937158
mean(gen_sent$total) # -0.0001737
# AllKpop is more positive. I assume general news websites are talking more about
# covid these days.