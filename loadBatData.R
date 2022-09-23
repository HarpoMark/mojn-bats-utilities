library(dplyr)
data_path = "https://services1.arcgis.com/fBc8EJBxQRMcHlei/arcgis/rest/services/MOJN_BatsAcoustic_Database/FeatureServer"
lookup_path = "https://services1.arcgis.com/fBc8EJBxQRMcHlei/arcgis/rest/services/MOJN_Lookup_Database/FeatureServer"
agol_username = "mojn_bats"
agol_password = rstudioapi::askForPassword(paste("Please enter the password for AGOL account", agol_username))
token_resp <- httr::POST("https://nps.maps.arcgis.com/sharing/rest/generateToken",
                         body = list(username = agol_username,
                                     password = agol_password,
                                     referer = 'https://irma.nps.gov',
                                     f = 'json'),
                         encode = "form")
agol_token <- jsonlite::fromJSON(httr::content(token_resp, type="text", encoding = "UTF-8"))

agol_layers <- list()

# ----- Site -----
agol_layers$Site <- fetchAllRecords(data_path, 0, token = agol_token$token) %>%
  dplyr::mutate(CreationDate = as.POSIXct(CreationDate/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
  dplyr::mutate(EditDate = as.POSIXct(EditDate/1000, origin = "1970-01-01", tz = "America/Los_Angeles"))

# ----- Deployment -----
agol_layers$deployment <- fetchAllRecords(data_path, 3, token = agol_token$token) %>%
  dplyr::mutate(DeploymentDate = as.POSIXct(DeploymentDate/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
  dplyr::mutate(RecordingStartDate = as.POSIXct(RecordingStartDate/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
  dplyr::mutate(RecordingStartTime = as.POSIXct(RecordingStartTime/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
  dplyr::mutate(RecoveryDate = as.POSIXct(RecoveryDate/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
  dplyr::mutate(ActualStartDate = as.POSIXct(ActualStartDate/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
  dplyr::mutate(ActualStopDate = as.POSIXct(ActualStopDate/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
  dplyr::mutate(DataProcessingLevelDate = as.POSIXct(DataProcessingLevelDate/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
  dplyr::mutate(CreationDate = as.POSIXct(CreationDate/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
  dplyr::mutate(EditDate = as.POSIXct(EditDate/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
  dplyr::mutate(ExpectedEndDate = as.POSIXct(ExpectedEndDate/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
  dplyr::mutate(ExpectedEndTime = as.POSIXct(ExpectedEndTime/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
  dplyr::mutate(ActualStopTimeOld = as.POSIXct(ActualStopTimeOld/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) 

# ----- Detection -----
agol_layers$detection <- fetchAllRecords(data_path, 6, token = agol_token$token) %>%
  dplyr::mutate(CreationDate = as.POSIXct(CreationDate/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
  dplyr::mutate(EditDate = as.POSIXct(EditDate/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
  dplyr::mutate(Night = as.POSIXct(Night/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
  dplyr::mutate(CallDate = as.POSIXct(CallDate/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
  dplyr::mutate(CallTime = as.POSIXct(CallTime/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
  dplyr::mutate(CallTimestamp = as.POSIXct(CallTimestamp/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
  dplyr::mutate(DeploymentDate = as.POSIXct(DeploymentDate/1000, origin = "1970-01-01", tz = "America/Los_Angeles"))
  
# ----- Detector Lookup -----
agol_layers$lu_detectors <- fetchAllRecords(lookup_path, 65, token = agol_token$token) %>%
  dplyr::mutate(CreationDate = as.POSIXct(CreationDate/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
  dplyr::mutate(EditDate = as.POSIXct(EditDate/1000, origin = "1970-01-01", tz = "America/Los_Angeles"))

# ----- Microphone Lookup -----
agol_layers$lu_mics <- fetchAllRecords(lookup_path, 68, token = agol_token$token) %>%
  dplyr::mutate(CreationDate = as.POSIXct(CreationDate/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
  dplyr::mutate(EditDate = as.POSIXct(EditDate/1000, origin = "1970-01-01", tz = "America/Los_Angeles"))
