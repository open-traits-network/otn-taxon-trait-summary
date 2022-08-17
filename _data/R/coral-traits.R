#coral-traits

# Load libraries
library(tidyverse)
library(rfigshare)

# create output directory
if(!dir.exists("_data/R/summaries")){dir.create("_data/R/summaries")}  
if(!dir.exists("_data/R/temp")){dir.create("_data/R/temp")}

# set variables
curator <- "https://opentraits.org/members/brian-s-maitner"
dataset_url <- "https://opentraits.org/datasets/coral-traits"
dataset <- "coral-traits"

# Get required metadata sample  
  trait_sample <- read.csv("traits-sample.csv")
  colnames(trait_sample)

# Download files using rfigshare
 
    fs_download(2067414, mine = FALSE, session = NULL, urls_only = TRUE)%>%
      download.file(destfile = "_data/R/temp/coral-traits.zip", mode = "wb") #note: wb needed for some reason
    
#unzip  
  
  utils::unzip(zipfile = file.path("_data/R/temp",paste(dataset,".zip",sep = "")),
               exdir = file.path("_data/R/temp",dataset))

  traits <- list.files(file.path("_data/R/temp",dataset),recursive = TRUE,full.names = TRUE)
  traits <- traits[grep(pattern = "data.csv",x = traits)]
  traits <- read.csv(traits)

#reformat
  
  traits %>%
    rename(taxonIdVerbatim = specie_id,
           scientificNameVerbatim = specie_name,
           traitIdVerbatim = trait_id,
           traitNameVerbatim = trait_name) %>%
    group_by(taxonIdVerbatim,
             scientificNameVerbatim,
             traitIdVerbatim,
             traitNameVerbatim) %>%
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

#Potential columns  
    # "taxonIdVerbatim"
    # "scientificNameVerbatim"
    # "family"
    # "phylum"
    # "traitIdVerbatim"
    # "traitNameVerbatim"
    # 
    # "numberOfRecords"
    # 
    # "datasetId"
    # "curator"
    # "accessDate"
    # "comment"
  
  
  
  
  
  