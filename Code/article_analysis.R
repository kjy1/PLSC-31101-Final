# Analyzing article data

## Loading packages
library(tidyverse)
library(rtweet)
library(lubridate)
library(tm)
library(ggplot2)
library(wordcloud)
library(textdata)
library(tidytext)


# Read in csv files
allkpop <- read.csv("Data/allkpop.csv")
news <- read.csv("Data/news.csv")


# Preprocessing
akp_corp <- Corpus(VectorSource(allkpop$Content))
akp_dtm  <- DocumentTermMatrix(akp_corp, control = list(stopwords = TRUE,
                                                        tolower = TRUE,
                                                        removeNumber = TRUE,
                                                        removePunctuation = TRUE))

news_corp <- Corpus(VectorSource(news$content))
news_dtm  <- DocumentTermMatrix(news_corp, control = list(stopwords = TRUE,
                                                          tolower = TRUE,
                                                          removeNumber = TRUE,
                                                          removePunctuation = TRUE))

# Frequencies
akp_freq <- colSums(as.matrix(akp_dtm)) %>%
  sort(decreasing = TRUE)
head(akp_freq)

news_freq <- colSums(as.matrix(news_dtm)) %>%
  sort(decreasing = TRUE)
news_freq <- news_freq[-2] # Removing the term 'kpop' manually
head(news_freq)

# Word cloud!
set.seed (123) # for reproducibility

akp_wc <- wordcloud(names(akp_freq), akp_freq, max.words = 50,
                    colors = brewer.pal(9, "Set1"))

news_wc <- wordcloud(names(news_freq), news_freq, max.words = 50,
                     colors = brewer.pal(9, "Set1"))


## Sentiment analysis
# Load dictionary
sent <- get_sentiments("afinn")

# Make dataframe of frequencies
akp_words <- as.data.frame(akp_freq, word = colnames (akp_freq), stringsAsFactors = FALSE)
akp_words <- tibble::rownames_to_column(akp_words, "word")

news_words <- as.data.frame(news_freq, word = colnames (news_freq), stringsAsFactors = FALSE)
news_words <- tibble::rownames_to_column(news_words, "word")

# Join with sentiment dictionary
akp_sent <- akp_words %>%
  left_join(sent, by = "word") %>%
  summarize(word = word, frequency = akp_freq, value = replace_na(value, 0)) # Set NA to 0

akp_sent <- akp_sent %>%
  mutate(total = as.numeric(frequency*value)) %>% # Add total sentiment value column
  arrange(desc(total))
head(akp_sent)


news_sent <- news_words %>%
  left_join(sent, by = "word") %>%
  summarize(word = word, frequency = news_freq, value = replace_na(value, 0)) # Set NA to 0

news_sent <- news_sent %>%
  mutate(total = as.numeric(frequency*value)) %>% # Add total sentiment value column
  arrange(desc(total))
head(news_sent)

## Time to visualize the sentiment analysis
# Prepare the data
akp_top <- akp_sent %>% # Get top 5 positive words
  summarize(word = word, total = total) %>%
  top_n(5) %>%
  mutate(sentiment = "positive") # To color code bar graph
akp_bot <- kpop_sent %>% # Get top 5 negative words
  summarize(word = word, total = total) %>%
  top_n(-5) %>%
  mutate(sentiment = "negative")

akp_dat <- full_join(akp_top, akp_bot) # Combine


news_top <- news_sent %>% # Get top 5 positive words
  summarize(word = word, total = total) %>%
  top_n(5) %>%
  mutate(sentiment = "positive") # To color code bar graph
news_bot <- news_sent %>% # Get top 5 negative words
  summarize(word = word, total = total) %>%
  top_n(-5) %>%
  mutate(sentiment = "negative")

news_dat <- full_join(news_top, news_bot) # Combine
# There are 13 values, not 10. Assuming some totals were tied

# Bar graph
akp_bar <- ggplot(data = akp_dat, aes(x = word, y = total, fill = sentiment)) +
  geom_bar(stat = "identity") +
  coord_flip() + 
  # Labels and titles
  xlab("Sentiment score") +
  ylab("Word") +
  ggtitle("Most positive and negative words in AllKpop articles") +
  ylim(-700, 700) 

ggsave("akp_sent.png", plot = akp_bar)


news_bar <- ggplot(data = news_dat, aes(x = word, y = total, fill = sentiment)) +
  geom_bar(stat = "identity") +
  coord_flip() + 
  # Labels and titles
  xlab("Sentiment score") +
  ylab("Word") +
  ggtitle("Most positive and negative words in news articles about K-pop") +
  theme(plot.title = element_text(size = 11)) +
  ylim(-40, 40) 
news_bar
ggsave("news_sent.png", plot = news_bar)


## Calculating mean of total sentiment score, out of curiosity
akp_mean <- mean(akp_sent$total) # 0.5254216
news_mean <- mean(news_sent$total) # 0.1121575
# Both are more positive, with AllKpop being the more positive of the two.

## Plotting the means, out of curiosity
# Gotta make a dataframe
means_df <- data.frame (data  = c("AllKpop.com articles", "News articles",
                                  "K-pop fans", "General Twitter users"),
                        mean = c(as.numeric(akp_mean), as.numeric(news_mean), 
                                    0.3937158, -0.0001737),
                        fan = c("yes", "not necessarily", "yes", "not necessarily"))

# Bar graph
means_bar <- ggplot(data = means_df, aes(x = data, y = mean, fill = fan)) +
  geom_bar(stat = "identity") +
  # Labels and titles
  xlab("Data source") +
  ylab("Mean Sentiment Score") +
  ggtitle("Mean sentiment scores") +
  labs(fill = "K-pop fan?") +
  theme(axis.text.x = element_text(size = 6),
        axis.title = element_text(size = 10)) +
  ylim(-0.001, 0.6)

ggsave("means_bar.png", plot = means_bar)

