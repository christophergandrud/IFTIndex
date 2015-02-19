########################################################################
# Extract raw IMF Government Finance Statistics data
# Christopher Gandrud
# 19 February 2015
# Christopher Gandrud
# MIT License
#########################################################################

# Set working directory. Change as needed.
setwd('/git_repositories/IFTIndex/')

# Load required packages
library(data.table)
library(dplyr)
library(DataCombine)
library(tidyr)

# Import full data set
## Data downloaded 2015-02-19 from data.imf.org
fiscal<- 'source/raw_data_clean/raw/GFS 2001 Multidimensional_02-19-2015 09-07-31-49.csv' %>%
    fread() %>% as.data.frame()

# Remove spaces from variable names
names(fiscal) <- gsub(' ', '', names(fiscal))

# Keep only Budgetary Central Government
fiscal <- fiscal %>% filter(SectorName == 'Budgetary Central Government')

# Order
fiscal <- fiscal %>% arrange(CountryName, Time, IndicatorName)

# Keep only version in national currency
smaller <- fiscal %>% grepl.sub(pattern = '.*XDC', Var = 'IndicatorCode')
vars <- unique(smaller$IndicatorName)

keep <- c(
    "Government Assets and Liabilities, Liabilities (=GGAL_G01), National Currency",
    "Government Assets and Liabilities, Liabilities, Domestic (=GGALD_G01), National Currency",
    "Government Assets and Liabilities, Liabilities, Foreign (=GGALF_G01), National Currency",
    "Government Cash Inflow from Operation Activities, 2001 Manual, National Currency",
    "Government Cash Infow from Financing Activities, 2001 Manual, National Currency",
    "Government Cash surplus/deficit, 2001 Manual, National Currency",
    "Government Gross operating balance, 2001 Manual, National Currency",
    "Government Net lending/borrowing, 2001 Manual, National Currency",
    "Government Net operating balance, 2001 Manual, National Currency",
    "Government Assets and Liabilities, Debt (at Market Value), Classification of holding gains in assets and liabilities, 2001 Manual, National Currency",
    "Government Assets and Liabilities, Debt (at Nominal Value), Classification of the stocks of assets and liabilities, 2001 Manual, National Currency"
)

smaller <- smaller %>% grepl.sub(pattern = keep, Var = 'IndicatorName')


#### Create indicator key ####
key <- data.frame(IndicatorCode = unique(smaller$IndicatorCode), 
                  IndicatorName = unique(smaller$IndicatorName))

#### Spread data ####
smaller <- 
