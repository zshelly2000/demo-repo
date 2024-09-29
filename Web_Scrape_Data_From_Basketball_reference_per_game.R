library(rvest)
library(tidyverse)
library(dplyr)


# Specify the URL
url <- paste0("https://www.basketball-reference.com/leagues/NBA_2024_per_game.html")

# Read the HTML content from the URL
page <- read_html(url)

# Scrape all the data
raw_data <- page %>%
  html_nodes(".left , .center , .right") %>%
  html_text()

#extracting the column names
column_names <- raw_data[1:31]

#extracting the reamining elements
data_values <- raw_data[32:length(raw_data)]

# Remove the last two items because they are extra that the scrape brings in and not part of the original table
data_values <- data_values[1:(length(data_values) - 2)]

#reshaping the data into a matrix
data_matrix <- matrix(data_values, ncol = length(column_names), byrow = TRUE)

#convert the matrix to a data.frame and assign column names
df_per_game <- as.data.frame(data_matrix, stringsAsFactors = FALSE)
colnames(df) <- column_names