

function randomchoice(a::Array)
    n = length(a)
    idx = rand(1:n)
    return a[idx]
end

function exit_condition_iteration(a,b,c)
    if a < b && c != 0
        return true
    else
        return false
    end
end

function exit_condition_run(infections, infections_cap, edge_proba)
    if length(findall(infections .> infections_cap)) != edge_proba
        return true
    else
        return false
    end
end

function random_keys(d::Dict, n::Int)
    keys_array = collect(keys(d))
    return sample(keys_array, min(n, length(keys_array)))
end

global init_output_writer = 0


# runner iterates epidemic days for k random seeds, as long as infected agents
# left. additional exit conditions may be defined fulfilled. Population is
# created once


###############################
    ###    MAIN LOOP    ###
###############################

SEEDS = collect(1:SEEDS)

include(string("./population_builder/", populationBuilder)) # population remains same over all runs. create once

seed = SEEDS[1]
for seed in SEEDS # triggers n realisations with same seed
    Random.seed!(seed)
    global this_seed = seed
    global ITERATION = 0

    ################################################
        ###   CLEAR OR CREATE STATETISTICS   ###
    ################################################
    # statetistics dict is updated along all infection/progression/etc events
    # TODO: output to csv file on daily basis
    # TODO: create further outputs (i.e. infector vs infected)

    global STATETISTICS = nothing
    global STATETISTICS = Dict([("susceptible", POP_SIZE),
                        ("infected", 0),
                        ("recovered", 0),
                        ("cumInf", 0),
                        ("hh_isolation", 0),
                        ("vaccinated", 0)])


    include(string("./vaccination_model/",initialVaccinations))
    include(string("./infection_model/", initialInfections))
    include(string("./contact_builder/", contactBuilder))
    include("./writeOutput.jl")

    ##############################################
        ###  LOOP of ONE REALISATION/SEED  ###
    ##############################################

    global ITERATION = 1

    while STATETISTICS["infected"] != 0 && ENDITER > ITERATION

        include("./quarantineModel.jl")
        include(string("./infection_model/", infectionModel))
        include("./progressionModel.jl")
        include("./report.jl")

        if update_contacts == true
            include(string("./contact_builder/", contactBuilder))
        end

        include("./writeOutput.jl")

        global ITERATION += 1
    end

    if this_seed != SEEDS && ITERATION != ENDITER
        include("./clearAgents.jl") # reset agents,statetistics etc to default for next run
    end

end
