combustion = ce"C2H4 + O2 = CO2 + 2 H2O"
redox = ce"H{+} + Cr2O7{2-} + C2H5OH = Cr{3+} + CO2 + H2O"
cerational = ChemEquation{Rational}("1//2 H2 + O2 → H2O")
cefloat = ChemEquation{Float64}("0.33 N3 + 0.5 O2 = NO")

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
    @test equationmatrix(cerational) == [
        2//1  0//1  2//1
        0//1  2//1  1//1
    ]
    @test equationmatrix(cefloat) == [
        3.0  0.0  1.0
        0.0  2.0  1.0
    ]
    @test equationmatrix(ce"151 H2 + 32 O2 = 7 H2O") ==
        equationmatrix(ce"5 H2 + O2 = 5 H2O")
end

@testset "balancematrix" begin
    # [:,:] required to reshape Vector to Nx1 Array
    @test balancematrix(combustion) == [1//1; 3//1; -2//1; -2//1][:,:]
    @test balancematrix(redox, fractions=true) == [16//11; 2//11; 1//11; -4//11; -2//11; -1//1][:,:]
    @test balancematrix(cerational) == [1//1; 1//2; -1//1][:,:]
    @test balancematrix(cefloat) == [0.3333333333333333; 0.5; -1.0][:,:]
    @test balancematrix(ce"H2 + O2 = H2O") == balancematrix(ce"2 H2 + O2 = 2 H2O")
end

@testset "balance" begin
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
            "CuSO4*5H2O = CuSO4 + 5 H2O",
        "Zn(s) + O2(g) = ZnO(s)" => "2 Zn + O2 = 2 ZnO"
    ]
    for equation ∈ equations
        @test balance(ChemEquation(equation[1])) == ChemEquation(equation[2])
    end

    @test balance(cerational) == ChemEquation{Rational}("H2 + 1//2 O2 = H2O")
    @test balance(cefloat) == ChemEquation{Float64}("0.3333333333333333 N3 + 0.5 O2 = NO")
    @test balance(combustion, fractions=true) == ChemEquation{Rational}("1//2 C2H4 + 3//2 O2 = CO2 + H2O")

    @test_throws ErrorException balance(ce"H2 + O = H + O")
    @test_throws ErrorException balance(ce"H2 + CO = H2O")
end
