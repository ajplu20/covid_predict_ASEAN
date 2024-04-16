# libraries
library(covidcast)
library(tidyverse)
library(highcharter)
library(lubridate)
source("helper/plotting.r")
source("settings/defaults.r")
library("COVID19")


# time series data for all Asean countries
countries <- c("BN", "KH", "ID", "LA", "MY", "MM", "PH", "SG", "TH", "VN")
df_all_ASEAN <- covid19(country = countries, level = 1)

#replace all NA with 0
df_all_ASEAN[is.na(df_all_ASEAN)] <- 0

#rename confirmed as cases
colnames(df_all_ASEAN)[colnames(df_all_ASEAN) == "confirmed"] <- "cases"


#turn cumulative case into daily new cases.

nation <- df_all_ASEAN$administrative_area_level_1[1]
prev_confirmed <- df_all_ASEAN$cases[1]
prev_death <- df_all_ASEAN$deaths[1]
df_all_ASEAN$cases[1] <- 0
df_all_ASEAN$deaths[1] <- 0

#create population csv
state_id <- c(df_all_ASEAN$iso_alpha_2[1])
pop <- c(df_all_ASEAN$population[1])

for (x in 1:length(df_all_ASEAN$date)) {
  curr_nation <- df_all_ASEAN$administrative_area_level_1[x]
  
  #if different country:
  if (curr_nation != nation){
    #add new country and population
    state_id[length(state_id) + 1] <- df_all_ASEAN$iso_alpha_2[x]
    pop[length(pop) + 1] <- df_all_ASEAN$population[x]
    
    
    prev_confirmed <- df_all_ASEAN$cases[x]
    prev_death <- df_all_ASEAN$deaths[x]
    df_all_ASEAN$cases[x] <- 0
    df_all_ASEAN$deaths[x] <- 0
    nation = curr_nation
  }
  #if same country
  else {
    
    new_cases <- df_all_ASEAN$cases[x] - prev_confirmed
    new_death <- df_all_ASEAN$deaths[x] - prev_death
    prev_confirmed <- df_all_ASEAN$cases[x]
    prev_death <- df_all_ASEAN$deaths[x]
    df_all_ASEAN$cases[x] <- pmax(new_cases, 0)
    df_all_ASEAN$deaths[x] <- pmax(new_death, 0)
  }
}

#create population dataframe
asean_census_population <- data.frame(state_id, pop)
write.csv(asean_census_population, "ASEAN_files/asean-census-population.csv", row.names=TRUE)


#Add incidence, incidence is the number of cases per 100,000, so formula is cases/population*100,000
df_all_ASEAN$incidence <- (df_all_ASEAN$cases / df_all_ASEAN$population) * 100000



# selected time period
start_date <- as.Date("1/22/2020", format = "%m/%d/%Y") #1/22/2020
end_date <- as.Date("1/22/2022", format = "%m/%d/%Y") #1/1/2022

# generate training and prediction data
n_preds <- 14
date_seq <- seq.Date(start_date, end_date %m-% days(n_preds), by = "week")
for (ct in countries) {
  df_ct <- dplyr::filter(df_all_ASEAN, iso_alpha_2 == ct)
  list_ct_train <- list()
  list_ct_test <- list()
  for (d in 1:length(date_seq)) {
    list_ct_train[[d]] <- df_ct %>%   #df st is a dataframe with country, date, cases, incidence
      dplyr::select(date, cases, incidence) %>%
      dplyr::filter(date < date_seq[d]) %>% 
      dplyr::filter(date >= date_seq[d] %m-% days(53))
    list_ct_test[[d]] <- df_ct %>% 
      dplyr::select(date, cases, incidence) %>%
      dplyr::filter(date >= date_seq[d]) %>% 
      dplyr::filter(date < date_seq[d] %m+% days(n_preds)) 
  }
  df_ct_train <- tibble(state = ct, forecast_date = date_seq, data = list_ct_train) #train set is all data
  df_ct_test <- tibble(state = ct, forecast_date = date_seq, data = list_ct_test) #test set is the data from start to end date
  saveRDS(df_ct_train, paste0("ASEAN_files/ASEAN_data/", ct, "-train.rds"))
  saveRDS(df_ct_test, paste0("ASEAN_files/ASEAN_data/", ct, "-test.rds"))
}

