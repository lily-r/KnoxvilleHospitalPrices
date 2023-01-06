library(here)
library(readxl)
library(readr)

# No import data uploaded manually
bm_file_name <- "620505512_Blount_Memorial_Hospital_standardcharges.xlsx"
bm_upload_location <- here("data","extdata",bm_file_name)
excel_sheets(bm_upload_location)

bm_raw <- read_xlsx(bm_upload_location, sheet = 3, guess_max = Inf)

saveRDS(bm_raw, here("data","extdata","bm_data_raw.Rds"))
write_csv(bm_raw, here("data","extdata","bm_data_raw.csv"), na = "")
