#brot

#https://figshare.com/articles/dataset/BROT_plant_functional_trait_database_Data_file/5280868?backTo=/collections/BROT_2_0_A_functional_trait_database_for_Mediterranean_Basin_plants/3843841

# Load libraries
library(tidyverse)

# create output directory
if(!dir.exists("_data/R/summaries")){dir.create("_data/R/summaries")}  
if(!dir.exists("_data/R/temp")){dir.create("_data/R/temp")}

# set variables
curator <- "https://opentraits.org/members/brian-s-maitner"
dataset_url <- "https://opentraits.org/datasets/brot"
dataset <- "brot"

# Get required metadata sample  
trait_sample <- read.csv("traits-sample.csv")
colnames(trait_sample)


# Download files (using manual, was getting errors with automated download)

download.file(url = "https://figshare.com/ndownloader/files/11194784",
              destfile = file.path("_data/R/temp/brot.csv"))

traits <- read.csv(file.path("_data/R/temp/brot.csv"))

# reformat

traits %>%
  rename(taxonIdVerbatim = TaxonID,
         scientificNameVerbatim = Taxon,
         traitNameVerbatim = Trait) %>%
  select(intersect(colnames(.),
                   colnames(trait_sample))) %>%
  group_by(taxonIdVerbatim,scientificNameVerbatim, traitNameVerbatim) %>%
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




