using Suppressor

include("epanet_toolkit.jl")
em = Epanet

network_path = "unit_tests\\Net3.inp"

em.ENopen(network_path)
em.ENopenH()
em.ENinitH()
em.ENrunH()
nodes = em.getDictOfNodeIndexes()
junctions = nodes[em.NODE_TYPE.JUNCTION]
links = em.getDictOfLinkIndexes()
pumps = links[em.LINK_TYPE.PUMP]

# Calculating the total energy
energy = sum(em.ENgetlinkvalue(pump, em.LINK_PARAMETER.ENERGY) for pump in pumps)
println(energy)

# Calculating the max and min pressures: Example 1 - From dict
max_pressure = maximum(em.ENgetnodevalue(junction, em.NODE_PARAMETER.PRESSURE) for junction in nodes[em.NODE_TYPE.JUNCTION])
min_pressure = minimum(em.ENgetnodevalue(junction, em.NODE_PARAMETER.PRESSURE) for junction in nodes[em.NODE_TYPE.JUNCTION])


# Calculating the max and min pressures: Example 2 - From list
max_pressure = maximum(em.ENgetnodevalue(junction, em.NODE_PARAMETER.PRESSURE) for junction in junctions)
min_pressure = minimum(em.ENgetnodevalue(junction, em.NODE_PARAMETER.PRESSURE) for junction in junctions)

# Calculating the max and min pressures: Example 3 - With extrema
pressures = [em.ENgetnodevalue(junction, em.NODE_PARAMETER.PRESSURE) for junction in junctions]
min_pressure, max_pressure = extrema(pressures)

# Calculating the max and min pressures: Example 4 - As a function
junction_pressures() = [em.ENgetnodevalue(junction, em.NODE_PARAMETER.PRESSURE) for junction in junctions]
min_pressure, max_pressure = extrema(junction_pressures())

# Calculating the max and min pressures: Example 5 - For the first 5 simulations
junction_pressures() = [em.ENgetnodevalue(junction, em.NODE_PARAMETER.PRESSURE) for junction in junctions]
for i in 1:5
    em.ENrunH()
    min_pressure, max_pressure = extrema(junction_pressures())
    println(min_pressure, "   ", max_pressure)
    em.ENnextH()
end
