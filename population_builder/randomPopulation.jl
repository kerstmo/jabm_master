
########################################################
    ###   DEFINE AGENT AND HOUSEHOLD STRUCTURE  ###
########################################################
# dictionary stores agent identifier as key and agent struct with properties
# as value. used to store infection, progression and other details. age is an
# example for sociodemographics atm and is not used in simulations yet. dict
# keys / agents are used for looping over entire populatioon as well. same for
# household
SEX = ["female", "male"]


struct household
    household_id::Int
    member_ids
end

mutable struct agent
    agent_id::Int32
    household_id::Int32
    age::Int8
    sex::String
    state::String
    in_quar::Bool
    time_infected::Int8
    time_recov::Int8
    contacts_hh
    contacts_other
    vaccinated::Bool
end



#############################################################
    ###   CONSTRUCT AGENTS WITH HOUSEHOLD STRUCTURE   ###
#############################################################
# agents are generated randomly in households of X agents each. age and sex
# are assigned s.t. older man and older woman live together with 3 younger
# agents of random sex.


agent_dict = Dict()
household_dict = Dict()



for i in 1:HH_NUMBER

    local hh_agent_list = []
    household_number = floor(Int,i)
    for j in 1:HH_SIZE

        # get some in-hosuehold stuff right (children, mother, father, etc. Not required atm but may be useful later on)
        # todo: write code that constructs nice households
        global agent_number = floor(Int,j+(i-1)*HH_SIZE)

        if j < HH_SIZE-1
            agent_age = floor(Int, rand(Uniform(0,20)))
            agent_sex = randomchoice(SEX)
        end
        if j == HH_SIZE -1
            agent_age = floor(Int, rand(Uniform(20,100)))
            agent_sex = SEX[1]
        end
        if j == HH_SIZE
            agent_age = floor(Int, rand(Uniform(20,100)))
            agent_sex = SEX[2]
        end

        #this line actually creates the agents one by one
        #@eval $(Symbol("agent_$agent_number")) = $agent($agent_number, $i, $agent_age, $agent_sex, "susceptible", false, -1, -1, [], [], false)
        agent_dict[ ("agent_$agent_number") ] = agent(agent_number, i, agent_age, agent_sex, "susceptible", false, -1, -1, [], [], false)

        push!(hh_agent_list, "agent_$agent_number")
    end
    household_dict[ ("household_$household_number") ] = household(household_number, hh_agent_list)
    hh_agent_list = nothing
end
