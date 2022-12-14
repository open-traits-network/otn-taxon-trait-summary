#load libraries

  library(tidyverse)

# create temporary directories

  if(!dir.exists("_data/R/temp")){dir.create("_data/R/temp")}
  if(!dir.exists("_data/R/summaries")){dir.create("_data/R/summaries")}  
  
# set variables
  curator <- "https://opentraits.org/members/brian-s-maitner"
  dataset <- "https://opentraits.org/datasets/try"
  

# Unzip file
  
  unzip(zipfile = "_data/R/manual_downloads/SpeciesTraitsCombinations4OTN_Family.zip",
        exdir = "_data/R/temp")

# read in file
  
  try <- read.csv(file = "_data/R/temp/SpeciesTraitsCombinations4OTN_Family.txt",
                  header = TRUE)
  
# rename columns
  
  try %>%
    rename(taxonIdVerbatim = AccSpeciesID,
           scientificNameVerbatim = AccSpeciesName,
           traitIdVerbatim = TraitID,
           traitNameVerbatim = TraitName,
           numberOfRecords = CountOfObsDataID,
           family = Family) %>%
    mutate(accessDate = Sys.Date(),
           datasetId = dataset,
           curator = curator
           ) -> try
  
# write as csv

  write.csv(x = try,
            file = "_data/R/temp/try.csv",
            row.names = FALSE)
  
#zip file

  R.utils::gzip(filename = "_data/R/temp/try.csv",
                destname = "_data/R/summaries/try.csv.gz",
                overwrite = TRUE)
  
#remove temp file

  unlink(file.path("_data/R/temp/"),recursive = TRUE)
  

  
