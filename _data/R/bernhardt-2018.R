#bernhardt-2018


# create output directory
  if(!dir.exists("_data/R/summaries")){dir.create("_data/R/summaries")}  
  if(!dir.exists("_data/R/temp")){dir.create("_data/R/temp")}

# set variables
  curator <- "https://opentraits.org/members/brian-s-maitner"
  dataset_url <- "https://opentraits.org/datasets/bernhardt-2018"
  dataset <- "bernhardt-2018"

# Download files (manual, since behind a paywall otherwise)
  traits <- read.csv("_data/R/manual_downloads/bernhardt-2018.csv")

# Get required metadata sample  
  trait_sample <- read.csv("traits-sample.csv")
  colnames(trait_sample)
  
#reformat  
  traits %>%
    mutate(across(everything(), as.character))%>%
    pivot_longer(cols = 4:38,
                 names_to = "traitNameVerbatim")%>%
    rename(scientificNameVerbatim = species_GermanSL,
           family = Familie) %>%
    filter(value != "",
           !is.na(value)) %>%
    select(intersect(colnames(.),
                     colnames(trait_sample))) %>%
    group_by(family, scientificNameVerbatim,traitNameVerbatim)%>%
    summarise(numberOfRecords = n()) %>%
    mutate(datasetId = dataset_url,
           curator = curator,
           accessDate = Sys.Date(),
           comment = "'Also available within TRY'") -> traits
  
  traits_summary <- traits
  
#write output
  
  write.csv(traits_summary,
            file = file.path("_data/R/summaries/",paste(dataset,".csv",sep="")),
            row.names = F )
  
  R.utils::gzip(filename = file.path("_data/R/summaries/",paste(dataset,".csv",sep="")),
                destname = file.path("_data/R/summaries/",paste(dataset,".csv.gz",sep="")),
                overwrite = TRUE)
  
  unlink(file.path("_data/R/summaries/",paste(dataset,".csv",sep="")))
  
