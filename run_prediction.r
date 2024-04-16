# run the entire R file first.
library(reticulate)


run_prediction <- function(state, model) {
  # arguments
  args <- commandArgs(trailingOnly = TRUE)
  args <- c(state, model)
  states <- unlist(stringr::str_split(args[1], "8"))
  models <- unlist(stringr::str_split(args[2], "8"))
  
  
  # settings
  source("settings/defaults.r")
  
  # libraries 
  library(tidyverse)
  
  # models
  source("models/epiestim.r")
  source("models/epinow2.r")
  #source("models/epidemia.r")
  source("models/arima.r")
  source("models/prophet.r")
  source("models/gp.r")
  
  # state population  
  cc <- read_csv("ASEAN_files/asean-census-population.csv")
  
  if (grepl("all", models[1])) {
    models <- c("epiestim", "epinow2", "arima", "prophet", "gp")
  }

  # 
  if (grepl("all", states[1])) {
    states <- unique(stringi::stri_extract(list.files("ASEAN code/ASEAN_data/"), regex = "\\w{2}")) 
  } 

  for (mod in models) {
    for (j in 1:length(states)) {
      # train and data
      state <- states[j]
      train_df_state <- readRDS(paste0("ASEAN_files/ASEAN_data/", state, "-train.rds")) 
      test_df_state <- readRDS(paste0("ASEAN_files/ASEAN_dat/summer2_dataset/", state, "-test.rds"))
      
      # loop over forecasting dates
      K <- nrow(train_df_state) #for every 7 day period
      for (k in 1:K) {
        print(k)
        if (all(train_df_state$data[[k]]$incidence<=0.1) 
            | 
            (mod == "epinow2" & 
             ((all(cumsum(train_df_state$data[[k]]$incidence) < 1))&(all(cumsum(train_df_state$data[[k]]$cases) < 10)))
            )
            |
            (k == 9 & state == "KH")
            |
            (k == 45 & state == "LA")
        ) {
          
          #print("in if")
          predicted <- matrix(0, nrow = n_preds, ncol = n_draws)
        } else { #train once using dataset attached.
          # train and predict
          #print("in else")
            if (mod == 'summer2'){
              #make a csv file for it
              write.csv(train_df_state$data[[k]], file = "ASEAN_files/temp.csv", row.names = TRUE)
                system("python summer2_model.py")
              predicted <- as.matrix(read.csv("ASEAN_files/output.csv", sep = ","), n_preds, n_draws)
            }
          else {
            predicted <- train_and_predict(model = mod, data = train_df_state$data[[k]], 
                                           seed = seed12345, n = n_peds, d = n_draws,
                                           pop = cc$pop[toupper(cc$state_id) == state])
          }
          #result of training should be 2000 predictions per day.
        }
        
        #stick all the 2000 prediction*14 days into one matrix.
        test_df_state$data[[k]]$ forecast <- get_samples(predicted, test_df_state$data[[k]], n_preds)
      }
      #BN_train 90 is 2021-10-06
      
      # save
      print("arrived at save")
      print(test_df_state)
      saveRDS(test_df_state, paste0("predictions/", state, "_", mod, ".rds"))
    }
  } 
}


#change the vector models and states to include ONLY the models and ASEAN states you want to run for

models <- c("summer2", "epiestim", "epinow2", "arima", "prophet")
states <- c("BN", "KH", "ID", "LA", "MY", "MM", "PH", "SG", "TH", "VN")


#run the loop below to ensure that the combination of models and states are as you desire
#uncomment the run_prediction function and run the loop to run every model.

for (s in states){
  for (m in models){
    print(s)
    print(m)
    #run_prediction(s,m)
  }
}
