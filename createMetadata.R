# Created for 2024 data (Lehman)

library(tidyverse)
library(stringr)
# This code assumes that you have already run loadBatData.R to pull the latest data from AGOL


# Set output folder for CSV exports
dest.folder <- paste0("C:/Users/mlehman/Documents/R/export/bats","/",format(Sys.time(), format="%Y-%m-%dT%H%M%S"))

if (file.exists(dest.folder)) {
  cat("The folder already exists")
} else {
  dir.create(dest.folder)
}

#--------Set Filters---------------
# Example:   visitseasonfilter <- c("22W","22S")
#visitseasonfilter <- c("18W", "18S", "19W", "19S","20W","20S","21W","21S","22W","22S","23W","23S")
visitseasonfilter <- c("24S")

bat.site <- agol_layers$Site %>%
  dplyr::select(SiteCode, GRTSCell, Park, BroadHabitat, WaterBodyType, Latitude, Longitude, LegacySiteCode)

bat.deployment <- agol_layers$deployment %>%
  dplyr::filter(VisitGroupCode %in% visitseasonfilter) %>%
  dplyr::select(SiteCode,VisitGroupCode,
                CreationDate,Creator,EditDate,Editor,DeploymentDate,
                ClutterPercent,ClutterDistance_m,ClutterType,
                DistanceToWater_m,
                MicrophoneOrientation,MicrophoneHeightOffGround_m,
                DeploymentNotes,DeploymentSignificantWeatherNot,RecoverySignificantWeatherNotes,
                DetectorCode, MicrophoneCode,
                ActualStartDate, ActualStartTime,ActualStopDate,ActualStopTime,
                GlobalID,DeploymentKey,ExpectedEndDate, ExpectedEndTime,
                DetectionFirst, DetectionLast, MonitoringStatus, NumFilesDownloaded, NumFilesProcessed,BatteryLocation, BatteryType,
                ProgramedStartTime, ProgramedStopTime, DeploymentDateText, RecoveryDateText,
                RecordingStartDateText, RecordingStartTimeText, RecordingEndDateText, RecordingEndTimeText,
                Software, SpeciesList, ManualVetter)

bat.detectors <- agol_layers$lu_detectors %>%
  dplyr::select(DetectorCode = name, DetectorSerialNumber = SerialNumber, DetectorManufacturer = Manufacturer, DetectorModel = Model, DetectorOwner = Owner, DetectorStatus = Status)
bat.mics <- agol_layers$lu_mics %>%
  dplyr::select(MicrophoneCode = name, MicSerialNumber = SerialNumber, MicManufacturer = Manufacturer, MicModel = Model, MicOwner = Owner, MicStatus = Status)

bat.metadata <- dplyr::left_join(bat.deployment, bat.site, by = "SiteCode") %>%
  dplyr::left_join(bat.detectors, "DetectorCode") %>%
  dplyr::left_join(bat.mics, "MicrophoneCode") %>%
  dplyr::mutate("Contact Name" = "Allen Calvert", "Contact Email" = "Allen_Calvert@nps.gov",
              "SurveyStartTime" = paste(RecordingStartDateText,"T", RecordingStartTimeText,":00", sep = ""),
              "Weather Proofing" = "FALSE",
              "Unusual Occurrences" = paste("Deployment: ",DeploymentSignificantWeatherNot, " Recovery: ",RecoverySignificantWeatherNotes),
              "SurveyEndTime" = paste(RecordingEndDateText,"T", RecordingEndTimeText, ":00", sep = ""),
              "Nightly Low Temperature"= "","Nightly High Temperature" = "",	"Nightly Low Relative Humidity (%)"="","Nightly High Relative Humidity (%)"="",
              "Nightly Low Weather Event"="","Nightly High Weather Event"="","Nightly Low Windspeed (km/hr)"="","Nightly High Windspeed (km/hr)"="",
              "Nightly Low Cloud Cover (%)"="","Nightly High Cloud Cover (%)"="",
              "Time Zone" = "Pacific Time",
              MicrophoneOrientation = tolower(MicrophoneOrientation),
              MicrophoneOrientation = ifelse(MicrophoneOrientation == "u", "vert", MicrophoneOrientation),
              MicrophoneOrientation = ifelse(MicrophoneOrientation == "NoData", "", MicrophoneOrientation),
              MicrophoneOrientation = ifelse(MicrophoneOrientation == "nodata", "", MicrophoneOrientation),
              ClutterType = ifelse(ClutterType == "NoData","",ClutterType))

bat.metadata.deployment.nabat <- bat.metadata %>%
                            dplyr::filter(MonitoringStatus %in% c("C","P")) %>%
                            dplyr::select("GRTS Cell Id" = GRTSCell,
                                          "Location Name" = SiteCode,
                                          Latitude,
                                          Longitude,
                                          "Survey Start Time" = SurveyStartTime,
                                          "Survey End Time" = SurveyEndTime,
                                          "Detector" = DetectorModel,
                                          "Detector Serial Number" = DetectorSerialNumber,
                                          "Microphone" = MicModel,
                                          "Microphone Serial Number" = MicSerialNumber,
                                          "Microphone Orientation" = MicrophoneOrientation,
                                          "Microphone Height (meters)" = MicrophoneHeightOffGround_m,
                                          "Distance to Nearest Clutter (meters)" = ClutterDistance_m,
                                          "Clutter Type" = ClutterType,
                                          "Distance to Nearest Water (meters)" = DistanceToWater_m,
                                          "Water Type" = WaterBodyType,
                                          "Percent Clutter" = ClutterPercent,
                                          "Broad Habitat Type" = BroadHabitat,
                                          "Land Unit Code" = Park,
                                          "Contact Name",
                                          "Weather Proofing",
                                          "Unusual Occurrences",
                                          "Nightly Low Temperature",
                                          "Nightly High Temperature",
                                          "Nightly Low Relative Humidity (%)",
                                          "Nightly High Relative Humidity (%)",
                                          "Nightly Low Weather Event",
                                          "Nightly High Weather Event",
                                          "Nightly Low Windspeed (km/hr)",
                                          "Nightly High Windspeed (km/hr)",
                                          "Nightly Low Cloud Cover (%)",
                                          "Nightly High Cloud Cover (%)",
                                          "Time Zone",
                                          "MonitoringStatus",
                                          "VisitGroupCode",
                                          "NumFilesDownloaded",
                                          GlobalID,
                                          CreationDate,
                                          Creator,
                                          EditDate,
                                          Editor,)

bat.metadata.deployment.internal <- bat.metadata %>%
  dplyr::select("Land Unit Code" = Park,
                "GRTS Cell Id" = GRTSCell,
                "Location Name" = SiteCode,
                "VisitGroupCode",
                "MonitoringStatus",
                "NumFilesDownloaded",
                "NumFilesProcessed",
                "Survey Start Time" = SurveyStartTime,
                "Survey End Time" = SurveyEndTime,
                "RecordingStartDateText",
                "RecordingEndDateText",
                "BatteryLocation",
                "BatteryType",
                "Detector" = DetectorModel,
                "Detector Serial Number" = DetectorSerialNumber,
                "Microphone" = MicModel,
                "Microphone Serial Number" = MicSerialNumber,
                "Microphone Orientation" = MicrophoneOrientation,
                "Microphone Height (meters)" = MicrophoneHeightOffGround_m,
                "Distance to Nearest Clutter (meters)" = ClutterDistance_m,
                "Clutter Type" = ClutterType,
                "Distance to Nearest Water (meters)" = DistanceToWater_m,
                "Water Type" = WaterBodyType,
                "Percent Clutter" = ClutterPercent,
                "Broad Habitat Type" = BroadHabitat,
                "Contact Name",
                "Weather Proofing",
                "Unusual Occurrences",
                Latitude,
                Longitude,
                "Time Zone",
                GlobalID,
                CreationDate,
                Creator,
                EditDate,
                Editor,)

# Export results to CSV files
readr::write_csv(bat.site, file.path(dest.folder, paste0("site", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(bat.deployment, file.path(dest.folder, paste0("deployment", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(bat.mics, file.path(dest.folder, paste0("mics", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(bat.detectors, file.path(dest.folder, paste0("detectors", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(bat.metadata.deployment.nabat, file.path(dest.folder, paste0("deployment_metadata_nabat", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(bat.metadata.deployment.internal, file.path(dest.folder, paste0("deployment_metadata_internal", ".csv")), na = "", append = FALSE, col_names = TRUE)
