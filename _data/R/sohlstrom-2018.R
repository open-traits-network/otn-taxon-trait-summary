library(reshape2)
library(dplyr)
library(tidyverse)
library(R.utils)

root.dir = getwd()

# create output directory
if(!dir.exists("_data/R/summaries")){dir.create("_data/R/summaries")}  
if(!dir.exists("_data/R/temp")){dir.create("_data/R/temp")}

# set variables
curator <- "https://opentraits.org/members/alexander-keller"
dataset_url <- "https://opentraits.org/datasets/sohlstrom-2018"
dataset <- "sohlstrom-2018"

# Download file
download.file(url = "https://datadryad.org/stash/downloads/file_stream/21629",
              destfile = paste("_data/R/temp/",dataset, sep=""))
setwd("_data/R/temp")

# unzipping if necessary
#unzip(dataset)

# setting location of table and read file
path <- dataset
traits <- read.table(paste("./", path, sep=""), sep=",", header=T, fill=T)

head(traits)
cols.used <- c(3:6)
traits <- traits[,cols.used]

## reshape from wide to long 
traits_long <- melt(traits, id.vars=c(colnames(traits)[1]))

## filter NAs
traits_long.filter <- traits_long[!is.na(traits_long[,3]),]

dim(traits_long)
dim(traits_long.filter)

# summarize

traits_summary <- traits_long.filter %>% count(Family,variable, sort = TRUE)


names(traits_summary)[1] <- "scientificNameVerbatim"
names(traits_summary)[2] <- "traitNameVerbatim"
names(traits_summary)[3] <- "NumberOfRecords"

traits_summary$OTNdatasetID <- dataset_url
traits_summary$curator <- curator
traits_summary$accessDate <- Sys.Date()

head(traits_summary)

write.csv(traits_summary, file=paste("../summaries/",dataset,".csv",sep=""), row.names = F )
gzip(paste("../summaries/",dataset,".csv",sep=""), destname=paste("../summaries/",dataset,".csv.gz",sep=""),overwrite=T)
unlink(paste("../summaries/",dataset,".csv",sep=""))

setwd(root.dir)
