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
function equationmatrix(equation::ChemEquation{T}) where T
    vect = elements(equation)
    charged = hascharge(equation)
    if charged && "e" ∉ vect
        push!(vect, "")
    end

    mat = zeros(T, length(vect), length(equation.tuples))
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

"Wrapper function for [`balancematrix`](@ref)."
function _balancematrix(equation)
    -nullspacex(equationmatrix(equation))
end

"""
Balances an equation matrix using the *nullspace method*.
Returns an array in which each column represents a solution.

# References
- [Thorne (2009)](https://arxiv.org/ftp/arxiv/papers/1110/1110.4321.pdf)
"""
balancematrix(equation::ChemEquation) = _balancematrix(equation)

"""
Same as [`balancematrix(::ChemEquation)`](@ref),
but for a chemical equation with integer coefficients.

By default, the solutions of integer matrices are displayed as integers.
If `fractions` is true, they will be displayed as rational fractions instead.
"""
function balancematrix(equation::ChemEquation{T}; fractions=false) where T<:IntegerX
    mat = _balancematrix(equation)
    if !fractions
        mat ./= gcd(mat)
        T.(mat)
    end
    return mat
end

"""
Balances the coefficients of a chemical equation.
If the equation cannot be balanced, an error is thrown.

!!! info
    The original equation is not modified.

# Examples
```jldoctest
julia> balance(ce"Fe + Cl2 = FeCl3")
2 Fe + 3 Cl2 = 2 FeCl3

julia> balance(ChemEquation{Rational}("H2 + Cl2 = HCl"))
1//2 H2 + 1//2 Cl2 = HCl
```
"""
balance(equation::ChemEquation) = _balance(equation)

"""
Balances the coefficients of a chemical equation with integer coefficients.

The minimal integer solution is displayed by default.
If `fractions` is true, they solution will be displayed as rational fractions instead.

# Examples
```jldoctest
julia> balance(ce"Fe + Cl2 = FeCl3", fractions=true)
Fe + 3//2 Cl2 = FeCl3

julia> balance(ce"Cr2O7{-2} + H{+} + {-} = Cr{+3} + H2O")
Cr2O7{-2} + 14 H{+} + 6 e = 2 Cr{+3} + 7 H2O
```
"""
balance(equation::ChemEquation{<:IntegerX}; fractions=false) = _balance(equation, fractions)

"Wrapper function for [`balance`](@ref)."
function _balance(equation::ChemEquation, fractions=false)
    if fractions
        eq = ChemEquation{Rational}(equation.tuples)
        mat = balancematrix(equation, fractions=true)
    else
        eq = ChemEquation(equation.tuples)
        mat = balancematrix(equation)
    end
    num = size(mat)[2]
    if num == 1
        for (i, k) ∈ enumerate(mat)
            eq.tuples[i] = (eq.tuples[i][1], k)
        end
    elseif num > 1
        error("Chemical equation $equation can be balanced in infinitely many ways")
    else
        error("Chemical equation $equation cannot be balanced")
    end
    return eq
end