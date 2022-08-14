### consolidating individual csv files to a file matching the whole template
library(dplyr)

root.dir <- getwd()

#if(!dir.exists("_data/R/temp_consolidate")){dir.create("_data/R/temp_consolidate")}
list.zip <- list.files(path = "_data/R/summaries", pattern="csv.gz")

setwd("_data/R/summaries/")

all.data <- list()

for (i in 1:length(list.zip)){
  R.utils::gunzip(list.zip[i], overwrite=T, remove=F)
  all.data[[gsub(".csv.gz","",list.zip[i])]] <- read.table(paste("./",gsub("csv.gz","csv",list.zip[i]),sep=""), sep=",", header=T)
}

setwd(root.dir)

columnNames <- c("taxonIdVerbatim","scientificNameVerbatim","resolvedTaxonId","resolvedTaxonName","parentTaxonId","family","phylum","traitIdVerbatim","traitNameVerbatim","bucketId","bucketName","counts","datasetId","numberOfRecords","curator","accessDate")

headerTable = data.frame(matrix(vector(), 1, length(columnNames),
                        dimnames=list(c(), columnNames)),
                        stringsAsFactors=F)


for (z in 1:length(names(all.data))){
  if(!is.null(all.data[[z]]$taxonIdVerbatim)){all.data[[z]]$taxonIdVerbatim <- as.character(all.data[[z]]$taxonIdVerbatim)}
  headerTableT <- bind_rows(headerTable,all.data[[z]])
  headerTable <- headerTableT
}

# account for species level resolution in taxonomy here 
  
tail(headerTable)
write.csv(file="_data/R/summaries/_all.csv",headerTable, row.names = F)
gzip("_data/R/summaries/_all.csv",destname="_data/R/_all.csv.gz",overwrite=T)
unlink("_data/R/summaries/*.csv")
