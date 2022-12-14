#load libraries

  library(tidyverse)

# create temporary directory

  if(!dir.exists("_data/R/temp")){dir.create("_data/R/temp")}

# create otuput directory

  if(!dir.exists("_data/R/summaries")){dir.create("_data/R/summaries")}  


# set variables
  curator <- "https://opentraits.org/members/brian-s-maitner"
  dataset <- "https://opentraits.org/datasets/australian-birds"

# Download file
  download.file(url = "https://figshare.com/ndownloader/files/3417176",
                destfile = "_data/R/temp/australian-birds.csv")

# Read in file
  ausbirds <-  read.table("_data/R/temp/australian-birds.csv",sep = ",",header = TRUE)
  
# Mutate into useful format
  
  ausbirds %>%
    mutate("scientificNameVerbatim" = paste(X4_Genus_name_2," ",X5_Species_name_2,sep = ""))%>%
    rename("family" = X10_Family_scientific_name_2) %>%
    pivot_longer(cols = c(96:110,112:192), names_to = "traitNameVerbatim", values_to = "traitvalues") -> ausbirds

  # NA removal
  ausbirds %>%
    filter(!is.na(traitvalues)) -> ausbirds
  

  ausbirds %>%
    dplyr::select(scientificNameVerbatim, family, traitNameVerbatim, traitvalues)%>%
    group_by(scientificNameVerbatim,family,traitNameVerbatim) %>%
    summarise(NumberOfRecords = n())%>%
    mutate(accessDate = Sys.Date(),
           datasetId = dataset,
           curator = curator) -> ausbirds
  
# toss malformed names

  ausbirds <- 
    ausbirds[which(as.numeric(sapply(X = ausbirds$scientificNameVerbatim,
        FUN = function(x){length(strsplit(x = x,
                              split = " ")[[1]])}))==2),]

# add comment about issue with file

 ausbirds$comment <- "'malformed entries in database perhaps due to comma placement issue'"

#write output

  write.csv(x = ausbirds,
            file = "_data/R/temp/australian-birds.csv",
            row.names = FALSE)
  
# zipping

  R.utils::gzip(filename = "_data/R/temp/australian-birds.csv",
       destname = "_data/R/summaries/australian-birds.csv.gz",
       overwrite = TRUE)
  
# clean up
  
  unlink(file.path("_data/R/temp/"), recursive = TRUE)
  
  
  
  
  
  
  
  
  
  
  
  