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
        @test Epanet.ENgetcount(Epanet.COUNT.EN_NODECOUNT) == 97
        @test Epanet.ENgetcount(Epanet.COUNT.EN_TANKCOUNT) == 5
        @test Epanet.ENgetcount(Epanet.COUNT.EN_LINKCOUNT) == 119
        @test Epanet.ENgetcount(Epanet.COUNT.EN_PATCOUNT) == 5
        @test Epanet.ENgetcount(Epanet.COUNT.EN_CURVECOUNT) == 2
        @test Epanet.ENgetcount(Epanet.COUNT.EN_CONTROLCOUNT) == 18
        @test Epanet.ENgetcount(-999) == "Error 251: function call contains invalid parameter code"
        close_epanet()
    end

    @testset "Node Parameters" begin
        initialize_epanet()
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EN_ELEVATION) == 147
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EN_BASEDEMAND) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EN_PATTERN) == 1
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EN_EMITTER) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EN_INITQUAL) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EN_SOURCEQUAL) == "Error 240: function call contains nonexistent source"
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EN_SOURCEPAT) == "Error 240: function call contains nonexistent source"
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EN_SOURCETYPE) == "Error 240: function call contains nonexistent source"
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EN_TANKLEVEL) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EN_DEMAND) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EN_HEAD) ≈ 145.52339
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EN_PRESSURE) ≈ -0.63981503
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EN_QUALITY) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EN_SOURCEMASS) == "Error 240: function call contains nonexistent source"
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EN_INITVOLUME) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EN_MIXMODEL) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EN_MIXZONEVOL) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EN_TANKDIAM) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EN_MINVOLUME) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EN_VOLCURVE) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EN_MINLEVEL) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EN_MAXLEVEL) == 0
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EN_MIXFRACTION) == 1
        @test Epanet.ENgetnodevalue(1, Epanet.NODE_PARAMETER.EN_TANK_KBULK) == 0
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