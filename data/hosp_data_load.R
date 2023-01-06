library(DBI)
library(here)
library(dplyr)

reload = 0

con <- dbConnect(odbc::odbc(),
                 Driver="sqlserver", 
                 Server = rstudioapi::askForPassword("Database server:"), 
                 Port = "1433", 
                 UID = rstudioapi::askForPassword("Database user id:"),
                 PWD = rstudioapi::askForPassword("Database password:"), 
                 Database = rstudioapi::askForPassword("Database name:"), 
                 timeout = 10)

## Parkwest Data

pw_raw <- readRDS(here("data","extdata","pw_data_raw.Rds"))

## Review the data and clean
glimpse(pw_raw)

pw_clean <- pw_raw |> 
  mutate(file_create_date = as.Date(file_create_date),
         gross.charge = as.numeric(gross.charge),
         de.identified.minimum.negotiated.charge = as.numeric(de.identified.minimum.negotiated.charge),
         payer.specific.negotiated.charge = as.numeric(payer.specific.negotiated.charge),
         de.identified.maximum.negotiated.charge = as.numeric(de.identified.maximum.negotiated.charge),
         discounted.cash.price = as.numeric(discounted.cash.price),
         UUID = row_number()) |> 
  rename_with(~ toupper(gsub(".", "_", .x, fixed = TRUE))) |> 
  select(
    UUID,
    FILE_CREATE_DATE,
    RUN_ID,
    NAME,
    TAX_ID,
    CODE,
    CODE_TYPE,
    CODE_DESCRIPTION,
    PAYER,
    PATIENT_CLASS,
    GROSS_CHARGE,
    DE_IDENTIFIED_MINIMUM_NEGOTIATED_CHARGE,
    PAYER_SPECIFIC_NEGOTIATED_CHARGE,
    DE_IDENTIFIED_MAXIMUM_NEGOTIATED_CHARGE,
    DISCOUNTED_CASH_PRICE
  )

glimpse(pw_clean)


## TC Data

tc_raw <- readRDS(here("data","extdata","tc_data_raw.Rds"))

glimpse(tc_raw)

tc_clean <- tc_raw |>
  rename_with(~ toupper(gsub(".", "_", .x, fixed = TRUE))) |> 
  rename_with(~ gsub("-", "", .x, fixed = TRUE)) |>
  rename_with(~ gsub("___", "_", .x, fixed = TRUE)) |>
  mutate(UUID = row_number(),
         AS_OF_DATE = as.Date(AS_OF_DATE)) |> 
  relocate(UUID, 1)

glimpse(tc_clean)

## UT Data

ut_raw <- readRDS(here("data","extdata","ut_data_raw.Rds"))

glimpse(ut_raw)

ut_clean_rnm <- ut_raw |> 
  rename_with(~ toupper(gsub(".", "", .x, fixed = TRUE))) |> 
  rename_with(~ toupper(gsub("-", "", .x, fixed = TRUE))) |> 
  rename_with(~ toupper(gsub(",", "", .x, fixed = TRUE))) |> 
  rename_with(~ toupper(gsub("  ", " ", .x, fixed = TRUE))) |> 
  rename_with(~ toupper(gsub("/", "_PER_", .x, fixed = TRUE))) |> 
  rename_with(~ toupper(gsub(" ", "_", .x, fixed = TRUE)))

colnames(ut_clean_rnm)[3] <- "CPT"
colnames(ut_clean_rnm)[4] <- "ALTERNATE_CPT"
  

glimpse(ut_clean_rnm)

ut_clean <- ut_clean_rnm |> 
  mutate(across(.col = everything(), ~ ifelse(.x == "N/A", NA, .x))) |> 
  mutate(across(5:length(ut_clean_rnm), ~ as.numeric(.x))) |>  # first 5 columns are the identifiers
  mutate(UUID = row_number(), CHARGE_CODE = as.integer(CHARGE_CODE)) |> 
  relocate(UUID, 1)

glimpse(ut_clean)


# Blount Memorial Data 

bm_raw <- readRDS(here("data","extdata","bm_data_raw.Rds"))

glimpse(bm_raw)

bm_subset <- bm_raw |> select(1:11) # Subsetting the first 11 columns for ease (the rest of the columns have long and ambiguous names) and relevance (do not really need the insurance payment breakout at this time)

glimpse(bm_subset)

bm_clean <- bm_subset |> 
  rename_with(~ toupper(gsub("/", "_OR_", .x, fixed = TRUE))) |> 
  rename_with(~ toupper(gsub("#", "NUMBER", .x, fixed = TRUE))) |> 
  rename_with(~ toupper(gsub(" ", "_", .x, fixed = TRUE))) |> 
  mutate(across(8:11, ~ stringr::str_remove_all(.x, "\\$")),
         across(8:11, ~ as.numeric(.x)),
         UUID = row_number()) |> 
  relocate(UUID, 1)
  
  
glimpse(bm_clean)

if (reload == 1) {
  
  DBI::dbExecute(
    con,
    "DELETE FROM BM_HOSPITAL_DATA"
  )
  
  DBI::dbAppendTable(
    con,
    "BM_HOSPITAL_DATA",
    bm_clean
  )
  
  DBI::dbExecute(
    con,
    "DELETE FROM TC_HOSPITAL_DATA"
  )
  
  DBI::dbAppendTable(
    con,
    "TC_HOSPITAL_DATA",
    tc_clean
  )
  
  DBI::dbAppendTable(
    con,
    "UT_HOSPITAL_DATA",
    ut_clean
  )
  
  DBI::dbExecute(
    con,
    "DELETE FROM PW_HOSPITAL_DATA"
  )
  
  DBI::dbAppendTable(
    con,
    "PW_HOSPITAL_DATA",
    pw_data_clean
  )
  
} else if (reload == 0) {
  print("Data not uploaded. Reload indicator set to 0.")
}
