#### Aggregate species x traits tables to produce summary tables ###
#TODO: rediscuss final structure of tables, where to save tables

#load libraries
require(data.table)

#functions
funsum <- function(x)sum(!is.na(x))

# Read in file
dat <-  fread("https://github.com/open-traits-network/otn-taxon-trait-summary/raw/main/traits.csv.gz")

## Overall summary for intro text
totals <- data.frame("tot_record" = sum(dat$numberOfRecords, na.rm = T),
                     "tot_species" = length(unique(dat$resolvedName)),
                     "tot_trait" = length(unique(dat$traitNameVerbatim)),
                     "tot_dataset" = length(unique(dat$datasetId)))

## Summary by trait (second table)
trait_summary <- dat[, c(lapply(.SD[, .(resolvedName)], funsum), 
                         lapply(.SD[, .(numberOfRecords)], function(x)sum(x, na.rm=T))), 
                     by = c("resolvedTraitName", "datasetId")]


## Summary by taxa (third table)
taxon_summary <- dat[, c(lapply(.SD[, .(traitNameVerbatim)], funsum), 
                         lapply(.SD[, .(numberOfRecords)], function(x)sum(x, na.rm=T))), 
                     by = c("resolvedPhylumName", "resolvedTraitName")]


## Summary of trait summary (first table)
trait_sum_summary <- trait_summary[, c(lapply(.SD[, .(resolvedName)], funsum), 
                                       lapply(.SD[, .(datasetId)], list)), 
                                   by = "resolvedTraitName"]
#clean list column
trait_sum_summary$datasetId <- gsub(",", " | ", trait_sum_summary$datasetId)
trait_sum_summary$datasetId <- gsub("\"", "", trait_sum_summary$datasetId)
trait_sum_summary$datasetId <- gsub("c(", "", trait_sum_summary$datasetId, fixed=TRUE)
trait_sum_summary$datasetId <- gsub(")", "", trait_sum_summary$datasetId, fixed=TRUE)

## Summary of traits and taxa
taxon_trait_summary <- dat[, c(lapply(.SD[, .(numberOfRecords)], function(x)sum(x, na.rm=T)), 
                               lapply(.SD[, .(traitNameVerbatim)], list)), 
                           by = c("resolvedPhylumName", "resolvedTraitName")]
#clean list column
taxon_trait_summary$traitNameVerbatim <- gsub(",", " | ", taxon_trait_summary$traitNameVerbatim, perl = T)
taxon_trait_summary$traitNameVerbatim <- gsub("\"", "", taxon_trait_summary$traitNameVerbatim)
taxon_trait_summary$traitNameVerbatim <- gsub("c(", "", taxon_trait_summary$traitNameVerbatim, fixed=TRUE)
taxon_trait_summary$traitNameVerbatim <- gsub(")", "", taxon_trait_summary$traitNameVerbatim, fixed=TRUE)

#save tables
fwrite(totals, file = "overall_totals.csv", sep = ";")
fwrite(trait_summary, file = "trait_summary.csv", sep = ";")
fwrite(taxon_summary, file = "taxon_summary.csv", sep = ";")
fwrite(trait_sum_summary, file = "trait_sum_summary.csv", sep = ";")
fwrite(taxon_trait_summary, file = "taxon_trait_summary.csv", sep = ";")
