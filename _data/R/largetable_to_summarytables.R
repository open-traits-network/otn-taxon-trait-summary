#### Aggregate species x traits tables to produce summary tables ###
#TODO: rediscuss final structure of tables, where to save tables

#load libraries
require(data.table)

#functions
funsum <- function(x)length(unique(x))
funlist <- function(x)list(unique(x))

# Read in file
dat <-  fread("https://github.com/open-traits-network/otn-taxon-trait-summary/raw/main/traits.csv.gz")

## Overall summary for intro text
totals <- data.frame("tot_record" = sum(dat$numberOfRecords, na.rm = T),
                     "tot_species" = length(unique(dat$resolvedName)),
                     "tot_trait" = length(unique(dat$traitNameVerbatim)),
                     "tot_dataset" = length(unique(dat$datasetId)))

## Summary by trait (second table)
trait_summary <- dat[, c(lapply(.SD[, .(traitNameVerbatim)], funsum),
                         lapply(.SD[, .(resolvedName)], funsum), 
                         lapply(.SD[, .(numberOfRecords)], function(x)sum(x, na.rm=T))), 
                     by = c("resolvedTraitName", "datasetId")]


## Summary by taxa (third table)
taxon_summary <- dat[, c(lapply(.SD[, .(traitNameVerbatim)], funsum), 
                         lapply(.SD[, .(resolvedName)], funsum), 
                         lapply(.SD[, .(numberOfRecords)], function(x)sum(x, na.rm=T))), 
                     by = c("resolvedPhylumName")]



## Summary of trait summary (first table)
trait_sum_summary <- trait_summary[, c(lapply(.SD[, .(resolvedName)], function(x)sum(x, na.rm=T)),
                                       lapply(.SD[, .(resolvedName)], funsum), 
                                       lapply(.SD[, .(datasetId)], funlist)), 
                                   by = "resolvedTraitName"]
#clean list column
trait_sum_summary$datasetId <- gsub(",", " | ", trait_sum_summary$datasetId)
trait_sum_summary$datasetId <- gsub("\"", "", trait_sum_summary$datasetId)
trait_sum_summary$datasetId <- gsub("c(", "", trait_sum_summary$datasetId, fixed=TRUE)
trait_sum_summary$datasetId <- gsub(")", "", trait_sum_summary$datasetId, fixed=TRUE)

## Summary of traits and taxa
taxon_trait_summary <- dat[, c(lapply(.SD[, .(numberOfRecords)], function(x)sum(x, na.rm=T)), 
                               lapply(.SD[, .(traitNameVerbatim)], funlist)), 
                           by = c("resolvedPhylumName", "resolvedTraitName")]
#clean list column
taxon_trait_summary$traitNameVerbatim <- gsub(",", " | ", taxon_trait_summary$traitNameVerbatim, perl = T)
taxon_trait_summary$traitNameVerbatim <- gsub("\"", "", taxon_trait_summary$traitNameVerbatim)
taxon_trait_summary$traitNameVerbatim <- gsub("c(", "", taxon_trait_summary$traitNameVerbatim, fixed=TRUE)
taxon_trait_summary$traitNameVerbatim <- gsub(")", "", taxon_trait_summary$traitNameVerbatim, fixed=TRUE)


#rename columns
setnames(trait_summary, names(trait_summary), c("Trait_category", "Dataset", "Number_of_traits", "Number_of_species", "Number_of_records"))
setnames(taxon_summary, names(taxon_summary), c("Phylum", "Number_of_traits", "Number_of_species", "Number_of_records"))
names(trait_sum_summary) <- c("Trait_category", "Number_of_species", "Number_of_datasets", "Datasets")
setnames(taxon_trait_summary, names(taxon_trait_summary), c("Phylum", "Trait_category", "Number_of_records", "Trait_names"))

#save tables
fwrite(totals, file = "_data/overall_totals.csv")
fwrite(trait_summary, file = "_data/trait_summary.csv")
fwrite(taxon_summary, file = "_data/taxon_summary.csv")
fwrite(trait_sum_summary, file = "_data/trait_sum_summary.csv")
fwrite(taxon_trait_summary, file = "_data/taxon_trait_summary.csv")
