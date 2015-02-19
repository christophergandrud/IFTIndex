

# Set working directory. Change as needed.
setwd('~/Desktop/')

# Load required packages
library(data.table)
library(dplyr)
library(tidyr)

# Import full data set
## Data downloaded 2015-02-19 from data.imf.org
fiscal<- fread('GFS 2001 Multidimensional_02-19-2015 09-07-31-49.csv',
                  header = T)


