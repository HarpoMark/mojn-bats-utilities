dir(path = listOfFolders, full.names = T) %>% # on W, use pattern="^your_pattern"
  (function(fpath){
    ftime <- file.mtime(fpath) # file.info(fpath)$ctime for file CREATED time
    return(fpath[which.max(ftime)]) # returns the most recent file path
  })


#get a vector of all filenames
myfiles <- list.files(path="E:/MOJN_Bats/MOJN_2022_Winter_Raw/LAKE_57481_SE1_20220211",pattern = ".WAV",full.names = TRUE,recursive = TRUE)

#get the directory names of these (for grouping)
mydirs <- dirname(myfiles)

#find the last file in each directory (i.e. latest modified time)
lastfiles <- tapply(myfiles,mydirs,function(v) v[which.max(file.mtime(v))])
test

list.files("E:/MOJN_Bats/MOJN_2022_Winter_Raw/LAKE_57481_SE1_20220211",full.names = T, pattern = ".WAV",recursive = TRUE) %>% 
  enframe(name = NULL) %>% 
  bind_cols(pmap_df(., file.info)) %>% 
  filter(mtime==max(mtime)) %>% 
  pull(mtime)


df_Filelist <- file.info(list.files(listOfFolders, full.names = T,pattern = ".WAV",recursive = TRUE))
df_mm <- c(min(df_Filelist$mtime),max(df_Filelist$mtime))


# folderStats <- data.frame(matrix(ncol = 4, nrow =0))
# colnames(folderStats) <- c('deployment', 'callcount','firstcall', 'lastcall')
# 
# for (folder in listOfFolders){
#   filelist <- file.info(list.files(folder, full.names = T,pattern = ".WAV",recursive = TRUE))
#   folderStats[nrow(folderStats) + 1,] = c(folder,nrow(filelist)+1,min(filelist$mtime),max(filelist$mtime))
# }