########################################################################
# Download and clean central government budget statistics 
# Christopher Gandrud
# 19 February 2015
# Christopher Gandrud
# MIT License
#########################################################################

# Set working directory. Change as needed.
setwd('/git_repositories/IFTIndex/')

# Load required packages
library(dplyr)
library(WDI)
library(countrycode)
library(DataCombine)

# Function to find the proportion of indicators reported

PropReported <- function(data){
    vars <- grep('Rep_.*', names(data), value = TRUE)
    data$sum <- rowSums(data[, vars])
    data$PropReport <- data$sum/length(vars)
    if ('country' %in% names(data)){
        Out <- data[, c('country', 'iso2c', 'year', 'PropReport')]
    }
    else Out <- data[, c('iso2c', 'year', 'PropReport')]
    return(Out)
}

#### Download data ####
indicators <- c('GC.DOD.TOTL.GD.ZS', 
                'FS.AST.CGOV.GD.ZS',
                'GC.BAL.CASH.GD.ZS',
                'GC.REV.XGRT.GD.ZS',
                'GC.XPN.TOTL.GD.ZS',
                'GC.TAX.TOTL.GD.ZS')

budget_full <- WDI(indicator = indicators, start = 1990, end = 2012,
                   extra = TRUE) 

budget_sub <- subset(budget_full, region != 'Aggregates')
budget_sub <- subset(budget_sub, !is.na(region))

budget_sub <- budget_sub[, c('iso2c', 'year', indicators)]
budget_sub <- budget_sub %>% filter(!is.na(iso2c))

budget_sub$country <- countrycode(budget_sub$iso2c, origin = 'iso2c',
                                  destination = 'country.name')
budget_sub <- budget_sub %>% MoveFront(Var = 'country')
budget_sub <- budget_sub %>% filter(!is.na(country))

budget_sub <- budget_sub %>% arrange(country, year)

#### Create missingness dummy ####
IndSub <- budget_sub %>% select(-country, -iso2c, -year) %>% names()

for (i in IndSub){
    budget_sub[, paste0('Rep_', i)] <- 1
    budget_sub[, paste0('Rep_', i)][is.na(budget_sub[, i])] <- 0
}

# Find proportion reported
prop_reported <- PropReported(budget_sub)

#### Save data ####
write.csv(prop_reported, file = 'source/data_cleaned/proportion_reported.csv',
          row.names = F)
write.csv(budget_sub, file = 'source/data_cleaned/wdi_fiscal.csv',
          row.names = F)

