#Make GRTS Folders
library(dplyr)
seasonfilter <-"21S"

#Check if the folder "Data" exists in the current directory, if not creates it
ifelse(!dir.exists("Data"), dir.create("Data"), "Data folder exists already")
ifelse(!dir.exists(paste("Data/",seasonfilter,sep="")), dir.create(paste("Data/",seasonfilter,sep="")), "Field season folder exists already")


# NEED TO ADD FOLDER to MAKE SEASONFILTER FOLDER


filtereddeployments <-dplyr::left_join(bat.deployment, bat.site, by="SiteCode") %>%
    dplyr::filter(VisitGroupCode == seasonfilter) %>%
    dplyr::mutate(cell = substr(SiteCode, 0, 10)) %>%
    dplyr::select(GRTSCell, cell) %>%
    dplyr::distinct()

newfolder <- paste("Data/", seasonfilter,"/GRTS_",filtereddeployments$GRTSCell,sep="")
newfile <- paste("Data/", seasonfilter,"/GRTS_",filtereddeployments$GRTSCell,"/",filtereddeployments$cell,".txt",sep="")

sapply(newfolder, dir.create)
sapply(newfile, file.create)