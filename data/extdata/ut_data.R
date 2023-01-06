library(readxl)
library(readr)
library(dplyr)
library(here)

# Go to this URL: https://s3.amazonaws.com/wp-uploads.gsandf/311626179_UTMedical+Center_standardcharges.zip
# Extract the data and save the xls file in data/extdata
# File is so large, reduced size by just saving the sheet for analysis

filename <- "311626179_UTMedical Center_standardcharges_CDM_Standard_Charges.xls"
filepath <- here("data","extdata", filename)

excel_sheets(filepath)

# I know from looking at the excel document that I only want CDM Standard Charges and need to skip the first 2 rows

ut_raw <- read_excel(filepath, skip = 2, guess_max = Inf)

saveRDS(ut_raw, here("data","extdata","ut_data_raw.Rds"))
write_csv(ut_raw, here("data","extdata","ut_data_raw.csv"), na = "")
