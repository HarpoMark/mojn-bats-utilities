#LEGACY VERSION - Use countWAVFiles instead
library(magrittr)
library(lubridate)
library(tidyverse)

##########EDIT THIS SECTION ONLY #############

searchFolder <- "D:/TUSK_Summer"

##########End of editable section#############

listOfFolders <- list.dirs(path=searchFolder,full.names = TRUE, recursive = FALSE)

folder_stats <- sapply(listOfFolders, function(folder) {
  filelist <- file.info(list.files(folder, full.names = T,pattern = ".WAV",recursive = TRUE,ignore.case=TRUE))
  #filelist <- system("ls -fR", intern = TRUE)
  #filelist <- filelist[grep("\\.wav$", filelist, ignore.case = TRUE)]
  #filelist <- file.info(filelist)
  #filelist <- system("ls -fR", intern = TRUE)
  #filelist <- filelist[grep("\\.wav$", filelist, ignore.case = TRUE)]
  #filelist <- file.info(filelist)

  my_stats <- tibble::tibble(deployment = folder,
                             callcount = nrow(filelist),
                             firstcall = min(filelist$mtime),
                             lastcall = max(filelist$mtime)
  )
  print(folder)
  return(my_stats)
}, simplify = FALSE) %>%
  dplyr::bind_rows()

