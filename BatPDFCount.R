# Script written to compare the number of wav files noted in the bat database to the number of wav files on a drive
# Rebecca Key is able to output a csv file that has the count of wav files by site. I import this csv file and
# compare that number to the number of wav files on the hard drive before archiving and creating clones.
# Written by: Al Kirschbaum
# Date: 3/26/18

# Modified for MOJN use (lehman), included added ability to sum file counts from multiple memory cards
#
# This script requires a database export saved as CSV as input. The query qry_FileCountExport has been created for this 
# purpose. You will need to adjust the query parameters for the desired field season.
# Save the results of this query without headers as a CSV. Do not add any additional columns. 
# You will be prompted to point to this query, and you will also need to point to a folder location that 
# contains all of the WAV files for a matching time period.

# Package check/management --------------------------------------------------------
list.of.pkgs <- c("dplyr","xlsx","rChoiceDialogs")
new.pkgs <- list.of.pkgs[!(list.of.pkgs %in% installed.packages()[,"Package"])]
if(length(new.pkgs)) install.packages(new.pkgs, repos='http://cran.rstudio.com/')
library (dplyr)
library(xlsx) #exporting and reading xlsx
library (rChoiceDialogs) #better user interface dialog box

# User inputs --------------------------------------------------------
# this file needs to contain the following columns: year, park, site_cell, location, deploy, and wav...in this order
# the columns don't need to be named, b/c we will name them as they're imported
#file <- rchoose.files(default="C:/Users/akirschbaum/documents",caption="Select csv file from RK")
#db_data <- read.csv (file, header = F, col.names = c("year","park","site_cell","location","deploy","db_wav_cnt"))

# Folder containing wav files for current year
# choose the root folder containing all of the parks, such as 'Bat_corrected_2017'
fromFolder <- rchoose.dir(default = "d:/",caption="Folder contain deployment folders, example D:Bat_2016_Raw")
fromFolder <- gsub("\\","/",fromFolder,fixed=T)
year.list <- c('2020Winter','2020Summer')
i <- menu(year.list,graphics = T,title = "Choose year")
year <- year.list[i]

# create a list of folders w/in the folder from above, this list will be used in the loop below
listOfFolders <- list.dirs(path=fromFolder,full.names = TRUE, recursive = FALSE)

# create two empty lists to store information during the loop process
list_loc <- list()
list_wav <- list()

# the loop goes into the first folder (i=APIS), then w/in this folder creates a list (sub) of those folders (sites)
for (i in listOfFolders){
  print (i)
  listOfWavs <- list.files(i,pattern="\\.pdf$",recursive = F,full.names = T,ignore.case = T)
  len <- length(listOfWavs)
  print (len)  
  path_split <- strsplit(i,'[/]')
  loc_name <- path_split[[1]][4]
  print (loc_name)
  #2606
  list_loc <- c(list_loc,loc_name)
  list_wav <- c(list_wav,len)
  #"F:/Bat_corrected_2017/APIS"
  #subs <- list.dirs(path=i, full.names=TRUE,recursive=FALSE)
  #print (subs)
  #for (s in subs){
  #  print (s)
    #"F:/Bat_corrected_2017/APIS/APIS026A"
   # path_split <- strsplit(s,'[/]')
  #  loc_name <- path_split[[1]][4]
  #  print (loc_name)
    #"APIS026A"
   # listOfWavs <- list.files(s,pattern="\\.pdf$",recursive = T,full.names = T,ignore.case = T)
  #  len <- length(listOfWavs)
  #  print (len)
    #2606
   # list_loc <- c(list_loc,loc_name)
  #  list_wav <- c(list_wav,len)
  #}
}
# There are now two populated lists, one with site names, one with the number of wav files in that site folder
# You have to do a fair amount of programming to convert the list into a normal dataframe. This was the path of
# least resistance when I was writing this program. If I had the time, I would try to populate data frames instead of lists.

# the length the future data frame is needed
len <- length(list_loc)
# convert the lists to a dataframe
df_loc <- data.frame(matrix(unlist(list_loc),nrow=len,byrow = T),stringsAsFactors = F)
df_wav <- data.frame(matrix(unlist(list_wav),nrow=len,byrow = T),stringsAsFactors = F)
df <- cbind (df_loc,df_wav)
df1 <- df %>%
  rename (deployment=matrix.unlist.list_loc...nrow...len..byrow...T.,PDFCount=matrix.unlist.list_wav...nrow...len..byrow...T.)
df2 <- df1 

st=format(Sys.time(),"%Y%m%d_%H%M")
write.xlsx(df2,file=paste0(fromFolder,"/","PDF_Count_",year,"_",st,".xlsx"),row.names = F)
# now I can compare the db results to the drive results
#db_data <- rename (db_data, location=Loc)
#db_drive_compare <- right_join(db_data,df2, by='location')
#db_drive_compare$compare <- db_drive_compare$db_wav_cnt - db_drive_compare$drive_wav
#st=format(Sys.time(),"%Y%m%d_%H%M")
#write.xlsx(db_drive_compare,file=paste0(fromFolder,"/","WAV_Count_",year,"_RightJoin_",st,".xlsx"),row.names = F)
#db_drive_compare_l <- left_join(db_data,df2, by='location')
#db_drive_compare_l$compare <- db_drive_compare_l$db_wav_cnt - db_drive_compare_l$drive_wav
#write.xlsx(db_drive_compare_l,file=paste0(fromFolder,"/","WAV_Count_",year,"_LeftJoin_",st,".xlsx"),row.names = F)