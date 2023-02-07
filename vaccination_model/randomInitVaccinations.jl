#######################################
    ### RANDOM Vaccination MODEL ###
#######################################


# required inputs:
    # agent_id_list  :: list of agent ids
    # agent_dict     :: dict(k,v) with k:agent_id, v:agent-object
    # VACC_SHARE, POP_SIZE

#
# function random_keys(d::Dict, n::Int)
#     keys_array = collect(keys(d))
#     return sample(keys_array, min(n, length(keys_array)))
# end



println("Initial Vaccinations ....")

global vaccinated_agents = random_keys(agent_dict, convert(Int,VACC_SHARE*POP_SIZE))

for agent in vaccinated_agents
    agent_dict["$agent"].vaccinated = true
end


STATETISTICS["vaccinated"] = STATETISTICS["vaccinated"]+length(vaccinated_agents)


println("Initial Vaccinations .... DONE")
