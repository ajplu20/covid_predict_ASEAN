# Covid_predict_ASEAN
Predicting the COVID pandemic in ASEAN states with Machine Learning


# Credits
The code in this folder is an upgraded version of code from https://github.com/nbanho/covid_predict.

Features in the original code were preserved to a great extent.

Changes were made to incorporate new models, new evaluation index, and new datasets from ASEAN countries.


# Working Features
EpiEstim model

EpiNow2 model

SARIMA model (aka arima)

Prophet model

Summer2 SIR model

CRPS evaluations

Quantile loss evalutions

AUC hotspot prediction

Secondary evaluation index (calibration, empirical coverage, sharpness, bias)


# Setup:
Ensure that the working directory for R and python are set to the current folder.

Open and run packages.R to install necessary R packages.

Run generate train and test.R in the ASEAN_files folder to generate relevant data files (optional, as all data files are included).

Refer to https://summer2.readthedocs.io/en/latest/install.html and https://github.com/monash-emu/estival for instructions on installing summer2 and estival in python. 

Look through summer2_model.py and ensure that you have all other relevant packages installed.


# Run Models
Open run_prediction.R and follow the instructions specified by the comments.

prediction outputs are in the predictions folder.

# Run Evaluations
Open the evaluation RMD file

Execute cell by cell, skip over any cell that mentions "by phase" or "phase labels".

To change the tau value for Quantile Loss, go to the quantile loss cell and change the tau value on top to whatever you desire within the range (0,1).

open results folder to view the pdf files of graphic results.

# Debugging Tips
1. Check to make sure that all relevant packages are installed.

2. If all packages are installed properly, check to see if your working directory is specified correctly

3. If working directories are also correctly specified, try changing code in run_prediction.R and summer2_model.py that refers to directories to explicitly refer to your computer's directory. For instance, change "summer2_model.py" to "C:/Users/ajplu/Desktop/urops/covid_predict-main/covid_predict_ASEAN/summer2_model.py" and "ASEAN_files/temp.csv" to "C:/Users/ajplu/Desktop/urops/covid_predict-main/covid_predict_ASEAN/ASEAN_files/temp.csv".
