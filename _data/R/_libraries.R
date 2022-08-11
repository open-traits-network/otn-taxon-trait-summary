options(install.packages.compile.from.source = "never")

my_packages <- c("reshape2", "dplyr", "tidyverse", "R.utils","readxl")                           # Specify your packages
not_installed <- my_packages[!(my_packages %in% installed.packages()[ , "Package"])]    # Extract not installed packages
if(length(not_installed)) install.packages(not_installed, dependencies=T)               # Install not installed packages
