water = cc"H2O"
H_ion = cc"H{+1}"
O_ion = cc"O{-2}"

@testset "Compound" begin
    @test Compound("{-1}").tuples == cc"{1-}".tuples ==
        cc"{-}".tuples == [("e", 1)]
    @test cc"Γ(Θ2Π)5".tuples == [("Γ", 1), ("Θ", 10), ("Π", 5)]
    @test cc"CoN5H15BrSO4".tuples ==
        [("Co", 1), ("N", 5), ("H", 15), ("Br", 1), ("S", 1), ("O", 4)]

    @test water.charge == 0
    @test H_ion.charge == 1
    @test O_ion.charge == -2
end

@testset "@cc_str" begin
    @test cc"H2O" == water
end

@testset "==" begin
    @test cc"H2" == cc"H2"
    @test cc"{-}" == cc"{-1}"
    @test cc"CH2(OH)2(CH)" == cc"O2H5C2"

    @test cc"H H" == cc"H2"
    @test cc"H_1C_1O_1" == cc"HCO"
    @test cc"Mg(OH)2(s)" == cc"Mg(OH)2(aq)"
end

@testset "string" begin
    @test string(cc"C1O1") == "CO"
    @test string(H_ion) == "H{+}"
    @test string(O_ion) == "O{-2}"

    @test string(cc"CuSO4*5H2O") == "CuSO9H10"
    @test string(cc"MgOH * OH * CO") == "MgO3H2C"
    @test string(cc"Mg OH * 5 (OH)2") == "MgO11H11"

    @test string(cc"H(OH)") == "H2O"
    @test string(cc"(XyZx)2{+2}") == "Xy2Zx2{+2}"
    @test string(cc"(CH3COOH)2Mg") == "C4H8O4Mg"
end

@testset "show" begin
    @test isa(repr(water), String) == true
end

@testset "elements" begin
    @test elements(water) == ["H", "O"]
end

@testset "hascharge" begin
    @test hascharge(water) == false
    @test hascharge(H_ion) == true
    @test hascharge(O_ion) == true
end
