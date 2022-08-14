#bien

# Load libraries
library(BIEN)

# create output directory
if(!dir.exists("_data/R/summaries")){dir.create("_data/R/summaries")}  
if(!dir.exists("_data/R/temp")){dir.create("_data/R/temp")}

# set variables
curator <- "https://opentraits.org/members/brian-s-maitner"
dataset_url <- "https://opentraits.org/datasets/bien"
dataset <- "bien"

# Get required metadata sample  
trait_sample <- read.csv("traits-sample.csv")
colnames(trait_sample)

# Download data

  # traits_og <- BIEN_trait_traits_per_species()
  

  traits <- 
  BIEN:::.BIEN_sql(query = "SELECT DISTINCT scrubbed_species_binomial,
                                            trait_name,
                                            taxon_id,
                                            scrubbed_family,
                                            count(*)
                            FROM agg_traits 
                            GROUP BY trait_name, scrubbed_species_binomial, scrubbed_family, taxon_id
                            ORDER BY scrubbed_species_binomial,trait_name ;")
  

# reformat
  
  traits %>%
    rename(taxonIdVerbatim = taxon_id,
    scientificNameVerbatim = scrubbed_species_binomial,
    family = scrubbed_family,
    traitNameVerbatim = trait_name,
    numberOfRecords = count) %>%
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
  
  
  
  