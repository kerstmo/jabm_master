

struct household
    household_id::Int32
    member_ids
end

mutable struct agent
    agent_id::Int32
    household_id::Int32
    home_zone::String
    state::String
    hh_iso::Bool
    time_infected::Int8
    time_recov::Int8
    contacts_hh
    contacts_other
    vaccinated::Bool
end


agent_list=[]
agent_id_list=[]

household_list=[]
household_id_list=[]



println("load population data...")
popdata = CSV.File(string(DATA_LOCATION, DATA_NAME))|> DataFrame
POP_SIZE = size(popdata,1)
println("load population data... DONE")



println("------------")
println("Create Agents ....")
global z = 1
for this_agent in 1:size(popdata,1)

    if popdata[this_agent,"subpopulation"] == "person"
        agent_number = parse(Int32, (filter(isdigit, popdata[this_agent, "person"])))
        household_number = parse(Int32, (filter(isdigit, popdata[this_agent, "first_act_type"])))
        home_zone = popdata[this_agent, "home_zone"]

        push!(agent_id_list, "$agent_number")
        push!(agent_list, agent(agent_number, household_number, home_zone, "susceptible", false, 0, 0, [], [], false))

        if string(household_number) ∉ household_id_list
            push!(household_id_list, "$household_number")
            push!(household_list, household(household_number, [agent_number]))
        else
            push!(household_list[findall(x -> x == string(household_number),household_id_list)[1]].member_ids, agent_number)
        end
    end
    global agent_dict = Dict(agent_id_list .=>  agent_list)
    global household_dict = Dict(household_id_list .=>  household_list)

    if z%10000 == 0
        println(string("Agents parsed: ", z))
    end
    global z+=1
end


println("Create Agents .... DONE")


# xx = household(123,[])
# testdict = Dict(123 => xx)
# push!(testdict[123].member_ids, 789)
# testdict
