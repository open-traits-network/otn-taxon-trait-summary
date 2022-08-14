#bennett-2018
#10.1038/sdata.2018.22

library(reshape2)
library(dplyr)
library(readxl)
library(rdryad)

# create output directory
  if(!dir.exists("_data/R/summaries")){dir.create("_data/R/summaries")}  
  if(!dir.exists("_data/R/temp")){dir.create("_data/R/temp")}

# set variables
  curator <- "https://opentraits.org/members/brian-s-maitner"
  dataset_url <- "https://opentraits.org/datasets/bennett-2018"
  dataset <- "bennett-2018"

# Download file
  dataset_dryad <- rdryad::dryad_dataset(dois = "10.5061/dryad.1cv08")
  dryad_files <- rdryad::dryad_download(dois = "10.5061/dryad.1cv08")

# Read in file
  traits <- read.csv(file = dryad_files$`10.5061/dryad.1cv08`[1])

# Get required metadata sample  
  trait_sample <- read.csv("traits-sample.csv")
  colnames(trait_sample)
  
# Combine traits into a "trait name" 
  
  traits %>%
    mutate(scientificNameVerbatim = paste(Genus, Species, sep = " "))%>%
    rename(phylum = Phylum,
           family = Family) -> traits


  traits %>%
    mutate(tmin = as.numeric(tmin))%>%
    pivot_longer(cols = c(Tmax, Tmax_2 , tmin, tmin_2),
                 names_to = "traitNameVerbatim",
                 values_to = "traitValue")%>%
    filter(!is.na(traitValue)) %>%
    mutate(datasetId = dataset_url,
           curator = curator,
           accessDate = Sys.Date()
           ) %>%
    select(intersect(colnames(.),
                     colnames(trait_sample))) -> traits
  

  traits %>%
    mutate(traitNameVerbatim = gsub(pattern = "_2",
                                    replacement = "",
                                    x = traitNameVerbatim)) %>%
    group_by(phylum,
              family,
              scientificNameVerbatim,
              traitNameVerbatim,
              datasetId,
              curator,
              accessDate) %>%
    summarize(numberOfRecords = n()) ->traits

    

  if(!all(colnames(traits) %in%   colnames(trait_sample))){stop("column name problem")}
  
  traits_summary <- traits
  
  #write output
  
  write.csv(traits_summary,
            file = file.path("_data/R/summaries/",paste(dataset,".csv",sep="")),
            row.names = F )
  
  R.utils::gzip(filename = file.path("_data/R/summaries/",paste(dataset,".csv",sep="")),
                destname = file.path("_data/R/summaries/",paste(dataset,".csv.gz",sep="")),
                overwrite = TRUE)
  
  unlink(file.path("_data/R/summaries/",paste(dataset,".csv",sep="")))
  