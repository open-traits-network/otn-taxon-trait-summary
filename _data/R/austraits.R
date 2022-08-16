#austraits

# Load libraries
library(tidyverse)

# create output directory
if(!dir.exists("_data/R/summaries")){dir.create("_data/R/summaries")}  
if(!dir.exists("_data/R/temp")){dir.create("_data/R/temp")}

# set variables
curator <- "https://opentraits.org/members/brian-s-maitner"
dataset_url <- "https://opentraits.org/datasets/austraits"
dataset <- "austraits"

# Get required metadata sample  
trait_sample <- read.csv("traits-sample.csv")
colnames(trait_sample)

# Download files (using manual, was getting errors with automated download)
download.file(url = "https://zenodo.org/record/5112001/files/austraits-3.0.2.rds",
              destfile = file.path("_data/R/temp/austraits.rds"))

# read file

  traits <- readRDS(file.path("_data/R/temp/austraits.rds"))

  traits <- traits$traits
  
# reformat
  traits %>%
    rename(scientificNameVerbatim = taxon_name,
           traitNameVerbatim = trait_name) %>%
    group_by(scientificNameVerbatim, traitNameVerbatim) %>%
    summarise(numberOfRecords = n()) %>%
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
  