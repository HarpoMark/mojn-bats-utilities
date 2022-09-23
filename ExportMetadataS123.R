source("utils.R")
library(dplyr)
#loadbatdata()

visitseasonfilter <- c("22W","22S")
bat.site <- agol_layers$Site %>%
  dplyr::select(SiteCode, GRTSCell, Park, BroadHabitat, WaterBodyType, Latitude, Longitude)
bat.deployment <- agol_layers$deployment %>%
  dplyr::select(SiteCode,VisitGroupCode,
                CreationDate,Creator,EditDate,Editor,
                ClutterPercent,ClutterDistance_m,ClutterType,
                DistanceToWater_m,
                MicrophoneOrientation,MicrophoneHeightOffGround_m,
                DeploymentNotes,DeploymentSignificantWeatherNot,RecoverySignificantWeatherNotes,
                DetectorCode, MicrophoneCode,
                ActualStartDate, ActualStartTime,ActualStopDate,ActualStopTime,
                GlobalID)
bat.detection <- agol_layers$detection
bat.detectors <- agol_layers$lu_detectors %>%
  dplyr::select(DetectorCode = name, DetectorSerialNumber = SerialNumber, DetectorManufacturer = Manufacturer, DetectorModel = Model, DetectorOwner = Owner, DetectorStatus = Status)
bat.mics <- agol_layers$lu_mics %>%
  dplyr::select(MicrophoneCode = name, MicSerialNumber = SerialNumber, MicManufacturer = Manufacturer, MicModel = Model, MicOwner = Owner, MicStatus = Status)



bat.metadata <- dplyr::left_join(bat.deployment, bat.site, by = "SiteCode") %>%
  dplyr::left_join(bat.detectors, "DetectorCode") %>%
  dplyr::left_join(bat.mics, "MicrophoneCode")  


bat.metadata <- dplyr::filter(bat.metadata,VisitGroupCode %in% visitseasonfilter) %>%
  dplyr::mutate("Contact Name" = "Allen Calvert", "Contact Email" = "Allen_Calvert@nps.gov", "Weather Proofing" = "FALSE",
                "Unusual Occurrences" = paste("Deployment: ",DeploymentSignificantWeatherNot, " Recovery: ",RecoverySignificantWeatherNotes),
                "Nightly Low Temperature"= "","Nightly High Temperature" = "",	"Nightly Low Relative Humidity (%)"="","Nightly High Relative Humidity (%)"="",
                "Nightly Low Weather Event"="","Nightly High Weather Event"="","Nightly Low Windspeed (km/hr)"="","Nightly High Windspeed (km/hr)"="",
                "Nightly Low Cloud Cover (%)"="","Nightly High Cloud Cover (%)"="",
                "Time Zone" = "Pacific Time")
bat.metadata$MicrophoneOrientation <- tolower(bat.metadata$MicrophoneOrientation)



metadata_S123 <-dplyr::select(bat.metadata,
                         GlobalID,
                         CreationDate,
                         Creator, 
                         EditDate, 
                         Editor,
                         "Contact Name",
                         "Contact Email",
                         ActualStartDate, ActualStartTime,
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
                         "Unusual Occurrences",
                         ActualStopDate, ActualStopTime,
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
                         "X" = Longitude)
