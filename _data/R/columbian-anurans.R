#columbian-anurans

# Load libraries
library(tidyverse)

# create output directory
if(!dir.exists("_data/R/summaries")){dir.create("_data/R/summaries")}  
if(!dir.exists("_data/R/temp")){dir.create("_data/R/temp")}

# set variables
curator <- "https://opentraits.org/members/brian-s-maitner"
dataset_url <- "https://opentraits.org/datasets/columbian-anurans"
dataset <- "columbian-anurans"

# Get required metadata sample  
trait_sample <- read.csv("traits-sample.csv")
colnames(trait_sample)

# Download files (using manual, was getting errors with automated download)

  # download.file(url = "https://esajournals.onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1002%2Fecy.2685&file=ecy2685-sup-0001-DataS1.zip",
  #               destfile = file.path("_data/R/temp/columbian-anurans.zip"))

  utils::unzip(zipfile = file.path("_data/R/manual_downloads/columbian-anurans.zip"),
               exdir = file.path("_data/R/temp"))

  traits <- read.csv(file.path("_data/R/temp/ColombianAnuranMorphology_individuals.txt"),sep = "\t")

# reformat

  traits %>%
    mutate(across(everything(), as.character))%>%
    rename(scientificNameVerbatim = Species,
            family = Family) %>%
    pivot_longer(cols = c(8,20:27),
                 names_to = "traitNameVerbatim")%>%
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
  
  
  
      