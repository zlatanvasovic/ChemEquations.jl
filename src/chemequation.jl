"Type stored in `ChemEquation.tuples`."
const CompoundTuple{T} = Tuple{Compound, T}

fwd_arrows = ['>', '→', '↣', '↦', '⇾', '⟶', '⟼', '⥟', '⥟', '⇀', '⇁', '⇒', '⟾']
bwd_arrows = ['<', '←', '↢', '↤', '⇽', '⟵', '⟻', '⥚', '⥞', '↼', '↽', '⇐', '⟽']
double_arrows = ['↔', '⟷', '⇄', '⇆', '⇌', '⇋', '⇔', '⟺']
pure_rate_arrows = ['⇐', '⟽', '⇒', '⟾', '⇔', '⟺']
equal_signs = ['=', '≔', '⩴', '≕']
"""
Characters used to split a chemical equation into two sides.
Source: <https://github.com/SciML/Catalyst.jl/blob/master/src/reaction_network.jl#L56>
"""
const EQUALCHARS = vcat(fwd_arrows, bwd_arrows, double_arrows, pure_rate_arrows, equal_signs)

"Regex to split a chemical equation into compounds."
const PLUSREGEX = r"(?<!{)\+(?!})" # '+' not after '{' and not before '}'

"Stores chemical equation's compounds and their coefficients in a structured way."
struct ChemEquation{T<:Real}
    tuples::Vector{CompoundTuple{T}}
end

"""
Constructs a chemical equation from the given string.
If no `{Type}` is provided, it defaults to `Int`.

Parsing is insensitive to whitespace.
Any character in [`EQUALCHARS`](@ref) separates the equation into two sides,
while `+` separates the equation into compounds.

# Examples
```jldoctest
julia> ChemEquation("N2+O2⇌2NO")
N2 + O2 = 2 NO

julia> ChemEquation("CH3COOH + Na → H2 + CH3COONa")
C2H4O2 + Na = H2 + C2H3O2Na

julia> ChemEquation("⏣H + Cl2 = ⏣Cl + HCl")
⏣H + Cl2 = ⏣Cl + HCl

julia> ChemEquation{Rational}("1//2 H2 → H")
1//2 H2 = H

julia> ChemEquation{Float64}("0.5 H2 + 0.5 Cl2 = HCl")
0.5 H2 + 0.5 Cl2 = HCl
```
"""
ChemEquation{T}(str::AbstractString) where T<:Real = ChemEquation(_compoundtuples(str, T))

ChemEquation(str::AbstractString) = ChemEquation{Int}(str)

"Extracts compound tuples from equation's string."
function _compoundtuples(str::AbstractString, T::Type)
    strs = replace(str, [' ', '_'] => "") |>
        x -> split(x, EQUALCHARS) |>
        x -> split.(x, PLUSREGEX)
    splitindex = length(strs[1])
    strs = [strs[1]; strs[2]]
    tuples = Vector{CompoundTuple{T}}(undef, length(strs))

    for (i, compound) ∈ enumerate(strs)
        k = 1
        if isdigit(compound[1]) # begins with a digit
            charindex = findfirst(r"\(?(\p{L}|\p{S})", compound)[1]
            k, compound = compound[1:charindex-1], compound[charindex:end]
            k = Meta.parse(k) |> eval
        end
        if i > splitindex
            k *= -1
        end
        tuples[i] = (Compound(compound), k)
    end

    return tuples
end

"""
Constructs a chemical equation with `ce"str"` syntax, instead of `ChemEquation(str)`.

# Examples
```jldoctest
julia> ce"H2 + O2 → H2O"
H2 + O2 = H2O
```
"""
macro ce_str(str) ChemEquation(str) end

"""
Checks whether two equations are chemically equal.

# Examples
```jldoctest
julia> ce"H2 + O2 = H2O" == ce"O2 + H2 → H2O"
true
```
"""
function Base.:(==)(equation_1::ChemEquation, equation_2::ChemEquation)
    f = x -> sort(x[1].tuples)
    return sort(equation_1.tuples, by = f) == sort(equation_2.tuples, by = f)
end

"""
Creates a string to represent the chemical equation.

All compounds are displayed with [`Base.string(::Compound)`](@ref),
in the order in which they were originally given,
with coefficients equal to 1 not displayed.
`'='` and `'+'` are used as separators, with spaces inserted for easier reading.

# Examples
```jldoctest
julia> string(ce"Cr2O7{2-} + H{+} + {-} = Cr{3+} + H2O")
"Cr2O7{-2} + H{+} + e = Cr{+3} + H2O"
```
"""
function Base.string(equation::ChemEquation)
    left = String[]
    right = String[]
    for (compound, k) ∈ equation.tuples
        str = ""
        if k ∉ (-1, 1)
            str *= string(abs(k)) * " "
        end
        str *= string(compound)
        if k > 0
            push!(left, str)
        else
            push!(right, str)
        end
    end
    left = join(left, " + ")
    right = join(right, " + ")
    return join([left, right], " = ")
end

"Displays the chemical equation using [`Base.string(::Compound)`](@ref)."
function Base.show(io::IO, equation::ChemEquation)
    print(io, string(equation))
end

"Returns chemical equation's compounds in a list."
function compounds(equation::ChemEquation)
    return first.(equation.tuples) |> unique
end

"""
Returns chemical equation's unique elements.

# Examples
```jldoctest
julia> elements(ce"2 H2 + O2 → 2 H2O")
2-element Array{String,1}:
 "H"
 "O"
```
"""
function elements(equation::ChemEquation)
    vect::Vector{String} = vcat(elements.(compounds(equation))...) |> unique
    return vect
end

"True if chemical equation has at least one compound with nonzero charge."
function hascharge(equation::ChemEquation)
    return !isnothing(findfirst(hascharge, compounds(equation)))
end
