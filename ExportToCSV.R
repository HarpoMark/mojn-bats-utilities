dest.folder <- "C:/Users/mlehman/Documents/R/exports/bats"



readr::write_csv(bat.site, file.path(dest.folder, paste0("site", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(bat.deployment, file.path(dest.folder, paste0("deployment", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(bat.detection, file.path(dest.folder, paste0("detection", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(bat.mics, file.path(dest.folder, paste0("mics", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(bat.detectors, file.path(dest.folder, paste0("detectors", ".csv")), na = "", append = FALSE, col_names = TRUE)


readr::write_csv(deployment_metadata_S123, file.path(dest.folder, paste0("metadata_s123", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(detection_metadata, file.path(dest.folder, paste0("detection_metadata", ".csv")), na = "", append = FALSE, col_names = TRUE)