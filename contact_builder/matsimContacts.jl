# https://svn.vsp.tu-berlin.de/repos/public-svn/matsim/scenarios/countries/de/berlin/berlin-v5.5-1pct/output-berlin-v5.5-1pct/
####

#Pkg.add("EzXML")
using LightXML, DataFrames

# data= String(read("/media/mk/McDrive/jabm_data/berlin-v5.5.3-1pct.output_events.xml"))
data= "/media/mk/McDrive/jabm_data/berlin-v5.5.3-1pct.output_events.xml"


mutable struct container
    actType
    agent_list
    cum_contact_time
end

open_containers = Dict()
open_containers2 = Dict()



global df_rawActivities = DataFrame(time = String[],
                                    agentID = String[],
                                    eventType = String[],
                                    x = String[],
                                    y = String[],
                                    actType = String[],
                                    containerID = String[])


# fill, when agents leave
global contacts_df = DataFrame(time = String[],
                                    agentID_1 = String[],
                                    agentID_2 = String[],
                                    containerID = String[],
                                    containerType = String[],
                                    this_x = String[],
                                    this_y = String[],
                                    contactTime = Int32)




# Open the XML file for reading
open(data, "r") do f

    # Read each line of the file
    linenumber = 1
    linecheck = 1

    for line in eachline(f)

        ### print counter to REPL
        if linenumber % linecheck == 0
            println(linenumber)
            # println(line)
            linecheck = linecheck *10
        end
        linenumber = linenumber + 1


        if occursin( "person",  line )
            # if occursin( "61627901", line )
            #     println(line)
            # end

            local this_agentID = rsplit(rsplit(line, "\" link")[1], "person=\"")[2]
            local this_time = replace(String(rsplit(rsplit(line, " type=")[1], "=")[2]), "\"" => "")

            if occursin("x=", line)
                local this_x = rsplit(rsplit(line, "\" y")[1], "x=\"")[2]
                local this_y = rsplit(rsplit(line, "\" actType")[1], "y=\"")[2]
            else
                local this_x = "unknown"
                local this_y = "unknown"
            end


            local this_eventType = "unknown"
            #
            if occursin("actend", line)
                local this_eventType = "actend"
            end
            if occursin("actstart", line)
                local this_eventType = "actstart"
            end
            if occursin("departure", line)
                local this_eventType = "departure"
            end
            if occursin("travelled", line)
                local this_eventType = "travelled"
            end
            if occursin("arrival", line)
                local this_eventType = "arrival"
            end
            if occursin("PersonEntersVehicle", line)
                local this_eventType = "PersonEntersVehicle"
                this_agentID = rsplit(this_agentID, "\"")[1]
            end
            if occursin("PersonLeavesVehicle", line)
                local this_eventType = "PersonLeavesVehicle"
                this_agentID = rsplit(this_agentID, "\"")[1]
            end
            if occursin("waitingForPt", line)
                local this_eventType = "waitingForPt"
            end
            if occursin("interaction", line)
                local this_eventType = "test"
            end

            local this_containerID = "unknown"
            local this_actType = "unknown"
            #
            if occursin("home", line)
                local this_actType = "home"
                local this_containerID = "home_" * replace(replace(string(rsplit(rsplit(line, "\" actType=")[2], "_")[2]), " " => ""), "\"/>" => "")
            elseif occursin("leisure", line)
                local this_actType = "leisure"
                local this_containerID = "leisure_" * replace(replace(string(rsplit(rsplit(line, "\" actType=")[2], "_")[2]), " " => ""), "\"/>" => "")
            elseif occursin("work_", line)
                local this_actType = "work"
                local this_containerID = "work_" * replace(replace(string(rsplit(rsplit(line, "\" actType=")[2], "_")[2]), " " => ""), "\"/>" => "")
            elseif occursin("shopping", line)
                local this_actType = "shopping"
                local this_containerID = "shopping_" * replace(replace(string(rsplit(rsplit(line, "\" actType=")[2], "_")[2]), " " => ""), "\"/>" => "")
            elseif occursin("other", line)
                local this_actType = "other"
                local this_containerID = "other_" * replace(replace(string(rsplit(rsplit(line, "\" actType=")[2], "_")[2]), " " => ""), "\"/>" => "")
            elseif occursin("freight", line) & ! occursin("freight interaction", line)
                local this_actType = "freight"
                local this_containerID = "freight_unknown"
            #
            #
            elseif occursin("car interaction", line)
                local this_actType = "car interaction"
                local this_containerID = "carInteraction_" * rsplit(rsplit(line, "\" link=")[2], " x")[1]
            elseif occursin("pt interaction", line)
                local this_actType = "pt interaction"
                local this_containerID = "ptInteraction_" * rsplit(rsplit(line, "\" link=")[2], " x")[1]
            elseif occursin("ride interaction", line)
                local this_actType = "ride interaction"
                local this_containerID = "rideInteraction_" * rsplit(rsplit(line, "\" link=")[2], " x")[1]
            elseif occursin("freight interaction", line)
                local this_actType = "freight interaction"
                local this_containerID = "freightInteraction_" * rsplit(rsplit(line, "\" link=")[2], " x")[1]
            #
            #vehicle="pt
            elseif occursin("PersonEntersVehicle", line) & occursin("vehicle=\"pt", line) &! occursin("person=\"pt", line)
                local this_actType = "pt"
                local this_containerID = "ptVehicle_" * string(rsplit(rsplit(line, "\" vehicle=\"")[2], "\"")[1])
                this_eventType = "actstart"
            elseif occursin("PersonLeavesVehicle", line) & occursin("vehicle=\"pt", line) &! occursin("person=\"pt", line)
                local this_actType = "pt"
                local this_containerID = "ptVehicle_" * string(rsplit(rsplit(line, "\" vehicle=\"")[2], "\"")[1])
                this_eventType = "actend"
            end

            push!(df_rawActivities, [this_time,
                                    this_agentID,
                                    this_eventType,
                                    this_x,
                                    this_y,
                                    this_actType,
                                    this_containerID]
            )


            # on the fly: create containers with in/out information of agents and add contactIDs and contact durations to agent_dict

            # if this is the first occurence of the container create it here
            # current time is the timestamp when the agent enters the contianer.
            # excepion: home contianers created when aagents leave first (are home from 0:current)
            if this_actType != "car interaction" &&
                this_actType != "ride interaction" &&
                this_actType != "pt interaction" &&
                this_actType != "freight" &&
                this_actType != "freight interaction"

                if this_containerID ∉ keys(open_containers) && this_containerID != "unknown"
                    if this_actType == "home"
                        open_containers[("$this_containerID")] = container(this_actType, Dict(this_agentID => Dict(1 => ("0", this_time))), "0")
                    else
                        open_containers[("$this_containerID")] = container(this_actType, Dict(this_agentID => Dict(1 => (this_time, "unknown"))), "0")
                    end
                #
                #
                # if container already exists, set agents entry and exit times
                else
                    if this_eventType == "actstart"
                        open_containers[this_containerID].agent_list[this_agentID]  =  Dict( 1 => (this_time, "unknown") )
                    end

                    if this_eventType == "actend"

                        if this_agentID in keys(open_containers[this_containerID].agent_list)
                            open_containers["$this_containerID"].agent_list[this_agentID][length(keys(open_containers["$this_containerID"].agent_list[this_agentID]))]  = (open_containers["$this_containerID"].agent_list[this_agentID][1][1], this_time)
                        else
                            open_containers["$this_containerID"].agent_list[this_agentID]  = Dict( 1 => ("0", this_time))
                        end
                    end
                end
                #TODO include inner forloop if agent enters container multiple times (i.e. home)
                # vemiede ich doppelerfassung von pärchen?
                if occursin("actend", line)
                    # conti = open_containers["ptVehicle_pt_M11---17441_700_56_2"]
                    conti = open_containers["$this_containerID"]

                    for this_agentID in collect(keys(conti.agent_list))
                        this_agent = conti.agent_list[this_agentID]

                        for other_agentID in collect(keys(conti.agent_list))
                            other_agent = conti.agent_list[other_agentID]

                            if this_agentID != other_agentID
                                # entry time of leaving agent %in% c(entry time staying agent, exit time staying agent)

                                if this_agent[1][1]  <  this_agent[1][2]  <  other_agent[1][2]
                                    this_contact_time =  parse(Float16, this_agent[1][1]) - max(parse(Float16, other_agent[1][2]), parse(Float16, this_agent[1][1]))
                                    push!(df_rawActivities, [this_time,#when agent1 leaves
                                                            this_agentID,
                                                            other_agentID,
                                                            this_containerID,
                                                            this_actType,
                                                            this_contact_time]
                                    )

                                end
                            end
                        end
                    end
                end
            end
        end
    end
end


open_containers["leisure_20400.0"]
