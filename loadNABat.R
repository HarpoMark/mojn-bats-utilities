#devtools::install_git("https://code.usgs.gov/fort/nabat/nabatr.git")
library(nabatr)

#Copy this token code from the API menu in the top right corner of the NABat Partner Portal
#Alternately: if you run token = get_nabat_gql_token(), it will prompt you for a username and then a password
token = list(refresh_token = 'eyJhbGciOiJIUzUxMiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJiOTNjODNiNy1hMjAxLTRlNTktYmNmNy0xYTU2ZDM1N2E2MDEifQ.eyJleHAiOjE3NDM3MTM3MzcsImlhdCI6MTc0MzcxMTkzNywianRpIjoiZmNkYzVhOTQtODczMC00ZmYzLTkxMDctN2EyOThhNmJiMDA0IiwiaXNzIjoiaHR0cHM6Ly9mb3J0LnVzZ3MuZ292L2F1dGgvcmVhbG1zL05BQkFUIiwiYXVkIjoiaHR0cHM6Ly9mb3J0LnVzZ3MuZ292L2F1dGgvcmVhbG1zL05BQkFUIiwic3ViIjoiYzJjY2NlNzEtZTZjNC00NjY0LTgyZDctZGVhZGMwZGE2M2EwIiwidHlwIjoiUmVmcmVzaCIsImF6cCI6Im5hYmF0LXByb2QiLCJub25jZSI6IjkzMDAwNjgyLTBkZmItNDM4ZC04N2EyLTkzOGYzMjU4MTIzZiIsInNlc3Npb25fc3RhdGUiOiJjOTE2NWVjMC0xYjE4LTRkNmUtODUwNC0wODE5YTcwZjQ4NTQiLCJzY29wZSI6Im9wZW5pZCBlbWFpbCBwcm9maWxlIiwic2lkIjoiYzkxNjVlYzAtMWIxOC00ZDZlLTg1MDQtMDgxOWE3MGY0ODU0In0.T-e08AdJ0-7GLgKSWgk1GTvZO-AM5p6ScMkd9cjXqbKdBxPo9vjB6TqeaaxtCFtE-oC7EUhp05Yw3D7hYnxQ7A', access_token = '', refresh_at = Sys.time())

# Get your projects lookup table
project_df = get_projects(token)
# Fill in project id using the project_df lookup table. 343 is MOJN acoustics
project_id = 343

# Get survey dataframe 
token = get_refresh_token(token)
sa_survey_df = get_sa_project_summary(token,project_df, project_id)
sa_proj_dates = unique(sa_survey_df$year)

#Get all WAV files
# Get stationary acoustic bulk upload format dataframe
#Select a year or all, year = 'all' or year = 2020
token = get_refresh_token(token)
year = 'all' 
sa_bulk_df = get_sa_bulk_wavs(token, 
                              sa_survey_df,
                              year)
                             
#Get nightly observed data
token = get_refresh_token(token)
species_df = get_species(token)
# Get Acoustic stationary acoustic bulk dataframe
nightly_observed_list = get_observed_nights(sa_bulk_df)

#Generate an Acoustic Report
# Edit these two variables below to your local system (file_name, out_dir)
file_name = 'MOJN_Acoustics_sa_report.docx'  
out_dir   = 'C:/Users/mlehman/Documents/R/export/nabatreports' # Make sure this ends without a '/'

sa_doc = build_sa_doc(out_dir = out_dir,
                      project_df = project_df,
                      project_id = project_id,
                      sa_bulk_df = sa_bulk_df,
                      sa_survey_df = sa_survey_df,
                      species_df = species_df,
                      selected_year = year,
                      nightly_observed_list = nightly_observed_list,
                      range_maps = TRUE)
# Save out your report
print(sa_doc, target = paste0(out_dir, '/', file_name))


#MOJN Wrangling

nabatr::get_sa_results(sa_bulk_df,'all',species_df)
manualidsbynight <- nightly_observed_list$manual_nightly_df




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

#bats.parkSiteSeasonYear<- bats %>%
#  dplyr::group_by(park, location_name, year,season, species_code) %>%
#  tally() %>%
#  spread(species_code,n)





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
