"""
Creates an equation matrix in which rows correspond to atoms
and columns correspond to compounds.

# Examples
```jldoctest
julia> equationmatrix(ce"H2 + Cl2 → HCl")
2×3 Array{Int64,2}:
 2  0  1
 0  2  1
```
"""
function equationmatrix(equation::ChemEquation)
    vect = elements(equation)
    charged = hascharge(equation)
    if charged && "e" ∉ vect
        push!(vect, "")
    end

    mat = zeros(Int, length(vect), length(equation.tuples))
    for (j, compoundtuple) ∈ enumerate(equation.tuples)
        compound = compoundtuple[1]
        for (element, k) ∈ compound.tuples
            i = findfirst(isequal(element), vect)
            mat[i, j] = k
        end
        if charged && hascharge(compound)
            mat[end, j] = compound.charge
        end
    end

    return mat
end

"""
Balances an equation matrix using the *nullspace method*.

# References
- [Thorne (2009)](https://arxiv.org/ftp/arxiv/papers/1110/1110.4321.pdf)
- [Dylan Holmes's blogpost](http://logical.ai/chemistry/html/chem-nullspace.html)
"""
function balance(mat::Matrix{Int})
    mat::Matrix{Int} = transpose(mat) |>
        x -> [x I] |>
        x -> matrix(ZZ, x) |>
        hnf |>
        Matrix
    return mat
end

"""
Balances the coefficients of a chemical equation.
The minimal integer solution is always displayed.

If the equation cannot be balanced, an error is thrown.

!!! info
    The original equation is not modified.

# Examples
```jldoctest
julia> balance(ce"Fe + Cl2 = FeCl3")
ce"2 Fe + 3 Cl2 = 2 FeCl3"

julia> balance(ce"Cr2O7{-2} + H{+} + {-} = Cr{+3} + H2O")
ce"Cr2O7{-2} + 14 H{+} + 6 e = 2 Cr{+3} + 7 H2O"
```
"""
function balance(equation::ChemEquation)
    eq = deepcopy(equation)
    mat = equationmatrix(eq)
    dim = size(mat)[1]
    mat = balance(mat)

    if iszero(mat[end, 1:dim])
        if iszero(mat[end-1, 1:dim])
            error("Chemical equation $equation can be balanced in infinitely many ways")
        else
            for (i, k) ∈ enumerate(mat[end, dim+1:end])
                eq.tuples[i] = (eq.tuples[i][1], k)
            end
        end
    else
        error("Chemical equation $equation cannot be balanced")
    end

    return eq
end
