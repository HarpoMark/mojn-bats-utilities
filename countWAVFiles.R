library(magrittr)
library(lubridate)
library(tidyverse)

# path to data/hard drive
dataPath <- "E:/MOJN_2024_Summer_Primary"

# Retrieve all WAV file paths
files <- list.files(path = dataPath, pattern = ".WAV$|.wav$", recursive = TRUE, full.names = TRUE)

# Assign empty vector for file info
fileList <- c()

# Iterate over all the WAV files
fileList <- sapply(files, function(file){
  # Fetch the file information
  fileInfo <- file.info(file)
  # add the deployment name and modified date-time to the file info vector
  fileList <- append(fileList, c(stringr::str_extract(rownames(fileInfo), "([^/]*/){2}([^/]*)", group = 2), as.character(fileInfo[['mtime']])))

  return(fileList)
})

# Transpose and turn into data frame
filesFlipped <- as.data.frame(t(fileList))

# Get rid of row names and rename columns
rownames(filesFlipped) <- c()
colnames(filesFlipped) <- c("deployment", "date")
# Shift date/time by twelve hours
filesFlipped <- filesFlipped %>%
  # Add time to dates that don't have a time
  dplyr::mutate(date = dplyr::case_when(
    (nchar(date) != 19) ~ paste0(date, " 00:00:0"),
    .default = date)) %>%
  # Shift all date-times by 12 hours
  dplyr::mutate(shiftedDate = lubridate::ymd_hms(date, tz = "America/Los_Angeles") - hours(12))


# Create table with total calls, first call, and last call per deployment
totalCalls <- filesFlipped %>%
  dplyr::group_by(deployment) %>%
  dplyr::summarise(totalCalls = n(),
          firstCall = min(lubridate::ymd_hms(date, tz = "America/Los_Angeles")),
          lastCall = max(lubridate::ymd_hms(date, tz = "America/Los_Angeles")),
          deploymentLength = lubridate::seconds_to_period(difftime(lastCall, firstCall, units = "secs"))) %>%
  dplyr::mutate(firstCall = as.character(firstCall),
                 lastCall = as.character(lastCall))



# Create table with number of calls per night for each deployment

callsByNight <- filesFlipped %>%
  dplyr::mutate(ymd = lubridate::date(shiftedDate)) %>%
  dplyr::group_by(deployment, ymd) %>%
  # Calculate number of calls in each date
  dplyr::summarise(numCalls = n())

callsByNight2 <- filesFlipped %>%
  dplyr::group_by(deployment) %>%
  # Find the first and last date of each deployment based on the shifted date
  dplyr::summarise(firstCall = lubridate::date(min(shiftedDate)),
                   lastCall = lubridate::date(max(shiftedDate))) %>%
  dplyr::select(deployment, firstCall, lastCall) %>%
  rowwise() %>%
  # Create a row for each date in the range of every deployment
  do(data.frame(deployment=.$deployment, date=seq(.$firstCall, .$lastCall, by="1 day")))

# Join date range and number of date tables
callsByNightFinal <- callsByNight %>%
  dplyr::full_join(callsByNight2, by = c("ymd" = "date", "deployment" = "deployment"))

# Replace number of call NAs with 0
callsByNightFinal$numCalls[is.na(callsByNightFinal$numCalls)] <- 0

callsByNightFinal <- callsByNightFinal %>%
  dplyr::arrange(deployment, ymd) %>%
  # Sequence the dates for every deployment
  dplyr::mutate(day = seq_along(deployment)) %>%
  dplyr::select(-ymd) %>%
  tidyr::pivot_wider(names_from = day, values_from = numCalls, names_prefix = "day_")


readr::write_csv(totalCalls, "totalBatCalls.csv")
readr::write_csv(callsByNightFinal, "batCallsByNight.csv", na = "")





