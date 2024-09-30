library(rvest)
library(tidyverse)
library(dplyr)

per_game_br_webscrape <- function(){
  # Specify the URL
  url <- paste0("https://www.basketball-reference.com/leagues/NBA_2024_per_game.html")
  
  # Read the HTML content from the URL
  page <- read_html(url)
  
  # Scrape all the data
  raw_data <- page %>%
    html_nodes(".left , .center , .right") %>%
    html_text()
  
  #extracting the column names
  column_names <- raw_data[1:match("Awards", raw_data)]
  
  #extracting the reamining elements
  data_values <- raw_data[(match("Awards", raw_data)+1):length(raw_data)]
  
  # Remove the last two items because they are extra that the scrape brings in and not part of the original table
  data_values <- data_values[1:(length(data_values) - 2)]
  
  #the headers repeat themselves throughout the table
  #Identify potential starting positions of repeated headers
  potential_starts <- which(data_values == column_names[1])
  
  # Initialize a vector to hold confirmed starting positions of repeated headers
  header_positions <- c()
  
  # Length of the column names
  header_length <- length(column_names)
  
  # Loop through each potential starting position
  for (start in potential_starts) {
    end <- start + header_length - 1
    
    # Ensure we don't exceed the length of data_values
    if (end > length(data_values)) {
      next
    }
    
    # Check if the sequence matches the column names
    if (all(data_values[start:end] == column_names)) {
      header_positions <- c(header_positions, start)
    }
  }
  
  # Step 4: Remove the repeated headers from data_values
  indices_to_remove <- unlist(
    lapply(header_positions, function(start) start:(start + header_length - 1))
  )
  
  data_values_clean <- data_values[-indices_to_remove]
  
  #reshaping the data into a matrix
  data_matrix <- matrix(data_values_clean, ncol = length(column_names), byrow = TRUE)
  
  #convert the matrix to a data.frame and assign column names
  df_per_game <- as.data.frame(data_matrix, stringsAsFactors = FALSE)
  colnames(df_per_game) <- column_names
  
  return(df_per_game)
}
