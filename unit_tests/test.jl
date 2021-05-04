include("..\\epanet_toolkit.jl")

using Test
using Suppressor

network_path = "unit_tests\\Net3.inp"
function initialize_epanet()
    @suppress_out Epanet.ENopen(network_path)
    @suppress_out Epanet.ENopenH()
    @suppress_out Epanet.ENinitH()
    @suppress_out Epanet.ENrunH()
    @suppress_out Epanet.ENopenQ()
    @suppress_out Epanet.ENinitQ()
    @suppress_out Epanet.ENrunQ()
end

function close_epanet()
    @suppress_out Epanet.ENclose()
end

"""Sets of tests writen for the example of the network 3 from the EPANET"""

@testset "Epanet-ToolKit" begin
    @testset "Start Epanet" begin
        @test Epanet.ENopen(network_path) === nothing
        @test Epanet.ENopenH() === nothing
        @test Epanet.ENinitH() === nothing
        @test Epanet.ENrunH() == 0
        @test Epanet.ENopenQ() === nothing
        @test Epanet.ENinitQ() === nothing
        @test Epanet.ENrunQ() == 0
        @test Epanet.ENclose() === nothing
    end

    @testset "Solvers" begin
        initialize_epanet()
        @test Epanet.ENsolveH() === nothing
        @test Epanet.ENsolveQ() === nothing
        close_epanet()
    end

    @testset "Run" begin
        initialize_epanet()
        @test Epanet.ENrunH() == 0
        @test Epanet.ENrunQ() == 0
        close_epanet()
    end
    
    @testset "Save" begin
        initialize_epanet()
        @test Epanet.ENsaveinpfile("test.inp") === nothing
        close_epanet()
    end

    @testset "next" begin
        initialize_epanet()
        @test Epanet.ENstepQ() == 604800
        @test Epanet.ENnextH() == 900
        @test Epanet.ENnextQ() == 900
        @test Epanet.ENrunH() == 900
        @test Epanet.ENrunQ() == 900
        @test Epanet.ENstepQ() == 603900
        close_epanet()
    end

    @testset "Control" begin
        initialize_epanet()
        @test Epanet.ENgetcontrol(1) == (2, 118, 1.0, 0, 3600)
        @test Epanet.ENsetcontrol(1, 2, 3, 0, 0, 500.0) === nothing
        @test Epanet.ENgetcontrol(1) == (2, 3, 0, 0, 500)
        @test Epanet.ENsetcontrol(2, 1, 1, 1, 1, 1) === nothing
        @test Epanet.ENgetcontrol(2) == (1, 1, 1, 1, 1)
        @test Epanet.ENgetcontrol(-999) == "Error 241: function call contains nonexistent control"
        close_epanet()
    end

    @testset "Count" begin
        initialize_epanet()
        @test Epanet.ENgetcount(Epanet.COUNT.NODE) == 97
        @test Epanet.ENgetcount(Epanet.COUNT.TANK) == 5
        @test Epanet.ENgetcount(Epanet.COUNT.LINK) == 119
        @test Epanet.ENgetcount(Epanet.COUNT.PAT) == 5
        @test Epanet.ENgetcount(Epanet.COUNT.CURVE) == 2
        @test Epanet.ENgetcount(Epanet.COUNT.CONTROL) == 18
        @test Epanet.ENgetcount(-999) == "Error 251: function call contains invalid parameter code"
        close_epanet()
    end

    @testset "Node Parameters" begin
        initialize_epanet()
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.ELEVATION) == 147
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.BASEDEMAND) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.PATTERN) == 1
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EMITTER) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.INITQUAL) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.SOURCEQUAL) == "Error 240: function call contains nonexistent source"
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.SOURCEPAT) == "Error 240: function call contains nonexistent source"
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.SOURCETYPE) == "Error 240: function call contains nonexistent source"
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.TANKLEVEL) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.DEMAND) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.HEAD) ≈ 145.52339
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.PRESSURE) ≈ -0.63981503
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.QUALITY) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.SOURCEMASS) == "Error 240: function call contains nonexistent source"
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.INITVOLUME) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.MIXMODEL) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.MIXZONEVOL) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.TANKDIAM) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.MINVOLUME) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.VOLCURVE) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.MINLEVEL) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.MAXLEVEL) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.MIXFRACTION) == 1
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.TANK_KBULK) == 0
        close_epanet()
    end

    @testset "Link Parameters" begin
        initialize_epanet()
        @test Epanet.ENgetlinkvalue(1, Epanet.LINK_PARAMETER.DIAMETER) == 99
        @test Epanet.ENgetlinkvalue(1, Epanet.LINK_PARAMETER.LENGTH) == 99
        @test Epanet.ENgetlinkvalue(1, Epanet.LINK_PARAMETER.ROUGHNESS) == 199
        @test Epanet.ENgetlinkvalue(1, Epanet.LINK_PARAMETER.MINORLOSS) == 0
        @test Epanet.ENgetlinkvalue(1, Epanet.LINK_PARAMETER.INITSTATUS) == 1
        @test Epanet.ENgetlinkvalue(1, Epanet.LINK_PARAMETER.INITSETTING) == 199
        @test Epanet.ENgetlinkvalue(1, Epanet.LINK_PARAMETER.KBULK) == 0
        @test Epanet.ENgetlinkvalue(1, Epanet.LINK_PARAMETER.KWALL) == 0
        @test Epanet.ENgetlinkvalue(1, Epanet.LINK_PARAMETER.FLOW) ≈ -2246.2974
        @test Epanet.ENgetlinkvalue(1, Epanet.LINK_PARAMETER.VELOCITY) ≈ 0.0936
        @test Epanet.ENgetlinkvalue(1, Epanet.LINK_PARAMETER.HEADLOSS) ≈ 1.7537064*10e-6
        @test Epanet.ENgetlinkvalue(1, Epanet.LINK_PARAMETER.STATUS) == 1
        @test Epanet.ENgetlinkvalue(1, Epanet.LINK_PARAMETER.SETTING) == 199
        @test Epanet.ENgetlinkvalue(1, Epanet.LINK_PARAMETER.DIAMETER) == 99
        @test Epanet.ENgetlinkvalue(1, Epanet.LINK_PARAMETER.ENERGY) ≈ 7.4256145*10e-7
        @test Epanet.ENgetlinkvalue(100, Epanet.LINK_PARAMETER.DIAMETER) == 8
        close_epanet()
    end

    @testset "Time parameters" begin
        initialize_epanet()
        @test Epanet.ENgettimeparam(Epanet.TIME_PARAMETER.DURATION) == 604800
        @test Epanet.ENgettimeparam(Epanet.TIME_PARAMETER.HYDSTEP) == 900
        @test Epanet.ENgettimeparam(Epanet.TIME_PARAMETER.QUALSTEP) == 900
        @test Epanet.ENgettimeparam(Epanet.TIME_PARAMETER.PATTERNSTEP) == 3600
        @test Epanet.ENgettimeparam(Epanet.TIME_PARAMETER.PATTERNSTART) == 0
        @test Epanet.ENgettimeparam(Epanet.TIME_PARAMETER.REPORTSTEP) == 900
        @test Epanet.ENgettimeparam(Epanet.TIME_PARAMETER.REPORTSTART) == 0
        @test Epanet.ENgettimeparam(Epanet.TIME_PARAMETER.RULESTEP) == 90
        @test Epanet.ENgettimeparam(Epanet.TIME_PARAMETER.STATISTIC) == 0
        @test Epanet.ENgettimeparam(Epanet.TIME_PARAMETER.PERIODS) == 0
        close_epanet()
    end

    @testset "Node Types" begin
        initialize_epanet()
        @test Epanet.ENgetnodetype(1) == Epanet.NODE_TYPE.JUNCTION
        @test Epanet.ENgetnodetype(93) == Epanet.NODE_TYPE.RESERVOIR
        @test Epanet.ENgetnodetype(95) == Epanet.NODE_TYPE.TANK
        @test Epanet.ENgetnodetype(-999) == "Error 203: function call contains undefined node"
        close_epanet()
    end

    @testset "Link Types" begin
        initialize_epanet()
        @test Epanet.ENgetlinktype(1) == Epanet.LINK_TYPE.PIPE
        @test Epanet.ENgetlinktype(93) == Epanet.LINK_TYPE.PIPE
        @test Epanet.ENgetlinktype(119) == Epanet.LINK_TYPE.PUMP
        @test Epanet.ENgetlinktype(-999) == "Error 204: function call contains undefined link"
        close_epanet()
    end

    @testset "Elements" begin
        initialize_epanet()
        @testset "Links" begin
            @test Epanet.ENgetlinkindex("129") == 23
            @test Epanet.ENgetlinkindex("Not existing link") == "Error 204: function call contains undefined link"
            @test Epanet.ENgetlinkid(23) == "129"
            @test Epanet.ENgetlinkid(-999) == "Error 204: function call contains undefined link"
            @test Epanet.ENgetlinktype(97) == 1
            @test Epanet.ENgetlinknodes(27) == (25, 26)
            @test Epanet.ENgetlinkvalue(27, 5) == 130
        end

        @testset "Nodes" begin
            @test Epanet.ENgetnodeindex("129") == 25
            @test Epanet.ENgetnodeid(25) == "129"
            @test Epanet.ENgetnodeindex("Not existing node") == "Error 203: function call contains undefined node"
        end
        close_epanet()
    end
end

