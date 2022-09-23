ReadAGOL <- function(data_path, agol_username = "mojn_bats", agol_password = rstudioapi::askForPassword(paste("Please enter the password for AGOL account", agol_username))) {
  agol_layers <- FetchAGOLLayers(data_path, agol_username, agol_password)
  #data <- WrangleAGOLData(agol_layers)
  
  return(data)
}


FetchAGOLLayers <- function(data_path, lookup_path, sites_path, agol_username, agol_password) {
  # Get a token with a headless account
  token_resp <- httr::POST("https://nps.maps.arcgis.com/sharing/rest/generateToken",
                           body = list(username = agol_username,
                                       password = agol_password,
                                       referer = 'https://irma.nps.gov',
                                       f = 'json'),
                           encode = "form")
  agol_token <- jsonlite::fromJSON(httr::content(token_resp, type="text", encoding = "UTF-8"))
  
  agol_layers <- list()
  
  # Fetch sites table
  agol_layers$sites <- fetchAllRecords(sites_path, 0, token = agol_token$token)
  
  # Fetch lookup tables from lookup feature service
  lookup_names <- httr::GET(paste0(lookup_path, "/layers"),
                            query = list(where="1=1",
                                         outFields="*",
                                         f="JSON",
                                         token=agol_token$token))
  lookup_names <- jsonlite::fromJSON(httr::content(lookup_names, type = "text", encoding = "UTF-8"))
  lookup_names <- lookup_names$tables %>%
    dplyr::select(id, name) %>%
    dplyr::filter(grepl("MOJN_(Lookup|Ref)(_Lookup|_Ref)?_(DS|Shared)", name))  # (_Lookup|_Ref)? is to accommodate weirdly named Camera lookup - can be removed once fixed in AGOL
  
  lookup_layers <- lapply(lookup_names$id, function(id) {
    df <- fetchAllRecords(lookup_path, id, token = agol_token$token)
    return(df)
  })
  names(lookup_layers) <- lookup_names$name
  
  # Fetch each layer in the DS feature service
  

  # ----- Site -----
  agol_layers$Site <- fetchAllRecords(data_path, 0, token = agol_token$token) 
  
  # ----- Deployment -----
  agol_layers$visit <- fetchAllRecords(data_path, 3, token = agol_token$token) %>%
    dplyr::mutate(DeploymentDate = as.POSIXct(EditDate/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
    dplyr::mutate(RecordingStartDate = as.POSIXct(DateTime/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
    dplyr::mutate(RecordingStartTime = as.POSIXct(DateTime/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
    dplyr::mutate(RecoveryDate = as.POSIXct(DateTime/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
    dplyr::mutate(ActualStartDate = as.POSIXct(DateTime/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
    dplyr::mutate(ActualStopDate = as.POSIXct(DateTime/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
    dplyr::mutate(DataProcessingLevelDate = as.POSIXct(DateTime/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
    dplyr::mutate(CreationDate = as.POSIXct(DateTime/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
    dplyr::mutate(EditDate = as.POSIXct(DateTime/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
    dplyr::mutate(ExpectedEndDate = as.POSIXct(DateTime/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
    dplyr::mutate(ExpectedEndTime = as.POSIXct(DateTime/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) %>%
    dplyr::mutate(ActualStopTimeOld = as.POSIXct(DateTime/1000, origin = "1970-01-01", tz = "America/Los_Angeles")) 
  
 
  
  agol_layers <- c(agol_layers, lookup_layers)
  
  agol_layers <- lapply(agol_layers, function(data_table) {
    data_table <- data_table %>%
      dplyr::mutate(dplyr::across(where(is.character), function(x) {
        x %>%
          utf8::utf8_encode() %>%  # Encode text as UTF-8 - this prevents a lot of parsing issues in R
          trimws() %>%  # Trim leading and trailing whitespace
          dplyr::na_if("")  # Replace empty strings with NA
      }))
    col_names <- names(data_table)
    name_and_label <- grepl("(name)|(label)", col_names, ignore.case = TRUE)
    names(data_table)[name_and_label] <- tolower(names(data_table[name_and_label]))
    
    return(data_table)
  })
  
  return(agol_layers)
}


#' Fetch tabular data from AGOL
#' 
#' Retrieves tabular data from AGOL layers and tables, even when number of rows exceeds maximum record count.
#'
#' @param data_path Feature service URL
#' @param layer_number Layer number
#' @param token Authentication token (optional)
#' @param geometry Include spatial data columns? Works with points, not tested with other geometry types
#' @param where Query clause specifying a subset of rows (optional; defaults to all rows). See AGOL REST API documentation.
#' @param outFields String indicating which fields to return (optional; defaults to all fields). See AGOL REST API documentation.
#'
#' @return A tibble
#' @export
#'

fetchAllRecords <- function(data_path, layer_number, token, geometry = FALSE, where = "1=1", outFields = "*") {
  result <- tibble::tibble()
  exc_transfer <- TRUE
  offset <- nrow(result)
  
  qry <- list(where = where,
              outFields = outFields,
              f = "JSON",
              resultOffset = offset)
  
  if (!missing(token)) {
    qry$token <- token
  }
  
  while(exc_transfer) {
    resp <- httr::GET(paste0(data_path, "/", layer_number, "/query"),
                      query = qry)
    
    content <- jsonlite::fromJSON(httr::content(resp, type = "text", encoding = "UTF-8"))
    
    if ("exceededTransferLimit" %in% names(content)) {
      exc_transfer <- content$exceededTransferLimit
    } else {
      exc_transfer <- FALSE
    }
    
    if (geometry) {
      partial_result <- cbind(content$features$attributes, content$features$geometry) %>%
        dplyr::mutate(wkid = content$spatialReference$wkid) %>%
        tibble::as_tibble()
    } else {
      partial_result <- tibble::as_tibble(content$features$attributes)
    }
    result <- rbind(result, partial_result)
    offset <- nrow(result)
    qry$resultOffset <- offset
  }
  return(result)
}





LoadBatsAcoustic <- function(data_path = "https://services1.arcgis.com/fBc8EJBxQRMcHlei/arcgis/rest/services/MOJN_BatsAcoustic_Database/FeatureServer", ...) {
  
  # Figure out the format of the data
  agol_regex <- "^https:\\/\\/services1\\.arcgis\\.com\\/[^\\\\]+\\/arcgis\\/rest\\/services\\/[^\\\\]+\\/FeatureServer\\/?$"
  is_agol <- grepl(agol_regex, data_path)
  is_db <- grepl("^database$", data_path, ignore.case = TRUE)
  if (!is_agol & !is_db) {
    # Standardize data path
    data_path <- normalizePath(data_path, mustWork = TRUE)
  }
  is_zip <- grepl("\\.zip$", data_path, ignore.case = TRUE) && file.exists(data_path)
  is_folder <- dir.exists(data_path)
  
  if (is_agol) {  # Read from AGOL feature layer
    data <- ReadAGOL(data_path)  # TODO
  } else if (is_db) {  # Read from SQL Server database
    data <- ReadSqlDatabase(...)
  } else if (is_zip | is_folder) {  # Read from folder of CSV's (may be zipped)
    data <- ReadCSV(data_path)
  } else {
    stop(paste("Data path", data_path, "is invalid. See `?LoadBatsAcoustic` for more information."))
  }
  
  # Tidy up the data
  data <- lapply(data, function(df) {
    df %>%
      dplyr::mutate_if(is.character, utf8::utf8_encode) %>%
      dplyr::mutate_if(is.character, trimws, whitespace = "[\\h\\v]") %>%  # Trim leading and trailing whitespace
      dplyr::mutate_if(is.character, dplyr::na_if, "") %>%  # Replace empty strings with NA
      dplyr::mutate_if(is.numeric, dplyr::na_if, -9999) %>%  # Replace -9999 or -999 with NA
      dplyr::mutate_if(is.numeric, dplyr::na_if, -999) %>%
      dplyr::mutate_if(is.character, dplyr::na_if, "NA") %>%  # Replace "NA" strings with NA
      dplyr::mutate_if(is.character, stringr::str_replace_all, pattern = "[\\v]+", replacement = ";  ")  # Replace newlines with semicolons - reading certain newlines into R can cause problems
  })
  
  # Actually load the data into an environment for the package to use
  tbl_names <- names(data)
  lapply(tbl_names, function(n) {assign(n, data[[n]], envir = pkg_globals)})
  
  invisible(data)
}



