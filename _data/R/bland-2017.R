#bland-2017

# Load libraries
library(tidyverse)

# create output directory
  if(!dir.exists("_data/R/summaries")){dir.create("_data/R/summaries")}  
  if(!dir.exists("_data/R/temp")){dir.create("_data/R/temp")}

# set variables
  curator <- "https://opentraits.org/members/brian-s-maitner"
  dataset_url <- "https://opentraits.org/datasets/bland-2017"
  dataset <- "bland-2017"

# Get required metadata sample  
  trait_sample <- read.csv("traits-sample.csv")
  colnames(trait_sample)


# Download files (using manual, was getting errors with automated download)


  download.file(url = "https://raw.githubusercontent.com/LucieBland/Crayfish-extinction-risk/master/Crayfish_Species_Dataset.csv",
                destfile = file.path("_data/R/temp/bland-2017.csv"))
  
  traits <- read.csv(file.path("_data/R/temp/bland-2017.csv"))

#reformat
  
  traits %>%
    pivot_longer(cols = 5:ncol(.),names_to = "traitNameVerbatim") %>%
    filter(!is.na(value))%>%
    rename(scientificNameVerbatim = Binomial,
           family = Family)%>%
    select(intersect(colnames(.),
                     colnames(trait_sample))) %>%
    group_by(family, scientificNameVerbatim, traitNameVerbatim) %>%
    summarise(numberOfRecords = n())%>%
    mutate(datasetId = dataset_url,
           curator = curator,
           accessDate = Sys.Date()) -> traits
  
  # check output columns
  
  if(!all(colnames(traits) %in%   colnames(trait_sample))){stop("column name problem")}
  
  traits_summary <- traits
  
  # write output
  
  write.csv(traits_summary,
            file = file.path("_data/R/summaries/",paste(dataset,".csv",sep="")),
            row.names = F )
  
  R.utils::gzip(filename = file.path("_data/R/summaries/",paste(dataset,".csv",sep="")),
                destname = file.path("_data/R/summaries/",paste(dataset,".csv.gz",sep="")),
                overwrite = TRUE)
  
  unlink(file.path("_data/R/summaries/",paste(dataset,".csv",sep="")))
  unlink(file.path("_data/R/temp/"),recursive = TRUE)
  
  