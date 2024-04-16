# models
models <- c("epiestim", "epinow2", "epidemia", "arima", "prophet", "gp")
model_names <- c("EpiEstim", "EpiNow2", "Epidemia", "SARIMA", "Prophet", "GP")
names(model_names) <- models

# states
states <- c("BN", "KH", "ID", "LA", "MY", "MM", "PH", "SG", "TH", "VN")
state_names <- c("Brunei", "Cambodia", "Indonesia", 
                 "Laos", "Malaysia", "Myanmar", 
                 "Philippines", "Singapore", "Thailand", "Vietnam")
names(state_names) <- states

# phases
phase_names <- c("exponential growth", "subexponential growth", "plateau", 
                 "subexponential decline", "exponential decline")
phase_names_abrv <- c("Exponential\ngrowth", "Subexponential\ngrowth", "Plateau", 
                      "Subexponential\ndecline", "Exponential\ndecline")
phase_names_abrv2 <- c("Exponential growth", "Subexponential growth", "Plateau", 
                       "Subexponential decline", "Exponential decline")
names(phase_names_abrv) <- phase_names
names(phase_names_abrv2) <- phase_names