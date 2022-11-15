source("utils.R")
library(dplyr)
library(stringr)
#loadbatdata()

#--------Set Filters---------------
# Example:   visitseasonfilter <- c("22W","22S")
visitseasonfilter <- c("18W", "18S", "19W", "19S","20W","20S","21W","21S")
#visitseasonfilter <- c("22W","22S")


bat.site <- agol_layers$Site %>%
  dplyr::select(SiteCode, GRTSCell, Park, BroadHabitat, WaterBodyType, Latitude, Longitude)

bat.deployment <- agol_layers$deployment %>%
  dplyr::select(SiteCode,VisitGroupCode,
                CreationDate,Creator,EditDate,Editor,DeploymentDate,
                ClutterPercent,ClutterDistance_m,ClutterType,
                DistanceToWater_m,
                MicrophoneOrientation,MicrophoneHeightOffGround_m,
                DeploymentNotes,DeploymentSignificantWeatherNot,RecoverySignificantWeatherNotes,
                DetectorCode, MicrophoneCode,
                ActualStartDate, ActualStartTime,ActualStopDate,ActualStopTime,
                GlobalID,DeploymentKey,ExpectedEndDate, ExpectedEndTime,
                DetectionFirst, DetectionLast, MonitoringStatus, NumFilesDownloaded, NumFilesProcessed,
                ProgramedStartTime, ProgramedStopTime, DeploymentDateText, RecoveryDateText, 
                RecordingStartDateText, RecordingStartTimeText, RecordingEndDateText, RecordingEndTimeText,
                Software, SpeciesList, ManualVetter)

bat.detection <- agol_layers$detection %>%
  dplyr::mutate("AudioRecordingTime" = paste(stringr::str_sub(SCallTimestamp,start = 1,end = 4),"-",
                                             stringr::str_sub(SCallTimestamp,start = 5,end = 6),"-",
                                             stringr::str_sub(SCallTimestamp,start = 7,end = 8),"T",
                                             stringr::str_sub(SCallTimestamp,start = 10,end = 11),":",
                                             stringr::str_sub(SCallTimestamp,start = 12,end = 13),":",
                                             stringr::str_sub(SCallTimestamp,start = 14,end = 15),
                                             sep = "")
                )

bat.detectors <- agol_layers$lu_detectors %>%
  dplyr::select(DetectorCode = name, DetectorSerialNumber = SerialNumber, DetectorManufacturer = Manufacturer, DetectorModel = Model, DetectorOwner = Owner, DetectorStatus = Status)
bat.mics <- agol_layers$lu_mics %>%
  dplyr::select(MicrophoneCode = name, MicSerialNumber = SerialNumber, MicManufacturer = Manufacturer, MicModel = Model, MicOwner = Owner, MicStatus = Status)



bat.metadata <- dplyr::left_join(bat.deployment, bat.site, by = "SiteCode") %>%
  dplyr::left_join(bat.detectors, "DetectorCode") %>%
  dplyr::left_join(bat.mics, "MicrophoneCode")  


bat.metadata <- dplyr::filter(bat.metadata,VisitGroupCode %in% visitseasonfilter) %>%
  dplyr::mutate("Contact Name" = "Allen Calvert", "Contact Email" = "Allen_Calvert@nps.gov",
                "Survey Start Time" = paste(RecordingStartDateText,"T", RecordingStartTimeText,":00", sep = ""),
                "Weather Proofing" = "FALSE",
                "Unusual Occurrences" = paste("Deployment: ",DeploymentSignificantWeatherNot, " Recovery: ",RecoverySignificantWeatherNotes),
                "Survey End Time" = paste(RecordingEndDateText,"T", RecordingEndTimeText, ":00", sep = ""),
                "Nightly Low Temperature"= "","Nightly High Temperature" = "",	"Nightly Low Relative Humidity (%)"="","Nightly High Relative Humidity (%)"="",
                "Nightly Low Weather Event"="","Nightly High Weather Event"="","Nightly Low Windspeed (km/hr)"="","Nightly High Windspeed (km/hr)"="",
                "Nightly Low Cloud Cover (%)"="","Nightly High Cloud Cover (%)"="",
                "Time Zone" = "Pacific Time", 
                MicrophoneOrientation = tolower(MicrophoneOrientation),
                MicrophoneOrientation = ifelse(MicrophoneOrientation == "u", "vert", MicrophoneOrientation))


bat.detectionmetadata <- bat.detection %>%
  dplyr::left_join(bat.metadata, by = c("ParentGlobalID"="GlobalID"))


detection_metadata <-dplyr::select(bat.detectionmetadata,
                                   "GRTS Cell Id" = GRTSCell,
                                   "Location Name" = SiteCode,
                                   Latitude,
                                   Longitude,
                                   "Survey Start Time",
                                   "Survey End Time",
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
                                   "Contact" = "Contact Name",
                                   "Weather Proofing",
                                   "Unusual Occurrences",
                                   "Nightly Low Temperature",
                                   "Nightly High Temperature",
                                   "Nightly Low Relative Humidity" = "Nightly Low Relative Humidity (%)",
                                   "Nightly High Relative Humidity" = "Nightly High Relative Humidity (%)",
                                   "Nightly Low Weather Event",  
                                   "Nightly High Weather Event",
                                   "Nightly Low Wind Speed" = "Nightly Low Windspeed (km/hr)",
                                   "Nightly High Wind Speed" = "Nightly High Windspeed (km/hr)",
                                   "Nightly Low Cloud Cover" = "Nightly Low Cloud Cover (%)",
                                   "Nightly High Cloud Cover" = "Nightly High Cloud Cover (%)",
                                   "Audio Recording Name" = Filename,
                                   "Audio Recording Time" = AudioRecordingTime,
                                   "Software Type" = Software,
                                   "Auto Id" = SpeciesCodeAuto,
                                   "Manual Id" = SpeciesCodeManual,
                                   "Species List" = SpeciesList,
                                   "Manual Vetter" = ManualVetter
                                   )                                   



deployment_metadata_S123 <-dplyr::select(bat.metadata,
                         GlobalID,
                         CreationDate,
                         Creator, 
                         EditDate, 
                         Editor,
                         "Contact Name",
                         "Contact Email",
                         "Survey Start Time",
                         "GRTS Cell" = GRTSCell,
                         "Location Name" = SiteCode,
                         "Land Unit Code" = Park,
                         "Broad Habitat Type" = BroadHabitat,
                         "Distance to Nearest Clutter (meters)" = ClutterDistance_m,
                         "Clutter Type" = ClutterType,
                         "Percent Clutter" = ClutterPercent,
                         "Distance to Nearest Water (meters)" = DistanceToWater_m,
                         "Water Type" = WaterBodyType,
                         "Detector" = DetectorModel,
                         "Detector Serial Number" = DetectorSerialNumber,
                         "Microphone" = MicModel,
                         "Microphone Serial Number" = MicSerialNumber,
                         "Microphone Orientation" = MicrophoneOrientation,
                         "Microphone Height (meters)" = MicrophoneHeightOffGround_m,
                         "Weather Proofing",
                         "Unusual Occurrences",
                         "Survey End Time",
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
                         "Y" = Latitude,
                         "X" = Longitude,
                         "MonitoringStatus") %>%
  dplyr::filter(MonitoringStatus %in% c("C","P"))


deploymenttimes <- bat.deployment %>%
  dplyr::select(SiteCode, VisitGroupCode,MonitoringStatus, NumFilesDownloaded, NumFilesProcessed,DeploymentDateText, ProgramedStartTime, ProgramedStopTime, DetectionFirst, RecordingStartDateText, RecordingStartTimeText, DetectionLast, RecordingEndDateText, RecordingEndTimeText)
detectiontimes <- agol_layers$detection %>%
  dplyr::select(LocationName,DeploymentDate, DeploymentKey, VisitGroupCode, Filename, Night, SCallDate, SCallTime, SCallTimestamp, CallDate, CallTime, CallTimestamp)

bat.times <- dplyr::right_join(bat.deployment, bat.detection, by = c("GlobalID"="ParentGlobalID"))

minmaxCall <- bat.times %>% group_by(DeploymentKey.x, DeploymentDateText, VisitGroupCode.x) %>%
  summarize(min = min(SCallTimestamp, na.rm = TRUE),
            max = max(SCallTimestamp, na.rm = TRUE),
            count = n())

bat.times <- dplyr::right_join(bat.deployment, minmaxCall, by = c("DeploymentKey"="DeploymentKey"))
