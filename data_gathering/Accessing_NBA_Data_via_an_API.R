# Load the packages
library(httr)
library(jsonlite)

get_NBA_data_via_API <- function(){
  # API endpoint for player statistics
  url <- "https://stats.nba.com/stats/leaguedashplayerstats"
  
  # Define query parameters
  params <- list(
    'College' = '',
    'Conference' = '',
    'Country' = '',
    'DateFrom' = '',
    'DateTo' = '',
    'Division' = '',
    'DraftPick' = '',
    'DraftYear' = '',
    'GameScope' = '',
    'GameSegment' = '',
    'Height' = '',
    'LastNGames' = '0',
    'LeagueID' = '00',
    'Location' = '',
    'MeasureType' = 'Base',
    'Month' = '0',
    'OpponentTeamID' = '0',
    'Outcome' = '',
    'PORound' = '0',
    'PaceAdjust' = 'N',
    'PerMode' = 'PerGame',
    'Period' = '0',
    'PlayerExperience' = '',
    'PlayerPosition' = '',
    'PlusMinus' = 'N',
    'Rank' = 'N',
    'Season' = '2022-23',
    'SeasonSegment' = '',
    'SeasonType' = 'Regular Season',
    'ShotClockRange' = '',
    'StarterBench' = '',
    'TeamID' = '0',
    'TwoWay' = '0',
    'VsConference' = '',
    'VsDivision' = '',
    'Weight' = ''
  )
  
  # Set HTTP headers
  headers <- c(
    'Host' = 'stats.nba.com',
    'Connection' = 'keep-alive',
    'Accept' = 'application/json, text/plain, */*',
    'x-nba-stats-token' = 'true',
    'User-Agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
    'x-nba-stats-origin' = 'stats',
    'Referer' = 'https://www.nba.com/',
    'Accept-Language' = 'en-US,en;q=0.9',
    'Origin' = 'https://www.nba.com'
  )
  
  
  # Send GET request
  response <- GET(url, query = params, add_headers(.headers = headers))
  
  # Check the status code
  print(paste("Status code:", status_code(response)))
  
  if (status_code(response) == 200) {
    # Get raw content
    raw_content <- content(response, as = "text", encoding = "UTF-8")
    
    # Check if the content is valid JSON
    if (substr(raw_content, 1, 1) == "{") {
      # Parse the JSON content
      data_json <- fromJSON(raw_content, flatten = TRUE)
      
      # Check if 'resultSets' exists
      if ("resultSets" %in% names(data_json)) {
        # Extract the headers and data
        headers_data <- data_json$resultSets$headers[[1]]
        rows <- data_json$resultSets$rowSet[[1]]
        
        # Check the structure of 'rows'
        if (is.matrix(rows) || is.array(rows)) {
          # Convert 'rows' to data frame
          player_stats_df <- as.data.frame(rows, stringsAsFactors = FALSE)
          colnames(player_stats_df) <- headers_data
          
        } else if (is.list(rows)) {
          # Combine list of rows into data frame
          player_stats_df <- as.data.frame(do.call(rbind, rows), stringsAsFactors = FALSE)
          colnames(player_stats_df) <- headers_data

        } else {
          print("Unexpected data structure for 'rows'")
        }
      } else {
        print("'resultSets' not found in JSON response.")
      }
    } else {
      print("Response is not valid JSON.")
      print("Response content:")
      print(substr(raw_content, 1, 500))
    }
  } else {
    print(paste("Request failed with status code:", status_code(response)))
  }
  
  return(player_stats_df)
}
