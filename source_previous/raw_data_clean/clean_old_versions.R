################################################################################
# Data reported through the WDI at either t+1 or t+2
# Christopher Gandrud
# 23 February 2015
# MIT License
################################################################################

# Set working directory. Change as needed
setwd('/git_repositories/IFTIndex/')

# Load required packages
library(dplyr)
library(lubridate)
library(countrycode)
library(DataCombine)
library(tidyr)

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

# Load data
## Data downloaded from http://databank.worldbank.org/data/databases/archives
## February 2015
fiscal_old_1 <- read.csv('source_previous/raw_data_clean/fiscal_all_1.csv', 
                 stringsAsFactors = F)
fiscal_old_2 <- read.csv('source_previous/raw_data_clean/fiscal_all_2.csv', 
                       stringsAsFactors = F)

fiscal_old <- rbind(fiscal_old_1, fiscal_old_2)

rm(fiscal_old_1, fiscal_old_2)

# Add country name
fiscal_old$country <- countrycode(fiscal_old$Country.Code, origin = 'iso3c', 
                            destination = 'country.name')
fiscal_old <- fiscal_old %>% MoveFront('country')
fiscal_old <- fiscal_old %>% DropNA('country')

# Create cleaned version variable
vyear <- substr(fiscal_old$Version.Code, 1, 4)
vmonth <- substr(fiscal_old$Version.Code, 5, 6)

fiscal_old$Version.Code <- sprintf('%s-%s-15', vyear, vmonth)  %>% # Assume 15th release
                        ymd()

#### Create data reported in year t + 1

# Limit to >= 2005
fiscal_sub <- fiscal_old %>% filter(Version.Code >= '2005-01-01')

drop_years <- sprintf('YR%s', 1990:2004)

fiscal_sub <- fiscal_sub[, !(names(fiscal_sub) %in% drop_years)]

fiscal_sub <- fiscal_sub %>% gather(year_reported_for, value, 
                                    5:ncol(fiscal_sub))
fiscal_sub$year_reported_for <- fiscal_sub$year_reported_for %>%
                                    gsub('YR', '', .) %>% as.numeric()

fiscal_sub$version_year <- year(fiscal_sub$Version.Code)
fiscal_sub$version_year_mod_1 <- fiscal_sub$version_year - 1
fiscal_sub$version_year_mod_2 <- fiscal_sub$version_year - 2


fiscal_sub <- fiscal_sub %>% subset(year_reported_for == version_year_mod_1 |
                                        year_reported_for == version_year_mod_2)

fiscal_sub$reported <- 0
fiscal_sub$reported[!is.na(fiscal_sub$value) & 
                        fiscal_sub$year_reported_for == 
                        fiscal_sub$version_year_mod_1] <- 1
fiscal_sub$reported[!is.na(fiscal_sub$value) & 
                        fiscal_sub$year_reported_for == 
                        fiscal_sub$version_year_mod_2] <- 1

fiscal_sub$year <- NA

for (i in 1:nrow(fiscal_sub)) {
    fiscal_sub[i, 'year'][fiscal_sub[i, 'year_reported_for'] == 
                            fiscal_sub[i, 'version_year_mod_1']] <- 
        fiscal_sub[i, 'version_year_mod_1']
    fiscal_sub[i, 'year'][fiscal_sub[i, 'year_reported_for'] == 
                              fiscal_sub[i, 'version_year_mod_2']] <- 
        fiscal_sub[i, 'version_year_mod_2']
}

fiscal_sub <- fiscal_sub %>% 
                group_by(country, Series.Code, year) %>%
                mutate(reported_total = sum(reported))

fiscal_sub <- fiscal_sub[!duplicated(fiscal_sub[, 
                            c('country', 'year',
                              'Series.Code', 'reported_total')]), ]

fiscal_sub <- fiscal_sub %>% arrange(country, Series.Code, year)

fiscal_sub$reported[fiscal_sub$reported_total >= 1] <- 1

fiscal_sub <- fiscal_sub %>% select(country, Series.Code, year, 
                                    reported) 

fiscal_clean <- fiscal_sub %>% spread(Series.Code, reported)

fiscal_clean$iso2c <- countrycode(fiscal_clean$country, origin = 'country.name',
                                  destination = 'iso2c')

fiscal_clean <- fiscal_clean %>% MoveFront(c('country', 'iso2c'))
names(fiscal_clean) <- c('country', 'iso2c', 'year', 
                         sprintf('Rep_%s', 
                                 names(fiscal_clean)[4:ncol(fiscal_clean)]))

fiscal_clean <- fiscal_clean %>% filter(year != 2013)

# Subset for included countries
included <- 'source/data_cleaned/proportion_reported.csv' %>%
                read.csv(stringsAsFactors = F) %>%
                filter(country != 'Puerto Rico')
included <- unique(included$iso2c)

fiscal_clean <- fiscal_clean %>% filter(iso2c %in% included)

#### Proportion reported ####
prop_reported <- PropReported(fiscal_clean)

# Save
write.csv(prop_reported, 
          file = 'source_previous/data_cleaned/proportion_previous_reported.csv',
          row.names = F)
write.csv(fiscal_clean, 
          file = 'source_previous/data_cleaned/wdi_previous_fiscal.csv',
          row.names = F)
