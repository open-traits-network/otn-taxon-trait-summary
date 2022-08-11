library(reshape2)
library(dplyr)
library(readxl)

root.dir = getwd()

# create output directory
if(!dir.exists("_data/R/summaries")){dir.create("_data/R/summaries")}  
if(!dir.exists("_data/R/temp")){dir.create("_data/R/temp")}

# set variables
curator <- "https://opentraits.org/members/alexander-keller"
dataset_url <- "https://opentraits.org/datasets/passerine-morphology"
dataset <- "passerine-morphology"

# Download file
download.file(url = "https://esajournals.onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1002%2Fecy.1783&file=ecy1783-sup-0002-DataS1.zip",
              destfile = paste("_data/R/temp/",dataset, sep=""))
setwd("_data/R/temp")

# unzipping if necessary
unzip(dataset)

# setting location of table and read file
path <- "Measurements of passerine birds.xlsx"
traits <- data.frame(read_excel(paste("./", path, sep="")))

head(traits)
cols.used <- c(1:19,24,25)

## reshape from wide to long 
traits_long <- melt(traits[,cols.used], id.vars=c(colnames(traits)[24],colnames(traits)[25]))

## filter NAs
traits_long.filter <- traits_long[!is.na(traits_long[,4]),]

dim(traits_long)
dim(traits_long.filter)
head(traits_long.filter)

traits_long.filter$VerbSpec <- interaction(traits_long.filter$Genus,traits_long.filter$Species, sep=" ")

# summarize
traits_summary <- traits_long.filter %>% count(VerbSpec,variable, sort = TRUE)

names(traits_summary)[1] <- "scientificNameVerbatim"
names(traits_summary)[2] <- "traitNameVerbatim"
names(traits_summary)[3] <- "numberOfRecords"

traits_summary$datasetId <- dataset_url
traits_summary$curator <- curator
traits_summary$accessDate <- Sys.Date()

head(traits_summary)


write.csv(traits_summary, file=paste("../summaries/",dataset,".csv",sep=""), row.names = F )
gzip(paste("../summaries/",dataset,".csv",sep=""), destname=paste("../summaries/",dataset,".csv.gz",sep=""),overwrite=T)
unlink(paste("../summaries/",dataset,".csv",sep=""))

setwd(root.dir)
