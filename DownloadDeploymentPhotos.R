library(magrittr)
keyring::key_set("AGOL", "mojn_data")
source(here::here("utils.R"))

#Meatdata only run
#PhotoTable <- DownloadAGOLAttachments("https://services1.arcgis.com/fBc8EJBxQRMcHlei/arcgis/rest/services/MOJN_BatsAcoustic_Database/FeatureServer/4", agol_username = "mojn_data", test_run = TRUE, custom_name = TRUE, prefix = PhotoName)

#Regular run
DownloadAGOLAttachments("https://services1.arcgis.com/fBc8EJBxQRMcHlei/arcgis/rest/services/MOJN_BatsAcoustic_Database/FeatureServer/4", agol_username = "mojn_data", test_run = FALSE, custom_name = TRUE, prefix = PhotoName)
