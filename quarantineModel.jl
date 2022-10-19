
# simple isolation model. agents go in isolation at home after x days.
# hh_isolation: agents can not infect agents outside household, but
# only household members with unchanged probability


for i in infected_agents
    if (ITERATION - agent_dict["$i"].time_infected) == BEGIN_ISOLATION
         agent_dict["$i"].hh_iso = true
         STATETISTICS["hh_isolation"] = STATETISTICS["hh_isolation"]+1
    end
end


# released from quarantine/isolation in progression model
