
# reset running variables after each realisation
vaccinated_agents = []
infected_agents = []

# reset agents to default
for i in keys(agent_dict)
    agent_dict[i].state = "susceptible"
    agent_dict[i].in_quar = false
    agent_dict[i].time_infected = -1
    agent_dict[i].time_recov = -1
    agent_dict[i].contacts_hh = []
    agent_dict[i].contacts_other = []
    agent_dict[i].vaccinated = false
end
