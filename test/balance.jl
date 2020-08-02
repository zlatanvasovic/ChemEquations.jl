combustion = ce"C2H4 + O2 = CO2 + 2 H2O"
redox = ce"H{+} + Cr2O7{2-} + C2H5OH = Cr{3+} + CO2 + H2O"

@testset "equationmatrix" begin
    @test equationmatrix(combustion) == [
        2  0  1  0
        4  0  0  2
        0  2  2  1
    ]
    @test equationmatrix(redox) == [
        1   0  6  0  0  2
        0   2  0  1  0  0
        0   7  1  0  2  1
        0   0  2  0  1  0
        1  -2  0  3  0  0
    ]
    @test equationmatrix(ce"151 H2 + 32 O2 = 7 H2O") ==
        equationmatrix(ce"5 H2 + O2 = 5 H2O")
end

@testset "balance" begin
    @test balance(equationmatrix(combustion)) == [
        1  0  0  0  -1   1   0
        0  2  1  0   0   0   1
        0  0  2  0   1   0   0
        0  0  0  1   3  -2  -2
    ]
    @test balance(equationmatrix(redox)) == [
        1  0  0  0  1   1  0  0   0   0    0
        0  1  0  0  3   0  0  0   1   0    0
        0  0  1  0  4  12  1  0  -2   0   -6
        0  0  0  1  4   4  0  0   0   1   -2
        0  0  0  0  6  14  1  0  -2   0   -7
        0  0  0  0  0  16  2  1  -4  -2  -11
    ]
    @test balance(equationmatrix(ce"H2 + O2 = H2O")) ==
        balance(equationmatrix(ce"2 H2 + O2 = 2 H2O"))

    # Original equation should be unchanged
    balanced_combustion = balance(combustion)
    @test combustion == combustion

    # Examples from https://www.webqc.org/balance.php
    equations = [
        "Fe + Cl2 = FeCl3" =>
            "2 Fe + 3 Cl2 = 2 FeCl3",
        "KMnO4 + HCl = KCl + MnCl2 + H2O + Cl2" =>
            "2 KMnO4 + 16 HCl = 2 KCl + 2 MnCl2 + 8 H2O + 5 Cl2",
        "K4Fe(CN)6 + H2SO4 + H2O = K2SO4 + FeSO4 + (NH4)2SO4 + CO" =>
            "K4Fe(CN)6 + 6 H2SO4 + 6 H2O = 2 K2SO4 + FeSO4 + 3 (NH4)2SO4 + 6 CO",
        "C6H5COOH + O2 = CO2 + H2O" =>
            "2 C6H5COOH + 15 O2 = 14 CO2 + 6 H2O",
        "K4Fe(CN)6 + KMnO4 + H2SO4 = KHSO4 + Fe2(SO4)3 + MnSO4 + HNO3 + CO2 + H2O" =>
            "10 K4Fe(CN)6 + 122 KMnO4 + 299 H2SO4 = 162 KHSO4 + 5 Fe2(SO4)3 + 122 MnSO4 + 60 HNO3 + 60 CO2 + 188 H2O",
        "Cr2O7{-2} + H{+} + {-} = Cr{+3} + H2O" =>
            "Cr2O7{-2} + 14 H{+} + 6 e = 2 Cr{+3} + 7 H2O",
        "S{-2} + I2 = I{-} + S" =>
            "S{-2} + I2 = 2 I{-} + S",
        "PhCH3 + KMnO4 + H2SO4 = PhCOOH + K2SO4 + MnSO4 + H2O" =>
            "5 PhCH3 + 6 KMnO4 + 9 H2SO4 = 5 PhCO2H + 3 K2SO4 + 6 MnSO4 + 14 H2O",
        "CuSO4*5H2O = CuSO4 + H2O" =>
            "CuSO4*5H2O = CuSO4 + 5 H2O"
    ]
    for equation ∈ equations
        @test balance(ChemEquation(equation[1])) == ChemEquation(equation[2])
    end

    @test_throws ErrorException balance(ce"H2 + O = H + O")
    @test_throws ErrorException balance(ce"H2 + CO = H2O")
end
