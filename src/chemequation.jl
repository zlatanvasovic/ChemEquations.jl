"Type stored in `ChemEquation.tuples`."
const CompoundTuple = Tuple{Compound, Int}

"Characters used to split a chemical equation into two sides."
const EQUALCHARS = ['=', '→', '↔', '⇄', '⇆', '⇌', '⇋']

"Regex to split a chemical equation into compounds."
const PLUSREGEX = r"(?<!{)\+(?!})"

"""
Stores chemical equation's compounds and their coefficients in a structured way.
"""
struct ChemEquation
    tuples::Vector{CompoundTuple}
end

"""
Constructs a chemical equation from the given string.

Parsing is insensitive to whitespace.
Any character in `$EQUALCHARS` separates the equation into two sides,
while `+` separates the equation into compounds.

# Examples
```jldoctest
julia> ChemEquation("N2+O2⇌2NO")
ce"N2 + O2 = 2 NO"

julia> ChemEquation("CH3COOH + Na → H2 + CH3COONa")
ce"C2H4O2 + Na = H2 + C2H3O2Na"

julia> ChemEquation("⏣H + Cl2 = ⏣Cl + HCl")
ce"⏣H + Cl2 = ⏣Cl + HCl"
```
"""
ChemEquation(str::AbstractString) = ChemEquation(compoundtuples(str))

"Extracts compound tuples from equation's string."
function compoundtuples(str::AbstractString)
    tuples = replace(str, ' ' => "") |>
        x -> split(x, EQUALCHARS) |>
        x -> split.(x, PLUSREGEX) # '+' not after '{' and not before '}'
    splitindex = length(tuples[1])
    tuples::Vector{Any} = [tuples[1]; tuples[2]]

    for (i, compound) ∈ enumerate(tuples)
        k = 1
        if isdigit(compound[1])
            k, compound = match(r"(^\d+)(.+)", compound).captures
            k = parse(Int, k)
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
ce"H2 + O2 = H2O"
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
'=' and '+' are used as separators, with spaces inserted for easier reading.

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
        str = string(compound)
        if k > 0
            if k ≠ 1
                str = "$k " * str
            end
            push!(left, str)
        elseif k < 0
            if k ≠ -1
                str = "$(-k) " * str
            end
            push!(right, str)
        end
    end
    left = join(left, " + ")
    right = join(right, " + ")
    return join([left, right], " = ")
end

"Displays the chemical equation using [`Base.string(::Compound)`](@ref)."
function Base.show(io::IO, equation::ChemEquation)
    print(io, "ce", '"', string(equation), '"')
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
    ionic = findfirst(hascharge, compounds(equation))
    return !isnothing(ionic)
end
