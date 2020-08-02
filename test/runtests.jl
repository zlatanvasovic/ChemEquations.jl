using ChemEquations
using Test

for str in ("compound", "chemequation", "balance")
    @testset "$str.jl" begin
        include("$str.jl")
    end
end
