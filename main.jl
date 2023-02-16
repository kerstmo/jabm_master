println(" ")
println(" ")
println("=.=.=.=.=.=.=.=.=.=.=.=.=.=.=.=")
println("A New Hope")
println("------------")

# import Pkg
# Pkg.add("Setfield")
# Pkg.add("Tables")
# Pkg.add("DataFrames")
# Pkg.add("Dates")
# Pkg.add("typemax")
using Distributions
using Random
using Setfield
using CSV
using DataFrames
using Tables
using Dates

using Statistics


##############################
    ###   PARAMETERS   ###
##############################


            ####### NOTE #######
# some not required for existing population/contacts
# use -1 to make values being computed from input
            ####### NOTE  #######


#define population parameters
POP_SIZE = 10000 #10000
HH_SIZE = 5  #5
HH_NUMBER = POP_SIZE/HH_SIZE

# define contact parameters relevant for infection
MAX_CONTACTS_HH = 5
MAX_CONTACTS_OTHER = 10

#define infection parameters
PROBA_TRANS_HH = 0.3
PROBA_TRANS_OTHER = 0.1
DURATION_INFECTION = 5
BEGIN_ISOLATION = 3


INIT_INF_SHARE = 0.01
VACC_SHARE = 0.8


SEEDS = 3
ENDITER = 20


# Download and gunzip OpenBerlinData population data from:
# "https://svn.vsp.tu-berlin.de/repos/public-svn/matsim/scenarios/countries/de/berlin/berlin-v5.5-1pct/output-berlin-v5.5-1pct/output_persons.csv.gz";
# edit DATA_LOCAITON and DATA_NAME

DATA_LOCATION = "/media/mk/McDrive/jabm_data/"
DATA_NAME = "berlin-v5.5.3-1pct.output_persons.csv"

OUTPUT_LOCATION = "output/"

#which modules shall the programm use?
populationBuilder = "matsimPopulation.jl"
contactBuilder = "matsimContacts.jl"
initialInfections = "randomInitInfections.jl"
initialVaccinations ="randomInitVaccinations.jl"
infectionModel = "randomAndHouseholdInfectionModel.jl"

# whether contacts are updatd daily (ito. per each iteration) or remain same
update_contacts = true

include("./runner.jl") # handles one realisation

println(string("HOORAY! FINISHED ALL TASKS!"))
