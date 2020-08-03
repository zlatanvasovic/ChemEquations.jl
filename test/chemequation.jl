water_formation = ce"2 H2 + O2 → 2 H2O"
ionic_reaction = ce"Na{+} + Cl{-} > NaCl"
redox = ce"Cr2O7{-2} + H{+1} + {-} = Cr{3+} + H2O"

@testset "ChemEquation" begin
    @test water_formation.tuples ==
        [(cc"H2", 2), (cc"O2", 1), (cc"H2O", -2)]
    @test ionic_reaction.tuples ==
        [(cc"Na{+1}", 1), (cc"Cl{-1}", 1), (cc"ClNa", -1)]
    @test ChemEquation("N2+O2⇌2NO").tuples ==
        [(cc"N2", 1), (cc"O2", 1), (cc"NO", -2)]
end

@testset "@ce_str" begin
    @test ce"2 H2 + O2 → 2 H2O" == water_formation
end

@testset "==" begin
    @test ce"H2 = O2" == ce"H2 = O2"
    @test ce"H2+O2=H2O" == ce"H2 +O2 =H2O"
    @test ce"H2+O2=H2O" ≠ ce"2H2+O2=2H2O"
end

@testset "string" begin
    @test string(water_formation) == "2 H2 + O2 = 2 H2O"
    @test string(ionic_reaction) == "Na{+} + Cl{-} = NaCl"
    @test string(redox) == "Cr2O7{-2} + H{+} + e = Cr{+3} + H2O"
end

@testset "show" begin
    @test isa(repr(water_formation), String)
end

@testset "compounds" begin
    @test compounds(water_formation) == [cc"H2", cc"O2", cc"H2O"]
    @test compounds(ionic_reaction) == [cc"Na{+}", cc"Cl{-}", cc"NaCl"]
    @test compounds(redox) == [cc"Cr2O7{-2}", cc"H{+}", cc"{-}", cc"Cr{+3}", cc"H2O"]
end

@testset "elements" begin
    @test elements(water_formation) == ["H", "O"]
    @test elements(ionic_reaction) == ["Na", "Cl"]
    @test elements(redox) == ["Cr", "O", "H", "e"]
end

@testset "hascharge" begin
    @test hascharge(water_formation) == false
    @test hascharge(ionic_reaction) == true
    @test hascharge(redox) == true
end
