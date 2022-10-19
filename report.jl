
# print REPL output with some variables of interest
println("===================================")

println(string("Seed ", this_seed, " :: Iteration ", ITERATION))
println(" - - - - ")
println(string("Agents susceptible: ", get(STATETISTICS, "susceptible", -1 )))
println(string("Agents infected: ", get(STATETISTICS, "infected", -1 )))
println(string("Agents recovered: ", get(STATETISTICS, "recovered", -1 )))

println(string("S+I+R == popsize?  --", (get(STATETISTICS, "susceptible", -1) +
                                    get(STATETISTICS, "infected", -1) +
                                    get(STATETISTICS, "recovered", -1)) == POP_SIZE), "--")

println(string("Cumulative infections: ", get(STATETISTICS, "cumInf", -1 )))
println(" - - - - ")
println(string("Agents vaccinated: ", get(STATETISTICS, "vaccinated", -1 )))
println(string("Agents isolated: ", get(STATETISTICS, "hh_isolation", -1 )))
println("===================================")
println(" ")
