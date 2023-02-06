# https://svn.vsp.tu-berlin.de/repos/public-svn/matsim/scenarios/countries/de/berlin/berlin-v5.5-1pct/output-berlin-v5.5-1pct/
####

#Pkg.add("EzXML")
using LightXML, DataFrames

# data= String(read("/media/mk/McDrive/jabm_data/berlin-v5.5.3-1pct.output_events.xml"))
data= "/media/mk/McDrive/jabm_data/berlin-v5.5.3-1pct.output_events.xml"



global df_rawActivities = DataFrame(time = String[],
                                    agentID = String[],
                                    eventType = String[],
                                    x = String[],
                                    y = String[],
                                    actType = String[],
                                    containerID = String[])



# Open the XML file for reading
open(data, "r") do f
    # Read each line of the file
    linenumber = 1
    linecheck = 1

    for line in eachline(f)
        if occursin("200939301" , line)
            println(line)
        end
        ### print counter to REPL
        if linenumber % linecheck == 0
            println(linenumber)
            # println(line)
            linecheck = linecheck *10
        end
        linenumber = linenumber + 1


        if occursin( "person",  line )
        # if occursin( "8448401", line )  && occursin( "actType", line)

            local this_agentID = rsplit(rsplit(line, "\" link")[1], "person=\"")[2]
            local this_x = rsplit(rsplit(line, "\" y")[1], "x=\"")[2]
            local this_y = rsplit(rsplit(line, "\" actType")[1], "y=\"")[2]
            local this_time = replace(String(rsplit(rsplit(line, " type=")[1], "=")[2]), "\"" => "")

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
            end
            if occursin("PersonLeavesVehicle", line)
                local this_eventType = "PersonLeavesVehicle"
            end
            if occursin("waitingForPt", line)
                local this_eventType = "waitingForPt"
            end


            local this_containerID = "unknown"
            local this_actType = "unknown"
            #
            if occursin("home", line)
                local this_actType = "home"
                local this_containerID = replace(replace(string(rsplit(rsplit(this_line, "\" actType=")[2], "_")[2]), " " => ""), "\"/>" => "")
            elseif occursin("leisure", line)
                local this_actType = "leisure"
                local this_containerID = replace(replace(string(rsplit(rsplit(this_line, "\" actType=")[2], "_")[2]), " " => ""), "\"/>" => "")
            elseif occursin("shopping", line)
                local this_actType = "shopping"
                local this_containerID = replace(replace(string(rsplit(rsplit(this_line, "\" actType=")[2], "_")[2]), " " => ""), "\"/>" => "")
            elseif occursin("other", line)
                local this_actType = "other"
                local this_containerID = replace(replace(string(rsplit(rsplit(this_line, "\" actType=")[2], "_")[2]), " " => ""), "\"/>" => "")
            elseif occursin("freight", line) & ! occursin("freight interaction", line)
                local this_actType = "freight"
            #
            #
            elseif occursin("car interaction", line)
                local this_actType = "car interaction"
                local this_containerID = rsplit(rsplit(this_line, "\" link=")[2], " x")[1]
            elseif occursin("pt interaction", line)
                local this_actType = "pt interaction"
                local this_containerID = rsplit(rsplit(this_line, "\" link=")[2], " x")[1]
            elseif occursin("ride interaction", line)
                local this_actType = "ride interaction"
                local this_containerID = rsplit(rsplit(this_line, "\" link=")[2], " x")[1]
            elseif occursin("freight interaction", line)
                local this_actType = "freight interaction"
                local this_containerID = rsplit(rsplit(this_line, "\" link=")[2], " x")[1]
            #
            #
            elseif occursin("PersonEntersVehicle", line) & occursin("legMode=\"pt\"", line)
                local this_actType = "enterVehiclePt"
                local this_containerID = replace(replace(string(rsplit(rsplit(this_line, "\" vehicle=")[2], "_")[2]), " " => ""), "\"/>" => "")
            elseif occursin("PersonLeavesVehicle"), line) & occursin("legMode=\"pt\"", line)
                local this_actType = "leaveVehiclePt"
                local this_containerID = replace(replace(string(rsplit(rsplit(this_line, "\" vehicle=")[2], "_")[2]), " " => ""), "\"/>" => "")
            #
            elseif occursin("PersonEntersVehicle", line) & occursin("legMode=\"pt\"", line)
                local this_actType = "enterVehiclePt"
                local this_containerID = replace(replace(string(rsplit(rsplit(this_line, "\" vehicle=")[2], "_")[2]), " " => ""), "\"/>" => "")
            elseif occursin("PersonLeavesVehicle"), line) & occursin("legMode=\"pt\"", line)
                local this_actType = "leaveVehiclePt"
                local this_containerID = replace(replace(string(rsplit(rsplit(this_line, "\" vehicle=")[2], "_")[2]), " " => ""), "\"/>" => "")



            # else
                # local this_actType = replace(rsplit(rsplit(line, "\" actType=")[2], "_")[1], "\"" =>"")
            end


            # if occursin("_", line) & !occursin("freight", line) & !occursin("pt interaction", line)
            #     local this_containerID = replace(replace(string(rsplit(rsplit(this_line, "\" actType=")[2], "_")[2]), " " => ""), "\"/>" => "")
            # end
            #
            #
            # if occursin("freight", line) | occursin("interaction", line)
            #     println(line)
            # end
            #

            push!(df_rawActivities, [this_time,
                                    this_agentID,
                                    this_eventType,
                                    this_x,
                                    this_y,
                                    this_actType,
                                    this_containerID]
                )

        end
    end
end


print(df_rawActivities)



equals_freight(actType::String) = actType == "freight"
equals_ptinteraction(actType::String) = actType == "pt interaction"

equals_person(actType::String) = agentID == "134165901"




println( filter(:actType => equals_freight, df_rawActivities) )
println( filter(:actType => equals_ptinteraction, df_rawActivities) )

println( filter(:agentID => equals_person, df_rawActivities) )



    <event time="110460.0" type="vehicle leaves traffic" person="pt_pt_M48---17457_700_7_1_Bus_veh_type" link="pt_39219" vehicle="pt_M48---17457_700_7_1" networkMode="car" relativePosition="1.0"  />
1745770071
