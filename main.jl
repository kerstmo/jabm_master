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

using Distributions
using Random
using Setfield
using CSV
using DataFrames
using Tables
using Dates


##############################
    ###   PARAMETERS   ###
##############################


            ####### NOTE #######
# some not required for existing population/contacts
# use -1 to make values being computed from input
            ####### NOTE  #######


#define population parameters
POP_SIZE = -1 #10000
HH_SIZE = -1  #5
HH_NUMBER = -1 #POP_SIZE/HH_SIZE

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


SEEDS = 10
ENDITER = 100


# Download OpenBerlinData population data from: "https://svn.vsp.tu-berlin.de/repos/public-svn/matsim/scenarios/countries/de/berlin/berlin-v5.5-1pct/output-berlin-v5.5-1pct/output_persons.csv.gz";

DATA_LOCATION = "/media/mk/McDrive/my_abm/input_data/"
DATA_NAME = "berlin-v5.5.3-1pct.output_persons.csv"

OUTPUT_LOCATION = "output/"

#which modules shall the programm use?
populationBuilder = "matsimPopulation.jl"
contactBuilder = "randomContacts.jl"
initialInfections = "randomInitInfections.jl"
initialVaccinations ="randomInitVaccinations.jl"
infectionModel = "randomAndHouseholdInfectionModel.jl"

# whether contacts are updatd daily (ito. per each iteration) or remain same
update_contacts = false

include("./runner.jl") # handles one realisation

println(string("HOORAY! FINISHED ALL TASKS!"))
