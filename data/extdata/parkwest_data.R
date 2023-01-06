library(dplyr)
library(readr)
library(jsonlite)
library(here)

## Connect and read data
json_location <- "https://www.covenanthealth.com/pt_json/581897274_Parkwest-Medical-Center_standardcharges.json"

pw_json <- read_json(json_location)

## Loop through list and convert to data frame row by row

pw_raw <- tibble()

for (i in 2:length(pw_json$data)) {
  row <- pw_json$data[i] |> as.data.frame()
  
  pw_raw <- bind_rows(pw_raw, row)
}

## Potential future change to purrr::pluck to increase efficiency

## Save data
write_csv(pw_raw, here("data","extdata","pw_data_raw.csv"))
saveRDS(pw_raw, here("data","extdata","pw_data_raw.Rds"))
