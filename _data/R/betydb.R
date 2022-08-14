#betydb

library(traits)

# create output directory
  if(!dir.exists("_data/R/summaries")){dir.create("_data/R/summaries")}  
  if(!dir.exists("_data/R/temp")){dir.create("_data/R/temp")}

# set variables
  curator <- "https://opentraits.org/members/brian-s-maitner"
  dataset_url <- "https://opentraits.org/datasets/betydb"
  dataset <- "betydb"

# Get required metadata sample  
  trait_sample <- read.csv("traits-sample.csv")
  colnames(trait_sample)


# Download files
  traits <- betydb_query()

# reformat
  
  
  traits %>%
    rename(taxonIdVerbatim = species_id,
           scientificNameVerbatim = scientificname,
           traitNameVerbatim = trait_description) %>%
    select(intersect(colnames(.),
                     colnames(trait_sample))) %>%
    group_by(scientificNameVerbatim, taxonIdVerbatim, traitNameVerbatim) %>%
    summarise(numberOfRecords = n()) %>%
    mutate(datasetId = dataset,
           curator = curator,
           accessDate = Sys.Date()) -> traits
  
  traits %>%
    filter(!is.na(scientificNameVerbatim),
           scientificNameVerbatim != "",
           !is.na(traitNameVerbatim),
           traitNameVerbatim != "") -> traits

  traits_summary <- traits
  
  #write output
  
  write.csv(traits_summary,
            file = file.path("_data/R/summaries/",paste(dataset,".csv",sep="")),
            row.names = F )
  
  R.utils::gzip(filename = file.path("_data/R/summaries/",paste(dataset,".csv",sep="")),
                destname = file.path("_data/R/summaries/",paste(dataset,".csv.gz",sep="")),
                overwrite = TRUE)
  
  unlink(file.path("_data/R/summaries/",paste(dataset,".csv",sep="")))
  