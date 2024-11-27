library(NPSdataverse)
library(tidyverse)
library(fetchagol)

database_url <- "https://services1.arcgis.com/fBc8EJBxQRMcHlei/arcgis/rest/services/MOJN_BatsCapture_Database/FeatureServer"
agol_username <- "mojn_data"

batc <- fetchagol::fetchRawData(
  database_url,
  agol_username,
  agol_password = keyring::key_get(service = "AGOL", username = agol_username)
)

#--------Set Filters---------------
# Example:   visitseasonfilter <- c("22W","22S")
#visitseasonfilter <- c("19Sp","20Sp","21Sp","22Sp","23Sp","24Sp")
visitseasonfilter <- c("24Sp")

batc.site <- batc$data$Site %>%
  dplyr::select(SiteCode, SiteName, GRTS, Park, HabitatType, FeatureSampled, Latitude, Longitude, Status, Elevation_m, State, County,SiteDescription, DriveDescription, HikeDescription)

batc.survey <- batc$data$Survey %>%
  dplyr::select(SiteCode, Park, FieldSeason, VisitType, SurveyType, SurveyDate, NetOpenTime, NetCloseTime, NetCount, TotalNetArea_m2, PrimaryObserver, SurveyNotes, globalid) %>%
  dplyr::mutate(SurveyDate = as.POSIXct(SurveyDate/1000, origin = "1970-01-01", tz = "America/Los_Angeles"))

batc.observations <-batc$data$Observations %>%
  dplyr::select(BatNumber, CaptureTime, Species, Age, Sex, ReproductiveStatus, Forearm_mm, Weight_g, WingDamage,CaptureNotes, SwabNumber, globalid, parentglobalid) %>%
  dplyr::left_join(batc.survey, join_by("parentglobalid" == "globalid")) %>%
  dplyr::relocate(SiteCode, FieldSeason)

batc.samples <- batc$data$Samples %>%
  dplyr::left_join(batc.observations, join_by("ParentGlobalID" == "globalid")) %>%
  dplyr::relocate(Park, FieldSeason, SiteCode, VisitType, SurveyDate, SurveyType)

batc.bulkCapture <- batc.observations %>%
  dplyr::left_join(batc.site, join_by("SiteCode" == "SiteCode")) %>%
  dplyr::mutate("| GRTS Cell Id" = GRTS,
                "Location Name" = SiteCode,
                "Type of Survey" = SurveyType,
                #"Species",
                #"Age",
                #"Sex",
                "Reproductive Status" = ReproductiveStatus,
                "Right Forearm (mm)" = ifelse((Forearm_mm == -999), '', Forearm_mm),
                "Mass (g)" = ifelse((Weight_g == -999), '', Weight_g),
                "Net Height (m)" = "",
                "Sample Type" = "",
                "Wing Score" = ifelse((WingDamage == -999), '', WingDamage),
                "Band" = "",
                "Band Color" = "",
                "Band Number" = "",
                "Band Arm" = "",
                "PIT Tag" = "",
                "Radio Frequency" = "",
                "Capture Time" = paste(lubridate::date(SurveyDate),"T", CaptureTime, ":00", sep = ""),
                "Comments" = CaptureNotes,
                #"Latitude",
                #"Longitude",
                "Start Time" = paste(lubridate::date(SurveyDate),"T", NetOpenTime, ":00", sep = ""),
                #Need to add code to increase date by one day when NetCloseTime is after midnight
                "End Time" = paste(lubridate::date(SurveyDate),"T", NetCloseTime, ":00", sep = ""),
                "Effort" = NetCount,
                "TotalNetArea" = TotalNetArea_m2,
                "Feature Sampled" = FeatureSampled,
                "Habitat Type" = HabitatType,
                "Surveyor" = PrimaryObserver,
                "Complete Dataset" = "True") %>%
                dplyr::select("| GRTS Cell Id", "Location Name","Type of Survey","Species", "Age","Sex","Reproductive Status","Right Forearm (mm)",
                              "Mass (g)", "Net Height (m)","Sample Type","Wing Score",
                              "Band","Band Color","Band Number","Band Arm","PIT Tag","Radio Frequency",
                              "Capture Time","Comments","Latitude","Longitude","Start Time","End Time",
                              "Effort","TotalNetArea","Feature Sampled","Habitat Type","Surveyor","Complete Dataset")



# Set output folder for CSV exports
dest.folder <- paste0("C:/Users/mlehman/Documents/R/export/bats","/",format(Sys.time(), format="%Y-%m-%dT%H%M%S"))

if (file.exists(dest.folder)) {
  cat("The folder already exists")
} else {
  dir.create(dest.folder)
}

readr::write_csv(batc.site, file.path(dest.folder, paste0("site", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(batc.survey, file.path(dest.folder, paste0("survey", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(batc.observations, file.path(dest.folder, paste0("observations", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(batc.samples, file.path(dest.folder, paste0("samples", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(batc.bulkCapture, file.path(dest.folder, paste0("bulkCapture", ".csv")), na = "", append = FALSE, col_names = TRUE)
