
#########################################
    ### RANDOM INITIAL INFECTIONS ###
#########################################

println("Initial Infections ....")




global infected_agents =  random_keys(agent_dict, trunc(Int,INIT_INF_SHARE*POP_SIZE))

for agent in infected_agents
    agent_dict["$agent"].state = "infected"
    agent_dict["$agent"].time_infected = 0
end

STATETISTICS["susceptible"] = STATETISTICS["susceptible"]-length(infected_agents)
STATETISTICS["infected"] = STATETISTICS["infected"]+length(infected_agents)
STATETISTICS["cumInf"] = STATETISTICS["cumInf"]+length(infected_agents)

include("..\\report.jl")

println("Initial Infections .... DONE")
