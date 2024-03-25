dest.folder <- paste0("C:/Users/mlehman/Documents/R/exports/bats","/",format(Sys.time(), format="%Y-%m-%dT%H%M%S"))

if (file.exists(dest.folder)) {
    cat("The folder already exists")
  } else {
    dir.create(dest.folder)
  }

readr::write_csv(bat.site, file.path(dest.folder, paste0("site", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(bat.deployment, file.path(dest.folder, paste0("deployment", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(bat.detection, file.path(dest.folder, paste0("detection", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(bat.mics, file.path(dest.folder, paste0("mics", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(bat.detectors, file.path(dest.folder, paste0("detectors", ".csv")), na = "", append = FALSE, col_names = TRUE)


readr::write_csv(deployment_metadata_S123, file.path(dest.folder, paste0("deployment_metadata", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(detection_metadata, file.path(dest.folder, paste0("detection_metadata", ".csv")), na = "", append = FALSE, col_names = TRUE)

readr::write_csv(bat.times2, file.path(dest.folder, paste0("bat_times", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(deploymentfilecount, file.path(dest.folder, paste0("file_Count", ".csv")), na = "", append = FALSE, col_names = TRUE)

readr::write_csv(folder_stats, file.path(dest.folder, paste0("File_count_and_range", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(SummerStats, file.path(dest.folder, paste0("SummerFile3_count_and_range", ".csv")), na = "", append = FALSE, col_names = TRUE)


readr::write_csv(bat.metadata, file.path(dest.folder, paste0("deployment_metadata_raw", ".csv")), na = "", append = FALSE, col_names = TRUE)
