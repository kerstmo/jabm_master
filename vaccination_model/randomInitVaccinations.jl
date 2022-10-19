#######################################
    ### RANDOM Vaccination MODEL ###
#######################################


# required inputs:
    # agent_id_list  :: list of agent ids
    # agent_dict     :: dict(k,v) with k:agent_id, v:agent-object
    # VACC_SHARE, POP_SIZE


println("Initial Vaccinations ....")

global vaccinated_agents = []
while length(vaccinated_agents) < round(VACC_SHARE*POP_SIZE,digits=0)

    # new_agent = string("agent_", floor(Int, rand(Uniform(1,POP_SIZE))))

    new_agent = randomchoice(agent_id_list)

    if new_agent ∉ vaccinated_agents && agent_dict["$new_agent"].state == "susceptible"
        push!(vaccinated_agents, new_agent)
        agent_dict["$new_agent"].vaccinated = true
        STATETISTICS["vaccinated"] = STATETISTICS["vaccinated"]+1
    end
end

println("Initial Vaccinations .... DONE")
