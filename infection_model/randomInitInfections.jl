
#########################################
    ### RANDOM INITIAL INFECTIONS ###
#########################################

println("Initial Infections ....")

global infected_agents = []

while length(infected_agents) < INIT_INF_SHARE*POP_SIZE

    new_agent = randomchoice(agent_id_list)

    if new_agent ∉ infected_agents && agent_dict["$new_agent"].state == "susceptible" && agent_dict["$new_agent"].vaccinated == false
        push!(infected_agents, string(new_agent))
        agent_dict["$new_agent"].state = "infected"
        agent_dict["$new_agent"].time_infected = 0
        STATETISTICS["susceptible"] = STATETISTICS["susceptible"]-1
        STATETISTICS["infected"] = STATETISTICS["infected"]+1
        STATETISTICS["cumInf"] = STATETISTICS["cumInf"]+1
    end

end

include("../report.jl")

println("Initial Infections .... DONE")
