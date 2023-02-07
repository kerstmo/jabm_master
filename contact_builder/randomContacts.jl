
##############################################
    ###   CONSTRUCT CONTACT PATTERNS   ###
##############################################

# nur die infected werden durchgeloopt. jeder agent hat jeden tag 10 zufällige
# neue kontakte.
# zusätzlich haben alle fünf haushaltsmitglieder kontakt.
# die nicht-household kontakte sind so gestaltet, dass jeder externe agent
# Kontakt wiederum maximal 10 kontakte mit infektiösen agenten haben kann. So
# muss keine kontaktmatrix für alle agenten gebildet werden.

#
# agent_dict["42398601"]
# agent_dict["42398601"].household_id
# household_dict["948000"]



for i in infected_agents
    global hh_contacts = []
    global other_contacts = []
    global this_household_id = string(agent_dict[string(i)].household_id)
    hh_contacts =  copy(household_dict[this_household_id].member_ids)
    deleteat!(hh_contacts, findall(x->x== i,hh_contacts)) # i has not contact with herselves

    if agent_dict["$i"].in_quar == false
        while length(other_contacts) < MAX_CONTACTS_OTHER
            local new_contact = random_keys(agent_dict, 1)[1]

            if new_contact ∉ other_contacts &&
                new_contact != i &&
                agent_dict[new_contact].in_quar == false &&
                length(agent_dict[new_contact].contacts_other) < MAX_CONTACTS_OTHER

                push!(other_contacts, new_contact)
            end

        end
    end

    agent_dict["$i"].contacts_other = other_contacts
    agent_dict["$i"].contacts_hh = hh_contacts
    other_contacts = nothing
end
