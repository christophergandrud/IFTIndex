########################################################################
# Download and clean central government budget statistics 
# Christopher Gandrud
# 23 February 2015
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

## EMBI+ + China country list

EMBI <- c(
    'Argentina',
    'Brazil',
    'Bulgaria',
    'China',
    'Colombia',
    'Ecuador',
    'Egypt',
    'Mexico',
    'Morocco',
    'Nigeria',
    'Panama',
    'Peru',
    'Philippines',
    'Poland',
    'Russian Federation',
    'South Africa',
    'Turkey',
    'Ukraine',
    'Venezuela'
)

budget_full <- WDI(indicator = indicators, start = 1990, end = 2012,
                   extra = TRUE) 

# Subset for high income
budget_high <- grepl.sub(data = budget_full, Var = 'income', 
                         pattern = 'High income')

# Subset for EMBI+, + China
embi_iso <- countrycode(EMBI, origin = 'country.name', destination = 'iso2c')
budget_embi <- grepl.sub(data = budget_full, Var = 'iso2c', patter = embi_iso)

# Combine
budget_full <- rbind(budget_high, budget_embi)
budget_full <- budget_full[!duplicated(budget_full[, c('country', 'year')]), ]

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

