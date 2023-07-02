# https://svn.vsp.tu-berlin.de/repos/public-svn/matsim/scenarios/countries/de/berlin/berlin-v5.5-1pct/output-berlin-v5.5-1pct/
####

#Pkg.add("EzXML")
using LightXML, DataFrames

# data= String(read("/media/mk/McDrive/jabm_data/berlin-v5.5.3-1pct.output_events.xml"))
# data= "/media/mk/McDrive/jabm_data/berlin-v5.5.3-1pct.output_events.xml"
data= "F:\\jabm_data\\berlin-v5.5.3-1pct.output_events.xml"



mutable struct container
    actType
    agent_list
    cum_contact_time
end

open_containers = Dict()
open_containers2 = Dict()

function showPersonOrVehicle(searchstring::String, dataset::String)
    println("              ")
    println("========================================")
    # Open the XML file for reading
    open(dataset, "r") do f
        for line in eachline(f)
            if occursin( "person",  line )
                if occursin( searchstring, line )
                    println(line)
                end 
            end
        end
    end
end






# yet unclear which data is required for further modules, thus kept in two df_events
    # df_events: record any event (an agent enters/leaves a container)
    # df_contacts: record any bilateral contact (two agents are in the same container at the same time)
        # fill, when agents leave. when agents leave a container they first have had to enter it (thus recorded in df_events)
        # exception: first home leave of the day

global df_events = DataFrame(time = String[],
                             agentID = String[],
                             containerID = String[],
                             enter_leave = String[],
                             actType = String[],
                             x = String[],
                             y = String[])

global df_contacts = DataFrame(startTime = String[],
                               endTime = String[],
                               agentID = String[],
                               contactID = String[],
                               contactTime = String[],
                               containerType = String[],
                               containerID = String[],
                               x = String[],
                               y = String[]) 



#print all lines containing string (i.e. show an agents itinerary or all events of an vehicle)
showPersonOrVehicle("pt_S25---10145_109_24_9", data)
showPersonOrVehicle("423068201", data)
showPersonOrVehicle("work_12000.0", data)


# Initializations
    # agentIDs: records all processed agentIDs. primary use: initialisation of yet unprocessed agents (which start their day at home)
    # containerIDs: create unique container IDs based on type (work, shop, etc.)
    # lookup_ptInteraction: stores all pt interactions before entering pt vehicle. remove entry after use (agent can only be in 1 stop/station at a time)
        #(used to determine x/y location of stop/station which is missing in enter/leave vehicle line)
agentIDs = []
containerIDs = []
lookup_ptinteraction = Dict()
lookup_agent_last = Dict()


# searchstrings: if line does not contains one of this entries it is skipped
# activities: basic acitivites for containr generation without transportation
# todo: is this complete?
searchstrings = ["home", "work", "shopping", "other", "leisure", 
                 "pt interaction", "waitingForPt", "PersonEntersVehicle", "PersonLeavesVehicle"]
activities = ["home", "work", "shopping", "other", "leisure"]


# main loop. iterates over each line of input data (i/o stream)
# Open the XML file for reading
open(data, "r") do f

    # Read each line of the file
    linenumber = 1
    linecheck = 1

    

    for line in eachline(f)


        # count and print number of processed lines
        if linenumber % linecheck == 0
            println(linenumber)
            # println(line)
            linecheck = linecheck *10
        end
        linenumber = linenumber + 1


        # events without personIDs can be skipped
        # events withoud certain strings can be skipped as well
        if !occursin("person=", line) | !any(occursin, searchstring, Ref(line))
            continue 
        end



        
            # events with pt interaction before waiting must be stored in dictionary. can be skipped afterwards
        if occursin("pt interaction", line) & !occursin(this_agentID, keys(lookup_ptinteraction))
            local this_x = rsplit(rsplit(line, "\" y=")[1], "x=\"")[2]
            local this_y = rsplit(rsplit(line, "\" actType=")[1], "y=\"")[2]
            lookup_ptinteraction[this_agentID] = [this_x, this_y, nothing]
            continue
        if occursin("pt interaction", line) & occursin(this_agentID, keys(lookup_ptinteraction))
            local this_agentID = rsplit(rsplit(line, "\" link")[1], "person=\"")[2]
            local this_time = replace(String(rsplit(rsplit(line, " type=")[1], "=")[2]), "\"" => "")
            local this_type = "actend"
            local this_actType = "pt"
            local this_objectID = get(lookup_ptinteraction, this_agentID)[3]
            local this_x = rsplit(rsplit(line, "\" y=")[1], "x=\"")[2]
            local this_y = rsplit(rsplit(line, "\" actType=")[1], "y=\"")[2]            
            delete!(lookup_agent_last, this_agentID)
            continue
        elseif occursin("waitingForPt", line)
            local this_agentID = rsplit(rsplit(line, "\" link")[1], "person=\"")[2]
            local this_time = replace(String(rsplit(rsplit(line, " type=")[1], "=")[2]), "\"" => "")
            local this_type = "actstart"
            local this_actType = "waitingForPt"
            local this_x = get(lookup_ptinteraction, this_agentID)[1]
            local this_y = get(lookup_ptinteraction, this_agentID)[2]
        elseif occursin("PersonEntersVehicle", line) 
            local this_agentID = rsplit(rsplit(line, "\" link")[1], "person=\"")[2]
            local this_time = replace(String(rsplit(rsplit(line, " type=")[1], "=")[2]), "\"" => "")
            local this_type1 = "actend"
            local this_type2 = "actstart"
            local this_actType1 = "waitingForPt"
            local this_actType2 = "pt"
            local this_objectID = rsplit(rsplit(line, "\"  />")[1], " vehicle=\"")[2]
            local this_x = get(lookup_ptinteraction, this_agentID)[1]
            local this_y = get(lookup_ptinteraction, this_agentID)[2]
            lookup_ptinteraction[this_agentID] = [this_x, this_y, this_objectID]
        elseif occursin("PersonLeavesVehicle", line)
            local this_agentID = rsplit(rsplit(line, "\" link")[1], "person=\"")[2]
            local this_time = replace(String(rsplit(rsplit(line, " type=")[1], "=")[2]), "\"" => "")
            local this_type = "actend"
            local this_actType = "pt"
            local this_x = nothing
            local this_y = nothing
        else
            local this_agentID = rsplit(rsplit(line, "\" link")[1], "person=\"")[2]
            local this_time = replace(String(rsplit(rsplit(line, " type=")[1], "=")[2]), "\"" => "")
            local this_type = rsplit(rsplit(line, "\" person=")[1], "type=\"")[2]
            local this_actType = rsplit(rsplit(line, "\"  />")[1], "actType=\"")[2]
            local this_x = rsplit(rsplit(line, "\" y=")[1], "x=\"")[2]
            local this_y = rsplit(rsplit(line, "\" actType=")[1], "y=\"")[2]




            # extract activity type information of current event
            if occursin("actType=", line) & !occursin("pt_interaction", line)
                local this_actType = rsplit(rsplit(rsplit(line, "\"  />")[1], "actType=\"")[2], "_")[1]
            elseif  occursin("waitingForPt=", line) 
                local this_actType = "waiting_for_pt"
            
                
            end
            


            # extact container id from current line
            if occursin("waitingForPt", line)
                local this_container = String(["stopPt", "_x=", this_x, "_y=", this_y])
            elseif occursin("PersonEntersVehicle", line) | occursin("PersonLeavesVehicle", line)
                local this_container = String(["vehicle_",  rsplit(rsplit(line, "\"  />")[1], "vehicle=\"")[2]])
            elseif any(occursin, activities, Ref(line))
                local this_container = String([this_actType, "_x=", this_x, "_y=", this_y])
            end
        end



        if !occursin(this_agentID, agentIDs)
            
            if !occursin("actType=\"home_")
                println("ERROR")
                break
            end

            push!(agentIDs, this_agentID)
        end
    end
end












priorline = line
 

#todo: am ende des tages die startzeit der ersten homeaktivität überprüfen


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

print(df_rawActivities)
open_containers["leisure_20400.0"]
