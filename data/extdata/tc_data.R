library(readr)
library(here)

csv_location <- "https://www.tennovaturkeycreek.com/Uploads/Public/Documents/charge-masters/452535623_Tennova%20Turkey%20Creek_standardcharges.csv"

tc_data_raw <- read_csv(csv_location)
tc_data_raw_wo_attr <- data.frame(tc_data_raw)

write_csv(tc_data_raw_wo_attr, here("data","extdata","tc_data_raw.csv"))

saveRDS(tc_data_raw_wo_attr, here("data","extdata","tc_data_raw.Rds"))
