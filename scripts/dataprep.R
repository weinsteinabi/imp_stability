library(dplyr)
library(tidyr)
library(tidyverse)
library(readxl)
library(readr)
library(countrycode)
library(stringr)


mil_int <- read_excel("data/MIP-Dataset_2022.xlsx")
vdem <- readRDS("data/V-Dem-CY-Full+Others-v15.rds")
colony <- read_excel("data/WimmerMin1.0.xls")

#extract necessary data from colony data
colony_subset <- colony %>% filter(imppower == "USA") %>% select(c("country", "cowcode", "year", "imppower"))
colony_subset <- colony_subset %>% group_by(cowcode) %>% mutate(
  start_year = min(year), 
  end_year = max(year), 
  start_year = ifelse(start_year < 1898, 1898, start_year)
) %>% select(-c("year"))

colony_subset <- colony_subset[!duplicated(colony_subset), ]
colony_subset <- colony_subset %>% filter(country != "Philippines") %>% select(-c("imppower"))
colony_subset <- colony_subset %>% mutate(
    event = paste("US Occupation of", country), 
    max = max(end_year)
)

#extract necessary data from vdem
vdem_subset <- vdem %>% select(c("year", "country_name", "COWcode", "e_regionpol",
                                 "v2x_corr", "v2x_civlib", "v2stfisccap_ord",
                              "e_gdppc", "v2x_rule", "e_pelifeex"))
vdem_subset <- vdem_subset %>% filter(e_regionpol == 2) %>% filter(year >= 1898 & year <= 2010) 
vdem_subset <- vdem_subset %>% rename(cowcode = "COWcode") %>% rename(country = "country_name")

#set up military interactions ds
mil_int <- mil_int %>% filter(RemoveCase == 0) %>% separate_rows(`State B code`, sep = ", ") %>% separate_rows(`State B`, sep = ", ") %>% 
  separate_rows(`State B`, sep = "/") %>% separate_rows(`State B code`, sep = "/")
mil_int$`State B code` <- countrycode(mil_int$`State B`, origin = "cowc", destination = "cown")
mil_int$`State B code`[mil_int$`State B` == "KOR"] <- 730
mil_int <- mil_int[!duplicated(mil_int), ]

#separate and drop involvements on US soil 
mil_int <- mil_int %>% separate_rows(`Location`, sep = ", ") %>% separate_rows(`Location`, sep = ", ") %>% 
  drop_na(Location) %>% filter(Location != 2)
mil_int <- mil_int[!duplicated(mil_int), ]

#clear up target data
mil_int <- mil_int %>% mutate(
  `StateB primary target?` = case_when(
    str_detect(`StateB primary target?`, "0") ~ "0",
    str_detect(`StateB primary target?`, "1") ~ "1"
  )
)

#select essential info - country, code, years (start and end), location, duration, objective, objective code
mil_int_sub <- mil_int %>% select(c("State B", "State B code", "Name", "StateB primary target?", "styear", 
                                    "endyear", "cumdurat", "Location", "Objective", "ObjectiveCode"))
mil_int_sub <- mil_int_sub %>% separate_rows(ObjectiveCode, sep = "; ") %>% separate_rows(ObjectiveCode, sep = ";")

#identify region of interest (Latin America)
mil_int_sub <- mil_int_sub %>% rename(cowcode = "State B code")
vdem_region <- vdem_subset %>% select(e_regionpol, cowcode) %>% filter(!duplicated(cowcode))
mil_int_sub <- left_join(mil_int_sub, vdem_region)
mil_int_sub <- mil_int_sub %>% filter(e_regionpol == 2)

#remove data that is not coded according to imperial justifications of the time (1898 - 1945)
#(economic protection, empire preservation, acquire/defend territory, protect military interests)
mil_int_sub <- mil_int_sub %>% filter(ObjectiveCode == 7 | ObjectiveCode == 8 | 
                                        ObjectiveCode == 4 | ObjectiveCode == 3)
mil_int_sub <- mil_int_sub %>% filter(endyear < 1946)

#identify countries with 1+ years of engagement
mil_int_sub <- mil_int_sub %>% group_by(Name, `State B`, styear) %>% filter(!duplicated(Name))
mil_int_sub <- mil_int_sub %>% select(-c("Objective", "ObjectiveCode", "Location", "e_regionpol"))
mil_int_sub <- mil_int_sub %>% group_by(`State B`) %>% mutate(
  max = max(endyear))
mil_int_sub <- mil_int_sub %>% group_by(cowcode) %>% mutate(
  cumdurat_new = sum(cumdurat)
) %>% filter(cumdurat > 365)
mil_int_sub <- mil_int_sub %>% select(-c(`StateB primary target?`, max))

colnames(mil_int_sub) <- c("country", "cowcode", "event", "start_year", "end_year", "duration", "cumduration") 

#combine colony and military imperialism measures
imperialism_events <- bind_rows(mil_int_sub, colony_subset)
imperialism_events$country <- countrycode(imperialism_events$cowcode, "cown", "country.name")
imperialism_events <- imperialism_events %>% filter(start_year >= 1898)

#expand into yearly observation
imperialism_eventsl <- imperialism_events %>% pivot_longer(start_year:end_year, values_to = "year") %>%
  group_by(event) %>% 
  complete(year = seq(min(year), max(year)))

imperialism_eventsl <- imperialism_eventsl %>% fill(country, cowcode) %>% rename(impevent = "name")
imperialism_eventsl$impevent <- 1
imperialism_eventsl <- imperialism_eventsl[!duplicated(imperialism_eventsl), ]

imperialism_eventsl <- imperialism_eventsl %>% group_by(country, cowcode, year) %>% summarize(event = paste(event, collapse = "; "),
                                          cowcode = cowcode,
                                          impevent = impevent) 

imperialism_eventsl <- imperialism_eventsl[!duplicated(imperialism_eventsl), ]

imperialism_eventsl <- imperialism_eventsl %>% group_by(country) %>% complete(year = 1898:1945) %>% mutate(
  impevent = ifelse(is.na(impevent), 0, impevent), 
  cowcode = countrycode(country, "country.name", "cown")
)

#join datasets 
impevents <- left_join(vdem_subset, imperialism_eventsl, by = c("country", "year", "cowcode"))

#add needed vars + clean
impevents <- impevents %>% group_by(country, e_regionpol, cowcode) %>% complete(year = 1898:2010)
impevents <- impevents %>% mutate(
  cowcode = countrycode(country, "country.name", "cown")
)

impevents <- impevents %>% filter(!(country == "Panama" & year < 1903 & is.na(v2x_corr)))

impevents <- impevents %>% mutate(
  impevent = ifelse(is.na(impevent), 0, impevent))

impevents <- impevents %>% group_by(country) %>% mutate(
  end_yr = ifelse(impevent > 0, year, NA_real_),
  end_yr = zoo::na.locf(end_yr, na.rm = FALSE), 
  indep_yrs = year - end_yr, 
  indep_yrs = ifelse(is.na(indep_yrs), year - 1897, indep_yrs))

#split dataframes into US imperialism and non-US imperialism
impevents <- impevents %>% group_by(country) %>% mutate(
  sum = sum(impevent),
  imperialized = ifelse(sum > 0, 1, 0)) %>% filter(year <= 2010)

impevents <- impevents[!duplicated(impevents), ]
write.csv(impevents, "impevents.csv")
rm(colony_subset, mil_int, mil_int_sub, vdem, vdem_region,vdem_subset, colony, imperialism_events, imperialism_eventsl)
