#### Aggregate species x traits tables to produce summary tables ###
#TODO: revise with final column names, rediscuss final structure of tables, 
#save tables in a given place

require(data.table)

#to be replaced by link to Brian & Alex table once it's somewhere
dat <- fread("C:/Users/Caterina/Dropbox/Workshops/sDevTraits/sDevTraits2022/sample_largetable.csv")

funsum <- function(x)sum(!is.na(x))

## Overall summary for intro text
tot_record <- sum(dat$NumberOfRecords, na.rm = T)
tot_species <- length(unique(dat$resolvedTaxonName))
tot_trait <- length(unique(dat$traitNameVerbatim))
tot_dataset <- length(unique(dat$OTNdatasetID))



## Summary by trait (second table)
trait_summary <- dat[, c(lapply(.SD[, .(resolvedTaxonName)], funsum), 
                         lapply(.SD[, .(NumberOfRecords)], function(x)sum(x, na.rm=T))), 
                     by = c("bucketName", "OTNdatasetID")]


## Summary by taxa (third table)
taxon_summary <- dat[, c(lapply(.SD[, .(traitNameVerbatim)], funsum), 
                         lapply(.SD[, .(NumberOfRecords)], function(x)sum(x, na.rm=T))), 
                     by = c("phylum", "bucketName")]


## Summary of trait summary (first table)
trait_sum_summary <- trait_summary[, c(lapply(.SD[, .(resolvedTaxonName)], funsum), 
                                       lapply(.SD[, .(OTNdatasetID)], list)), 
                                   by = "bucketName"]
#clean list column
trait_sum_summary$OTNdatasetID <- gsub(",", " | ", trait_sum_summary$OTNdatasetID)
trait_sum_summary$OTNdatasetID <- gsub("\"", "", trait_sum_summary$OTNdatasetID)
trait_sum_summary$OTNdatasetID <- gsub("c(", "", trait_sum_summary$OTNdatasetID, fixed=TRUE)
trait_sum_summary$OTNdatasetID <- gsub(")", "", trait_sum_summary$OTNdatasetID, fixed=TRUE)

## Summary of traits and taxa
taxon_trait_summary <- dat[, c(lapply(.SD[, .(NumberOfRecords)], function(x)sum(x, na.rm=T)), 
                               lapply(.SD[, .(traitNameVerbatim)], list)), 
                           by = c("phylum", "bucketName")]
#clean list column
taxon_trait_summary$traitNameVerbatim <- gsub(",", " | ", taxon_trait_summary$traitNameVerbatim)
taxon_trait_summary$traitNameVerbatim <- gsub("\"", "", taxon_trait_summary$traitNameVerbatim)
taxon_trait_summary$traitNameVerbatim <- gsub("c(", "", taxon_trait_summary$traitNameVerbatim, fixed=TRUE)
taxon_trait_summary$traitNameVerbatim <- gsub(")", "", taxon_trait_summary$traitNameVerbatim, fixed=TRUE)