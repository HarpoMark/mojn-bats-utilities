##EXPORTS
##Note that the following exports include all species codes including LowF, HighF, Noise, LACITABR
##Future versions should include the ability to filter for just single species codes

bats <- sa_bulk_df %>%
  dplyr::inner_join(species_df, join_by(manual_id == id)) %>%
  dplyr::mutate("year" = case_when(month(recording_night)==12 ~ year(recording_night)+1,
                                   TRUE ~ year(recording_night)),
                "season" = case_when(month(recording_night)==12 ~ 'Winter',
                                     month(recording_night)<4 ~ 'Winter',
                                     TRUE ~ 'Summer')
  ) %>%
  dplyr::select(survey_event_id, "park" = land_unit_code,
                location_name,
                year,
                season,
                recording_night,
                recording_time,
                species_code,species,common_name,
                water_type,
                distance_to_water,
                clutter_percent,
                distance_to_clutter_meters,
                unusual_occurrences,
                grts_cell_id
  )

bats.park<- bats %>%
  dplyr::group_by(park, species_code) %>%
  tally() %>%
  pivot_wider(names_from = species_code,values_from = n, values_fill=0, values_fn = ~1)

bats.GRTS <- bats %>%
  dplyr::group_by(grts_cell_id, species_code) %>%
  tally() %>%
  pivot_wider(names_from = species_code,values_from = n, values_fill=0, values_fn = ~1)

bats.parkYear<- bats %>%
  dplyr::group_by(park, year, species_code) %>%
  tally() %>%
  pivot_wider(names_from = species_code,values_from = n, values_fill=0, values_fn = ~1)

bats.parkSeasonYear<- bats %>%
  dplyr::group_by(park, year,season, species_code) %>%
  tally() %>%
  pivot_wider(names_from = species_code,values_from = n, values_fill=0, values_fn = ~1)

bats.parkSiteSeasonYear<- bats %>%
  dplyr::group_by(park, location_name, year,season, species_code) %>%
  tally() %>%
  pivot_wider(names_from = species_code,values_from = n, values_fill=0, values_fn = ~1)



# Set output folder for CSV exports
dest.folder <- paste0("C:/Users/mlehman/Documents/R/export/bats","/",format(Sys.time(), format="%Y-%m-%dT%H%M%S"))

if (file.exists(dest.folder)) {
  cat("The folder already exists")
} else {
  dir.create(dest.folder)
}

# Export results to CSV files
readr::write_csv(bats, file.path(dest.folder, paste0("NABat_Manual_detections", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(bats.GRTS, file.path(dest.folder, paste0("NABat_Manual_GRTS", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(bats.park, file.path(dest.folder, paste0("NABat_Manual_park", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(bats.parkYear, file.path(dest.folder, paste0("NABat_Manual_parkYear", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(bats.parkSeasonYear, file.path(dest.folder, paste0("NABat_Manual_parkSeasonYear", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(bats.parkSiteSeasonYear, file.path(dest.folder, paste0("NABat_Manual_parkSiteSeasonYear", ".csv")), na = "", append = FALSE, col_names = TRUE)
readr::write_csv(manualidsbynight, file.path(dest.folder, paste0("NABat_Manual_idsByNight", ".csv")), na = "", append = FALSE, col_names = TRUE)
