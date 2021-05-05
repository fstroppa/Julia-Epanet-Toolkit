include("..\\epanet_toolkit.jl")
em = Epanet
using Test
using Suppressor

#  From https://www.epa.gov/water-research/epanet
network_path = "unit_tests\\Net3.inp"

function initialize_epanet()
    @suppress_out em.ENopen(network_path)
    @suppress_out em.ENopenH()
    @suppress_out em.ENinitH()
    @suppress_out em.ENrunH()
    @suppress_out em.ENopenQ()
    @suppress_out em.ENinitQ()
    @suppress_out em.ENrunQ()
end

function close_epanet()
    @suppress_out em.ENclose()
end

"""Sets of tests writen for the example of the network 3 from the EPANET"""

@testset "Epanet-ToolKit" begin
    @testset "Start Epanet" begin
        @test em.ENopen(network_path) === nothing
        @test em.ENopenH() === nothing
        @test em.ENinitH() === nothing
        @test em.ENrunH() == 0
        @test em.ENopenQ() === nothing
        @test em.ENinitQ() === nothing
        @test em.ENrunQ() == 0
        @test em.ENclose() === nothing
    end

    @testset "Solvers" begin
        initialize_epanet()
        @test em.ENsolveH() === nothing
        @test em.ENsolveQ() === nothing
        close_epanet()
    end

    @testset "Run" begin
        initialize_epanet()
        @test em.ENrunH() == 0
        @test em.ENrunQ() == 0
        close_epanet()
    end
    
    @testset "Save" begin
        initialize_epanet()
        @test em.ENsaveinpfile("test.inp") === nothing
        close_epanet()
    end

    @testset "next" begin
        initialize_epanet()
        @test em.ENstepQ() == 86400
        @test em.ENnextH() == 3600
        @test em.ENnextQ() == 3600
        @test em.ENrunH() == 3600
        @test em.ENrunQ() == 3600
        @test em.ENstepQ() == 82800
        close_epanet()
    end

    @testset "Control" begin
        initialize_epanet()
        @test em.ENgetcontrol(1) == (2, 118, 1.0, 0, 3600)
        @test em.ENsetcontrol(1, 2, 3, 0, 0, 500.0) === nothing
        @test em.ENgetcontrol(1) == (2, 3, 0, 0, 500)
        @test em.ENsetcontrol(2, 1, 1, 1, 1, 1) === nothing
        @test em.ENgetcontrol(2) == (1, 1, 1, 1, 1)
        @test_throws em.EpanetException em.ENgetcontrol(-999)
        close_epanet()
    end

    @testset "Count" begin
        initialize_epanet()
        @test em.ENgetcount(em.COUNT.NODE) == 97
        @test em.ENgetcount(em.COUNT.TANK) == 5
        @test em.ENgetcount(em.COUNT.LINK) == 119
        @test em.ENgetcount(em.COUNT.PAT) == 5
        @test em.ENgetcount(em.COUNT.CURVE) == 2
        @test em.ENgetcount(em.COUNT.CONTROL) == 6
        @test_throws em.EpanetException em.ENgetcount(-999)
        close_epanet()
    end

    @testset "Node Parameters" begin
        initialize_epanet()
        @test em.ENgetnodevalue(1, em.NODE_PARAMETER.ELEVATION) == 147
        @test em.ENgetnodevalue(1, em.NODE_PARAMETER.BASEDEMAND) == 0
        @test em.ENgetnodevalue(1, em.NODE_PARAMETER.PATTERN) == 1
        @test em.ENgetnodevalue(1, em.NODE_PARAMETER.EMITTER) == 0
        @test em.ENgetnodevalue(1, em.NODE_PARAMETER.INITQUAL) == 0
        @test_throws em.EpanetException em.ENgetnodevalue(1, em.NODE_PARAMETER.SOURCEQUAL)
        @test_throws em.EpanetException em.ENgetnodevalue(1, em.NODE_PARAMETER.SOURCEPAT)
        @test_throws em.EpanetException em.ENgetnodevalue(1, em.NODE_PARAMETER.SOURCETYPE)
        @test em.ENgetnodevalue(1, em.NODE_PARAMETER.TANKLEVEL) == 0
        @test em.ENgetnodevalue(1, em.NODE_PARAMETER.DEMAND) == 0
        @test em.ENgetnodevalue(1, em.NODE_PARAMETER.HEAD) ≈ 145.52339
        @test em.ENgetnodevalue(1, em.NODE_PARAMETER.PRESSURE) ≈ -0.63981503
        @test em.ENgetnodevalue(1, em.NODE_PARAMETER.QUALITY) == 0
        @test_throws em.EpanetException em.ENgetnodevalue(1, em.NODE_PARAMETER.SOURCEMASS) 
        @test em.ENgetnodevalue(1, em.NODE_PARAMETER.INITVOLUME) == 0
        @test em.ENgetnodevalue(1, em.NODE_PARAMETER.MIXMODEL) == 0
        @test em.ENgetnodevalue(1, em.NODE_PARAMETER.MIXZONEVOL) == 0
        @test em.ENgetnodevalue(1, em.NODE_PARAMETER.TANKDIAM) == 0
        @test em.ENgetnodevalue(1, em.NODE_PARAMETER.MINVOLUME) == 0
        @test em.ENgetnodevalue(1, em.NODE_PARAMETER.VOLCURVE) == 0
        @test em.ENgetnodevalue(1, em.NODE_PARAMETER.MINLEVEL) == 0
        @test em.ENgetnodevalue(1, em.NODE_PARAMETER.MAXLEVEL) == 0
        @test em.ENgetnodevalue(1, em.NODE_PARAMETER.MIXFRACTION) == 1
        @test em.ENgetnodevalue(1, em.NODE_PARAMETER.TANK_KBULK) == 0
        close_epanet()
    end

    @testset "Link Parameters" begin
        initialize_epanet()
        @test em.ENgetlinkvalue(1, em.LINK_PARAMETER.DIAMETER) == 99
        @test em.ENgetlinkvalue(1, em.LINK_PARAMETER.LENGTH) == 99
        @test em.ENgetlinkvalue(1, em.LINK_PARAMETER.ROUGHNESS) == 199
        @test em.ENgetlinkvalue(1, em.LINK_PARAMETER.MINORLOSS) == 0
        @test em.ENgetlinkvalue(1, em.LINK_PARAMETER.INITSTATUS) == 1
        @test em.ENgetlinkvalue(1, em.LINK_PARAMETER.INITSETTING) == 199
        @test em.ENgetlinkvalue(1, em.LINK_PARAMETER.KBULK) == 0
        @test em.ENgetlinkvalue(1, em.LINK_PARAMETER.KWALL) == 0
        @test em.ENgetlinkvalue(1, em.LINK_PARAMETER.FLOW) ≈ -2246.2974
        @test em.ENgetlinkvalue(1, em.LINK_PARAMETER.VELOCITY) ≈ 0.0936
        @test em.ENgetlinkvalue(1, em.LINK_PARAMETER.HEADLOSS) ≈ 1.7537064*10e-6
        @test em.ENgetlinkvalue(1, em.LINK_PARAMETER.STATUS) == 1
        @test em.ENgetlinkvalue(1, em.LINK_PARAMETER.SETTING) == 199
        @test em.ENgetlinkvalue(1, em.LINK_PARAMETER.DIAMETER) == 99
        @test em.ENgetlinkvalue(1, em.LINK_PARAMETER.ENERGY) ≈ 7.4256145*10e-7
        @test em.ENgetlinkvalue(100, em.LINK_PARAMETER.DIAMETER) == 8
        close_epanet()
    end

    @testset "Time parameters" begin
        initialize_epanet()
        @test em.ENgettimeparam(em.TIME_PARAMETER.DURATION) == 86400
        @test em.ENgettimeparam(em.TIME_PARAMETER.HYDSTEP) == 3600
        @test em.ENgettimeparam(em.TIME_PARAMETER.QUALSTEP) == 300
        @test em.ENgettimeparam(em.TIME_PARAMETER.PATTERNSTEP) == 3600
        @test em.ENgettimeparam(em.TIME_PARAMETER.PATTERNSTART) == 0
        @test em.ENgettimeparam(em.TIME_PARAMETER.REPORTSTEP) == 3600
        @test em.ENgettimeparam(em.TIME_PARAMETER.REPORTSTART) == 0
        @test em.ENgettimeparam(em.TIME_PARAMETER.RULESTEP) == 360
        @test em.ENgettimeparam(em.TIME_PARAMETER.STATISTIC) == 0
        @test em.ENgettimeparam(em.TIME_PARAMETER.PERIODS) == 0
        close_epanet()
    end

    @testset "Node Types" begin
        initialize_epanet()
        @test em.ENgetnodetype(1) == em.NODE_TYPE.JUNCTION
        @test em.ENgetnodetype(93) == em.NODE_TYPE.RESERVOIR
        @test em.ENgetnodetype(95) == em.NODE_TYPE.TANK
        @test_throws em.EpanetException em.ENgetnodetype(-999)
    end

    @testset "Link Types" begin
        initialize_epanet()
        @test em.ENgetlinktype(1) == em.LINK_TYPE.PIPE
        @test em.ENgetlinktype(93) == em.LINK_TYPE.PIPE
        @test em.ENgetlinktype(119) == em.LINK_TYPE.PUMP
        @test_throws em.EpanetException em.ENgetlinktype(-999)
        close_epanet()
    end

    @testset "Links" begin
        initialize_epanet()
        @test em.ENgetlinkindex("129") == 23
        @test_throws em.EpanetException em.ENgetlinkindex("Not existing link")
        @test em.ENgetlinkid(23) == "129"
        @test_throws em.EpanetException em.ENgetlinkid(-999)
        @test em.ENgetlinktype(97) == 1
        @test em.ENgetlinknodes(27) == (25, 26)
        @test em.ENgetlinkvalue(27, 5) == 130
        close_epanet()
    end

    @testset "Nodes" begin
        initialize_epanet()
        @test em.ENgetnodeindex("129") == 25
        @test em.ENgetnodeid(25) == "129"
        @test_throws em.EpanetException em.ENgetnodeindex("Not existing node")
        close_epanet()
    end
end

