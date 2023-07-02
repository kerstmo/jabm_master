# agents recover after x days and end isolation.

for i in infected_agents
    this_agent = string(i)
    recovery = (ITERATION - agent_dict[this_agent].time_infected) > DURATION_INFECTION

    if recovery
        agent_dict[this_agent].state = "recovered"
        agent_dict[this_agent].in_quar = false
        agent_dict[this_agent].time_recov = ITERATION

        STATETISTICS["infected"] = STATETISTICS["infected"]-1
        STATETISTICS["recovered"] = STATETISTICS["recovered"]+1
        STATETISTICS["hh_isolation"] = STATETISTICS["hh_isolation"]-1

        deleteat!(infected_agents, findall(x->x== this_agent,infected_agents))
    end
end
