library(rvest)
library(tidyverse)


# create output directory
if(!dir.exists("_data/R/summaries")){dir.create("_data/R/summaries")}  
if(!dir.exists("_data/R/temp")){dir.create("_data/R/temp")}

# set variables
curator <- "https://opentraits.org/members/brian-s-maitner"
dataset_url <- "https://opentraits.org/datasets/amp"
dataset <- "amp"


# For this set of data, I'm utilizing scraping functions provided by the AmP folks (https://debportal.debtheory.org/docs/AmP2R.html)
  getDEB.species <- function() {
    url <- "https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/species_list.html"
    d1 <- read_html(url)
    
    phylum <- d1 %>% html_nodes("td:nth-child(1)") %>% html_text()
    class <- d1 %>% html_nodes("td:nth-child(2)") %>% html_text()
    order <- d1 %>% html_nodes("td:nth-child(3)") %>% html_text()
    family <- d1 %>% html_nodes("td:nth-child(4)") %>% html_text()
    species <- d1 %>% html_nodes("td:nth-child(5)") %>% html_text()
    common <- d1 %>% html_nodes("td:nth-child(6)") %>% html_text()
    type <- d1 %>% html_nodes("td:nth-child(7)") %>% html_text()
    mre <- d1 %>% html_nodes("td:nth-child(8)") %>% html_text()
    smre <- d1 %>% html_nodes("td:nth-child(9)") %>% html_text()
    complete <- d1 %>% html_nodes("td:nth-child(10)") %>% html_text()
    all.species <- as.data.frame(cbind(phylum, class, order, 
                                       family, species, common, type, mre, smre, complete), 
                                 stringsAsFactors = FALSE)
    all.species$species <- gsub(" ", "_", all.species$species)
    all.species$mre <- as.numeric(mre)
    all.species$smre <- as.numeric(smre)
    all.species$complete <- as.numeric(complete)
    return(all.species)
  }

  getDEB.pars <- function(species) {
    require(rvest)
    library(rvest)
    baseurl <- "https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/entries_web/"
    d1 <- read_html(paste0(baseurl, species, "/", species, "_par.html"))
    symbol1 <- d1 %>% html_nodes("td:nth-child(1)") %>% html_text()
    
    value1 <- d1 %>% html_nodes("td:nth-child(2)") %>% html_text()
    
    units1 <- d1 %>% html_nodes("td:nth-child(3)") %>% html_text()
    
    description1 <- d1 %>% html_nodes("td:nth-child(4)") %>% 
      html_text()
    
    extra1 <- d1 %>% html_nodes("td:nth-child(5)") %>% html_text()
    
    extra2 <- d1 %>% html_nodes("td:nth-child(6)") %>% html_text()
    end <- which(symbol1 == "T_ref")
    symbol <- symbol1[1:end]
    value <- value1[1:end]
    units <- units1[1:end]
    description <- description1[1:end]
    
    pars <- as.data.frame(cbind(symbol, value, units, description))
    pars$symbol <- as.character(symbol)
    pars$value <- as.numeric(value)
    pars$units <- as.character(units)
    pars$description <- as.character(description)
    
    chempot <- c(value1[end + 1], units1[end + 1], description1[end + 
                                                                  1], extra1[1])
    dens <- c(value1[end + 2], units1[end + 2], description1[end + 
                                                               2], extra1[2])
    org.C <- c(units1[end + 3], description1[end + 3], extra1[3], 
               extra2[1])
    org.H <- c(value1[end + 4], units1[end + 4], description1[end + 
                                                                4], extra1[4])
    org.O <- c(value1[end + 5], units1[end + 5], description1[end + 
                                                                5], extra1[5])
    org.N <- c(value1[end + 6], units1[end + 6], description1[end + 
                                                                6], extra1[6])
    min.C <- c(units1[end + 7], description1[end + 7], extra1[7], 
               extra2[2])
    min.H <- c(value1[end + 8], units1[end + 8], description1[end + 
                                                                8], extra1[8])
    min.O <- c(value1[end + 9], units1[end + 9], description1[end + 
                                                                9], extra1[9])
    min.N <- c(value1[end + 10], units1[end + 10], description1[end + 
                                                                  10], extra1[10])
    
    organics <- rbind(org.C, org.H, org.O, org.N)
    minerals <- rbind(min.C, min.H, min.O, min.N)
    colnames(organics) <- c("X", "V", "E", "P")
    colnames(minerals) <- c("CO2", "H2O", "O2", "N-waste")
    rownames(organics) <- c("C", "H", "O", "N")
    rownames(minerals) <- c("C", "H", "O", "N")
    class(chempot) <- "numeric"
    class(dens) <- "numeric"
    class(organics) <- "numeric"
    class(minerals) <- "numeric"
    
    return(list(pars = pars, chempot = chempot, dens = dens, 
                organics = organics, minerals = minerals))
  }  
  
  getDEB.implied <- function(species) {
    require(rvest)
    library(rvest)
    baseurl <- "https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/entries_web/"
    d1 <- read_html(paste0(baseurl, species, "/", species, "_stat.html"))
    symbol <- d1 %>% html_nodes("td:nth-child(1)") %>% html_text()
    
    value <- d1 %>% html_nodes("td:nth-child(2)") %>% html_text()
    
    units <- d1 %>% html_nodes("td:nth-child(3)") %>% html_text()
    
    description <- d1 %>% html_nodes("td:nth-child(4)") %>% html_text()
    
    final <- as.data.frame(cbind(symbol, value, units, description))
    final$symbol <- as.character(symbol)
    final$value <- as.numeric(value)
    final$units <- as.character(units)
    final$description <- as.character(description)
    return(final)
  }

  #these little "robust" wrappers ensure that temporary issues with downloads don't break things

  robust_pars <- function(species, max_attempts = 100){
    
    i <- 0
    
    while(i < max_attempts){
      
      print(i)
      
      i=i+1
      
      pars_i <- tryCatch(expr = getDEB.pars(species = species_i),
                         error = function(e){e}
                         )
      
      if(inherits(pars_i,"list")){return(pars_i)}

    }

  }#end robust pars
  
  
  robust_implied <- function(species, max_attempts = 100){
    
    i <- 0
    
    while(i < max_attempts){
      
      print(i)
      
      i = i+1
      
      imp_i <- tryCatch(expr = getDEB.implied(species = species_i),
                         error = function(e){e}
      )
      
      if(inherits(imp_i,"data.frame")){return(imp_i)}
      
    }
    
  }#end robust pars
  
    
    
    
    
  species <- getDEB.species()  
  deb_pars <- NULL
  
  trait_sample<- read.csv("traits-sample.csv")
  colnames(trait_sample)
  
  for(i in 1:length(unique(species$species))){
    
    message(round(i/length(unique(species$species))*100,digits = 2), " % done")
    
    species_i <- unique(species$species)[i]
    tax_i <- species[which(species$species == species_i),]
    pars_i <- robust_pars(species = species_i)
    imp_i <- robust_implied(species = species_i)
    
    
    deb_pars <- 
    pars_i$pars %>%
      mutate(scientificNameVerbatim = species_i,
             family = tax_i$family,
             phylum = tax_i$phylum,
             traitNameVerbatim = description) %>%
      bind_rows(deb_pars)
    
    rm(species_i, tax_i, pars_i, imp_i)
    
  }

#add other metadata needed

  deb_pars %>%
    dplyr::select(scientificNameVerbatim,
                  family,
                  phylum,
                  traitNameVerbatim) %>%
    group_by(scientificNameVerbatim,
             family,
             phylum,
             traitNameVerbatim) %>%
    unique() %>%
    summarise(numberOfRecords = n()) -> deb_pars
  
  deb_pars %>%
    mutate(datasetId = dataset,
           curator = curator,
           accessDate = Sys.Date()) -> deb_pars

  if(!all(colnames(deb_pars) %in%   colnames(trait_sample))){stop("column name problem")}
  
  traits_summary <- deb_pars
  
#write output

  write.csv(traits_summary,
            file = file.path("_data/R/summaries/",paste(dataset,".csv",sep="")),
            row.names = F )
  
  R.utils::gzip(filename = file.path("_data/R/summaries/",paste(dataset,".csv",sep="")),
                destname = file.path("_data/R/summaries/",paste(dataset,".csv.gz",sep="")),
                overwrite = TRUE)
  
  unlink(file.path("_data/R/summaries/",paste(dataset,".csv",sep="")))
  






