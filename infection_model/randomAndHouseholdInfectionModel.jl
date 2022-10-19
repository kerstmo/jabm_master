
# model in-household infections. not blocked by isolation
for k in infected_agents
    local hh_contacts = copy(agent_dict["$k"].contacts_hh)
    for j in hh_contacts
        if agent_dict["$j"].state == "susceptible" &&
            rand() < PROBA_TRANS_HH &&
            agent_dict["$j"].vaccinated == false

            agent_dict["$j"].state = "infected"
            agent_dict["$j"].time_infected = ITERATION
            STATETISTICS["susceptible"] = STATETISTICS["susceptible"]-1
            STATETISTICS["infected"] = STATETISTICS["infected"]+1
            STATETISTICS["cumInf"] = STATETISTICS["cumInf"]+1
            push!(infected_agents, string(j))
        end
    end
end


# model outside infections
for k in infected_agents
    local other_contacts =  agent_dict["$k"].contacts_other
    for j in other_contacts
        if agent_dict["$j"].state == "susceptible" &&
            rand() < PROBA_TRANS_OTHER &&
            agent_dict["$j"].vaccinated == false

            agent_dict["$j"].state = "infected"
            agent_dict["$j"].time_infected = ITERATION
            STATETISTICS["susceptible"] = STATETISTICS["susceptible"]-1
            STATETISTICS["infected"] = STATETISTICS["infected"]+1
            STATETISTICS["cumInf"] = STATETISTICS["cumInf"]+1
            push!(infected_agents, string(j))
        end
    end
end


# note: number of contacts, max number of contacts, impact of isolation etc all
# considered in contact builder
