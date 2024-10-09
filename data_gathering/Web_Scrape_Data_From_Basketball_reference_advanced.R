library(rvest)
library(tidyverse)
library(dplyr)

advanced_br_webscrape <- function(){
  # Specify the URL
  url <- paste0("https://www.basketball-reference.com/leagues/NBA_2024_advanced.html")
  
  # Read the HTML content from the URL
  page <- read_html(url)
  
  # Scrape all the data
  raw_data <- page %>%
    html_nodes(".left , .center , .right") %>%
    html_text()
  
  #extracting the column names
  column_names <- raw_data[1:match("VORP", raw_data)]
  
  #extracting the reamining elements
  data_values <- raw_data[(match("VORP", raw_data)+1):length(raw_data)]
  
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
  df_advanced <- as.data.frame(data_matrix, stringsAsFactors = FALSE)
  colnames(df_advanced) <- column_names
  
  #they use pho, cho, and brk I want phx, cha, and bkn to be the official abbreviations
  df_advanced$Tm[df_advanced$Tm == 'PHO'] <- 'PHX'
  df_advanced$Tm[df_advanced$Tm == 'CHO'] <- 'CHA'
  df_advanced$Tm[df_advanced$Tm == 'BRK'] <- 'BKN'
  
  #remove the little blank columns that they put in here:
  df_advanced <- df_advanced[, -c(20, 25)]
  
  #I want to normalize column headers that will be shared across tables i.e. team name, player name, age, player_id
  colnames(df_advanced)[colnames(df_advanced) == "Rk"] <- "PLAYER_ID"
  colnames(df_advanced)[colnames(df_advanced) == "Player"] <- "PLAYER_NAME"
  colnames(df_advanced)[colnames(df_advanced) == "Age"] <- "AGE"
  colnames(df_advanced)[colnames(df_advanced) == "Tm"] <- "TEAM_ABBREVIATION"
  
  #Basketball Reference does multiple lines for players who played for multiple teams during the season. I want to use the team that they ended the year with.
  df_advanced <- df_advanced %>%
    group_by(PLAYER_ID) %>%
    mutate(
      # Identify if the player has a "TOT" row (i.e., was traded)
      has_tot = any(TEAM_ABBREVIATION == "TOT"),
      # Identify the last team abbreviation within each group bc bball ref puts the team that the player ended the season with last
      last_team = last(TEAM_ABBREVIATION)
    ) %>%
    # Keep rows based on conditions:
    # - If the player was traded (has "TOT"), keep only the "TOT" row
    # - If the player was not traded, keep the original row
    filter((has_tot & TEAM_ABBREVIATION == "TOT") | !has_tot) %>%
    # Update TEAM_ABBREVIATION for "TOT" rows
    mutate(TEAM_ABBREVIATION = ifelse(TEAM_ABBREVIATION == "TOT", last_team, TEAM_ABBREVIATION)) %>%
    ungroup() %>%
    # Drop helper columns
    select(-has_tot, -last_team)
  
  
  return(df_advanced)
}
