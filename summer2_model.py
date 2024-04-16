#make sure to import all relevant packages!
import sys
sys.executable # This is required for pymc parallel evaluation in notebooks
import summer2
import multiprocessing as mp
import platform

if platform.system() != "Windows":
    mp.set_start_method('forkserver')
    
import numpy as np
import pandas as pd
import numpy as np

import os
from summer2.extras import test_models
import estival
# The following imports are the 'building blocks' of estival models
import nevergrad as ng
# Targets represent data we are trying to fit to
from estival import targets as est
# We specify parameters using (Bayesian) priors
from estival import priors as esp
# Finally we combine these with our summer2 model in a BayesianCompartmentalModel (BCM)
from estival.model import BayesianCompartmentalModel
import inspect
from estival.wrappers import pymc as epm
import pymc as pm
import arviz as az




data = pd.read_csv('ASEAN_files/temp.csv')
days = data.date
sicks = data.cases
incid = data.incidence
#print(days)
#print(sicks)
#print(incid)
m = test_models.sir()
defp =  m.get_default_parameters()

time_weight = pd.Series(1, range(len(days)))

targets = [
    est.NegativeBinomialTarget("incidence", sicks, 
        esp.UniformPrior("incidence_dispersion",(0.1, sicks.max()*0.1)  )) #is this stdev? If so, why is it the result of this function?
]

priors = [ #how did we get these priors?
    esp.UniformPrior("contact_rate", (0.01,1.0)),
    esp.TruncNormalPrior("recovery_rate", 0.5, 0.2, (0.01,1.0)),
]
bcm = BayesianCompartmentalModel(m, defp, priors, targets)

with pm.Model() as model:
    # This is all you need - a single call to use_model
    variables = epm.use_model(bcm)
    
    # The log-posterior value can also be output, but may incur additional overhead
    # Use jacobian=False to get the unwarped value (ie just the 'native' density of the priors
    # without transformation correction factors)
    # pm.Deterministic("logp", model.logp(jacobian=False))
    
    # Now call a sampler using the variables from use_model
    # In this case we use the Differential Evolution Metropolis sampler
    # See the PyMC docs for more details
    try:
    # Your code that may raise an exception
    # For example, let's try to divide by zero
        idata = pm.sample(step=[pm.DEMetropolis(variables)], draws=2000, tune=0,cores=4,chains=4)
        
    except:
    # If an exception occurs, execute certain code
        result = np.zeros((14, 2000))
        df = pd.DataFrame(result)
        df.to_csv('ASEAN_files/output.csv', index=False)
    # End the execution of the program
        sys.exit()
    

from estival.sampling.tools import likelihood_extras_for_idata
likelihood_df = likelihood_extras_for_idata(idata, bcm)

ldf_sorted = likelihood_df.sort_values(by="logposterior",ascending=False)

#create output array
result = np.zeros((14, 2000))

for i in range(2000):
    #print("I now is ")
    #print(i)
    map_params = idata.posterior.to_dataframe().loc[ldf_sorted.index[i]].to_dict()
    map_res = bcm.run(map_params)
    variable = "incidence"
    for j in range(14):
        result[j,i] = map_res.derived_outputs[variable][53-(14-j)]

# Export the DataFrame to a CSV file named "result.csv"
df = pd.DataFrame(result)
df.to_csv('ASEAN_files/output.csv', index=False)
