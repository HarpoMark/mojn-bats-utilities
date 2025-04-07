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
manualidsbynight <- nightly_observed_list$manual_nightly_df

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

