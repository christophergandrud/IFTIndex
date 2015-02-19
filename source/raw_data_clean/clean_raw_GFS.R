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
library(countrycode)

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
smaller <- smaller %>% filter(AccountingMethodName == 'Cash')
vars <- unique(smaller$IndicatorName)

keepers <- c(
    "Government Assets and Liabilities, Liabilities .*, National Currency",
    "Government Assets and Liabilities, Liabilities, Domestic .*, National Currency",
    "Government Assets and Liabilities, Liabilities, Foreign .*, National Currency",
    "Government Cash Inflow from Operation Activities, 2001 Manual, National Currency",
    "Government Cash Infow from Financing Activities, 2001 Manual, National Currency",
    "Government Cash surplus\\/deficit, 2001 Manual, National Currency",
    "Government Gross operating balance, 2001 Manual, National Currency",
    "Government Net lending\\/borrowing, 2001 Manual, National Currency",
    "Government Net operating balance, 2001 Manual, National Currency",
    "Government Assets and Liabilities, Debt .*, Classification of holding gains in assets and liabilities, 2001 Manual, National Currency"
)

smaller <- smaller %>% grepl.sub(pattern = keepers, Var = 'IndicatorName')


#### Create indicator key ####
key <- data.frame(IndicatorCode = unique(smaller$IndicatorCode), 
                  IndicatorName = unique(smaller$IndicatorName))

#### Spread data ####
fiscal_spread <- smaller %>% select(CountryName, CountryCode, Time, 
                                    IndicatorCode, Value) 
fiscal_spread$Time <- as.numeric(fiscal_spread$Time)
fiscal_spread$Value <- as.numeric(fiscal_spread$Value)

fiscal_spread <- fiscal_spread %>% spread(IndicatorCode, Value)
