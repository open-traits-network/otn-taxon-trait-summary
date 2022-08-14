#beukhof-2019

# https://store.pangaea.de/Publications/Beukhof-etal_2019/TraitCollectionFishNAtlanticNEPacificContShelf.xlsx
# https://store.pangaea.de/Publications/Beukhof-etal_2019/SupplementaryInformationTraitCollection.pdf

# Load libraries
  library(xlsx)

# create output directory
  if(!dir.exists("_data/R/summaries")){dir.create("_data/R/summaries")}  
  if(!dir.exists("_data/R/temp")){dir.create("_data/R/temp")}

# set variables
  curator <- "https://opentraits.org/members/brian-s-maitner"
  dataset_url <- "https://opentraits.org/datasets/beukhof-2019"
  dataset <- "beukhof-2019"
  
# Get required metadata sample  
  trait_sample <- read.csv("traits-sample.csv")
  colnames(trait_sample)
  

# Download files (using manual, was getting errors with automated download)
  
    # download.file(url = "https://store.pangaea.de/Publications/Beukhof-etal_2019/TraitCollectionFishNAtlanticNEPacificContShelf.xlsx",
    #               destfile = file.path("_data/R/temp/beukhof-2019.xlsx"))
    # 
    # traits <- read.xlsx(file = file.path("_data/R/temp/beukhof-2019.xlsx"),sheetIndex = 1)
  
  traits <- read.xlsx(file = file.path("_data/R/manual_downloads/beukhof-2019.xlsx"), sheetIndex = 1)

# reformat
  
  traits %>%
    mutate(across(everything(), as.character))%>%
    pivot_longer(cols = c("habitat",
                          "feeding.mode",
                          "tl",
                          "body.shape",
                          "fin.shape",
                          "AR",
                          "offspring.size",
                          "spawning.type",
                          "age.maturity",
                          "fecundity",
                          "length.infinity",
                          "growth.coefficient",
                          "length.max",
                          "age.max"),
                 names_to = "traitNameVerbatim") %>%
      mutate(scientificNameVerbatim = paste(genus,species,sep = " ")) %>%
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
  
  
