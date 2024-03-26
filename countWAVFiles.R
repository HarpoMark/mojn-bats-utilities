
# path to data/hard drive
dataPath <- "D:/Bats_24_Mirror_STAY_OUT"

# Retrieve all WAV file paths
files <- list.files(path = dataPath, pattern = ".WAV$", recursive = TRUE, full.names = TRUE)

# Assign empty vector for file info
fileList <- c()

# Iterate over all the WAV files
fileList <- sapply(files, function(file){
  # Fetch the file information
  fileInfo <- file.info(file)
  # add the deployment name and modified date-time to the file info vector
  fileList <- append(fileList, c(str_extract(rownames(fileInfo), "([^/]*/){2}([^/]*)", group = 2), as.character(fileInfo[['mtime']])))

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
                   firstCall = min(shiftedDate),
                   lastCall = max(shiftedDate),
                   deploymentLength = seconds_to_period(difftime(lastCall, firstCall, units = "secs")))

# # Create table with number of calls per night for each deployment
# callsByNight <- filesFlipped %>%
#   dplyr::mutate(ymd = date(shiftedDate)) %>%
#   dplyr::group_by(deployment, ymd) %>%
#   # Calculate number of calls in each date
#   dplyr::summarise(numCalls = n()) %>%
#   # Calculate number day for each date
#   dplyr::mutate(day = seq_along(deployment)) %>%
#   dplyr::select(-ymd) %>%
#   tidyr::pivot_wider(names_from = day, values_from = numCalls, names_prefix = "day_")


# Create table with number of calls per night for each deployment

callsByNight <- filesFlipped %>%
  dplyr::mutate(ymd = date(shiftedDate)) %>%
  dplyr::group_by(deployment, ymd) %>%
  # Calculate number of calls in each date
  dplyr::summarise(numCalls = n())


callsByNight2 <- totalCalls %>%
  dplyr::select(deployment, firstCall, lastCall) %>%
    dplyr::mutate(firstCall = date(firstCall),
                     lastCall = date(lastCall)) %>%
  rowwise() %>%
  # Create a row for each date in the range for every deployment
  do(data.frame(deployment=.$deployment, date=seq(.$firstCall, .$lastCall, by="1 day")))

# Join date range and number of date tables
callsByNightFinal <- callsByNight %>%
  dplyr::full_join(callsByNight2, by = c("ymd" = "date", "deployment" = "deployment"))

# Replace number of call NAs with 0
callsByNightFinal$numCalls[is.na(callsByNightFinal$numCalls)] <- 0

callsByNightFinal <- callsByNightFinal %>%
  dplyr::arrange(deployment, ymd) %>%
  # Calculate number day for each date
  dplyr::mutate(day = seq_along(deployment)) %>%
  dplyr::select(-ymd) %>%
  tidyr::pivot_wider(names_from = day, values_from = numCalls, names_prefix = "day_")


write.csv(totalCalls, "totalBatCalls.csv")
readr::write_csv(callsByNightFinal, "batCallsByNight.csv", na = "")




