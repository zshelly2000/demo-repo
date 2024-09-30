library(rvest)
library(tidyverse)
library(dplyr)
library(httr)
library(jsonlite)

# Set the working directory to the project root
setwd("..") # Moves up one directory form 'main/ to 'repo/'

# Source the scripts
source("data_gathering/Accessing_NBA_Data_via_an_API.R")
source("data_gathering/Web_Scrape_Data_From_Basketball_reference_advanced.R")
source("data_gathering/Web_Scrape_Data_From_Basketball_reference_per_game.R")

# Call the functions
nba_stats <- get_NBA_data_via_API()
br_advanced <- advanced_br_webscrape()
br_per_game <- per_game_br_webscrape()
