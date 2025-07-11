# libraries
library(EpiNow2)

# utilities
source("utils/delays.r")
source("utils/prior_R.R")

#' @title train and predict using EpiNow2
#' 
#' @param ... args$data: data.frame with columns date, cases, incidence; 
#'            args$seed: seed
#'            args$n: the number of days to forecast ahead
#'            args$d: the number of posterior draws
#'            
#' @return A d x n matrix fcast of the posterior draws for the incidence


train_and_predict.epinow2 <- function(est_rt, ...) {

  # arguments 
  args <- c(as.list(environment()), list(...))

  # rename and select columns
  # filter very low incidence
  #' i.e. cumulative cases >= 10 or cumulative incidence >=1
  #' EpiNow2 may otherwise not initialize as leading zeros cannot effectively be removed
  data <- data.frame(date = args$data$date,
                     confirm = args$data$cases,
                     incidence = args$data$incidence) %>%
    mutate(cum_cases = cumsum(confirm),
           cum_incidence = cumsum(incidence)) %>%
    dplyr::filter(cum_cases >= 10 | cum_incidence >= 1) %>%
    dplyr::select(date, confirm)
  #print("data is")
  #print(data)
  
  
  # parameters
  if (est_rt == "backcalc" ) {
    rto <- NULL
    gpo <- NULL
  } else if (est_rt == "rw") {
    rto <- rt_opts(prior = list(mean = rt_prior_mean, sd = rt_prior_sd), 
                   use_breakpoints = F, pop = args$pop)
    gpo <- NULL
  } else if (est_rt == "gp") {
    rto <- rt_opts(prior = list(mean = rt_prior_mean, sd = rt_prior_sd), 
                   use_breakpoints = F, pop = args$pop)
    gpo <- gp_opts(basis_prop = .2, ls_min = 3, alpha_sd = .1)
  } else {
    stop("Invalid est_rt options")
  }
  # fit model
  estimates <- epinow(reported_cases = data,
                      generation_time = generation_time,
                      delays = delay_opts(dist_spec(reporting_delay$mean,reporting_delay$sd,reporting_delay$mean_sd,reporting_delay$sd_sd, "lognormal", reporting_delay$max) + incubation_period),
                      backcalc = backcalc_opts(prior_window = 7),
                      rt = rto,
                      gp = gpo,
                      stan = stan_opts(samples = args$d, seed = args$seed),
                      horizon = args$n,
                      output = "samples")

  # get samples
  samples <- estimates$estimates$samples
  
  # filter
  samples <- samples %>%
    dplyr::filter(variable == "reported_cases") %>%
    dplyr::filter(type == "forecast")
  
  # transform
  fcast <- samples %>%
    dplyr::select(sample, time, value) %>%
    spread(time, value) %>%
    dplyr::select(-sample) %>%
    as.matrix() %>%
    t()
  
  return(fcast)
}
