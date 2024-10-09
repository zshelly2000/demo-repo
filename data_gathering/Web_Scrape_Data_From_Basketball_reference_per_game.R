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
    html_nodes(".left , .right , .center") %>%
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
  
  #the way that the raw_data comes in off of this data pull, it duplicates after the row that says "League Average" (a row that I also would like to remove)
  # Step 1: Find the index where Player == "League Average"
  index_league_avg <- which(df_per_game$Player == "League Average")
  
  # Step 2: If "League Average" is found, subset the DataFrame to remove that row and everything after it
  if (length(index_league_avg) > 0) {
    df_per_game <- df_per_game[1:(index_league_avg - 1), ]
  }
  
  #they use pho, cho, and brk I want phx, cha, and bkn to be the official abbreviations
  df_per_game$Team[df_per_game$Team == 'PHO'] <- 'PHX'
  df_per_game$Team[df_per_game$Team == 'CHO'] <- 'CHA'
  df_per_game$Team[df_per_game$Team == 'BRK'] <- 'BKN'
  
  #I want to normalize column headers that will be shared across tables i.e. team name, player name, age, player_id
  colnames(df_per_game)[colnames(df_per_game) == "Rk"] <- "PLAYER_ID"
  colnames(df_per_game)[colnames(df_per_game) == "Player"] <- "PLAYER_NAME"
  colnames(df_per_game)[colnames(df_per_game) == "Age"] <- "AGE"
  colnames(df_per_game)[colnames(df_per_game) == "Team"] <- "TEAM_ABBREVIATION"
  
  #Basketball Reference does multiple lines for players who played for multiple teams during the season. I want to use the team that they ended the year with.
  df_per_game <- df_per_game %>%
    group_by(PLAYER_ID) %>%
    mutate(
      #the first row in every duplicated player instance will always be the entire season but won't have the correct team if they were traded
      first_team = first(TEAM_ABBREVIATION),
      # Identify the last team abbreviation within each group bc bball ref puts the team that the player ended the season with last (if only one team then it will be first and last)
      last_team = last(TEAM_ABBREVIATION)
    ) %>%
    # Keep rows that match the first_team because these will always be the entire seaosn stats
    filter(TEAM_ABBREVIATION == first_team) %>%
    # Update TEAM_ABBREVIATION for "TOT" rows
    mutate(TEAM_ABBREVIATION = last_team) %>%
    ungroup() %>%
    # Drop helper columns
    select(-first_team, -last_team)
  
  return(df_per_game)
}
