#compadre

# Load libraries
library(tidyverse)
library(Rcompadre)

# create output directory
if(!dir.exists("_data/R/summaries")){dir.create("_data/R/summaries")}  
if(!dir.exists("_data/R/temp")){dir.create("_data/R/temp")}

# set variables
curator <- "https://opentraits.org/members/brian-s-maitner"
dataset_url <- "https://opentraits.org/datasets/compadre"
dataset <- "compadre"

# Get required metadata sample  
trait_sample <- read.csv("traits-sample.csv")
colnames(trait_sample)

# Download files (using R package)

compadre <- cdb_fetch("compadre") # or use 'comadre' for the animal database
comadre <- cdb_fetch("comadre")

compadre %>%
  as.data.frame()%>%
  rename(scientificNameVerbatim = SpeciesAccepted,
         family = Family,
         phylum = Phylum) %>%
  select(intersect(colnames(.),
                   colnames(trait_sample)))%>%
  mutate(traitNameVerbatim = "matrix population models") -> compadre

comadre %>%
  as.data.frame()%>%
  rename(scientificNameVerbatim = SpeciesAccepted,
         family = Family,
         phylum = Phylum) %>%
  select(intersect(colnames(.),
                   colnames(trait_sample)))%>%
  
  mutate(traitNameVerbatim = "matrix population models") -> comadre

compadre %>%
  bind_rows(comadre) %>%
  group_by(phylum, family, scientificNameVerbatim, traitNameVerbatim) %>%
  summarise(numberOfRecords = n())%>%
  mutate(datasetId = dataset_url,
         curator = curator,
         accessDate = Sys.Date(),
         comment = "'the traitNameVerbatim field is a bit tricky to apply here and more thought is needed") -> traits
  

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



