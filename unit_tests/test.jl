include("..\\epanet_module.jl")
using Test

"""Sets of tests writen for the example of the network 3 from the EPANET"""
@testset "Start Epanet" begin
    @test EpanetModule.ENopen("unit_tests\\Net3.inp", "") === nothing
    @test EpanetModule.ENopenH() === nothing
    @test EpanetModule.ENinitH() === nothing
    @test EpanetModule.ENrunH() == 0
end

@testset "Elements" begin
    @testset "Links" begin
        @test EpanetModule.ENgetlinkindex("129") == 23
        @test EpanetModule.ENgetlinkindex("Not existing link") == "Error 204: function call contains undefined link"
        @test EpanetModule.ENgetlinkid(23) == "129"
        @test EpanetModule.ENgetlinkid(-999) == "Error 204: function call contains undefined link"
        @test EpanetModule.ENgetlinktype(97) == 1
        @test EpanetModule.ENgetlinknodes(27) == (25, 26)
        @test EpanetModule.ENgetlinkvalue(27, 5) == 130
    end

    @testset "Nodes" begin
        @test EpanetModule.ENgetnodeindex("129") == 25
        @test EpanetModule.ENgetnodeid(25) == "129"
        @test EpanetModule.ENgetnodeindex("Not existing node") == "Error 203: function call contains undefined node"
    end
end