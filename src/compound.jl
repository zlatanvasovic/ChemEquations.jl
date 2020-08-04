"Type stored in `Compound.tuples`."
const ElementTuple{T} = Tuple{String, T}

"Regex to match `{±n}` charge."
const CHARGEREGEX_1 = r"{((\+|-).*)}"

"Regex to match `{n±}` charge."
const CHARGEREGEX_2 = r"{(.*)(\+|-)}"

"""
Stores chemical compound's elements and charge in a structured way.

!!! info
    Electron is stored as `"e"`.
"""
struct Compound{T<:Number}
    tuples::Vector{ElementTuple{T}}
    charge::T
end
Compound(tuples::Vector{ElementTuple{T}}, charge::T) where T = Compound{T}(tuples, charge)

"""
Constructs a compound from `str`.

An element begins with an uppercase unicode letter and
ends with a lowercase unicode letter or a unicode symbol.

!!! info
    An element can also begin with a symbol if
    the symbol is the first character (e.g. `"⬡H"`).

Parsing is insensitive to whitespace and underscores (`_`).
Special parsing is implemented for:
- parens (e.g. `"(CH3COO)2Mg"`)
- compounds with `"*"` (e.g. `"CuSO4 * 5H2O"`)
- electrons (`"e"`)
Charge is in the form `"{±n}"` or `"{n±}"`.
It is automatically deduced for electron (`"e"`).

# Examples
```jldoctest
julia> Compound("H2O")
cc"H2O"

julia> Compound("H3O{+}")
cc"H3O{+}"

julia> Compound("(CH3COO)2Mg")
cc"C4H6O4Mg"

julia> Compound("CuSO4 * 5H2O")
cc"CuSO9H10"

julia> Compound("⬡Cl")
cc"⬡Cl"
```
"""
Compound(str::AbstractString) = Compound(elementtuples(str), charge(str))

"Extracts element tuples from compound's string."
function elementtuples(str::AbstractString)
    str = replace(str, [' ', '_'] => "") |>
        x -> replace(x, CHARGEREGEX_1 => "") |>
        x -> replace(x, CHARGEREGEX_2 => "")
    if str ∈ ("", "e")
        return [("e", 1)]
    end

    tuples = ElementTuple{Int}[]

    # Add 1 to elements and parens without a coefficient
    str = replace(str,  r"(?<x>\p{L}|\p{S}|\))(?=(\p{Lu}|\(|\)|\*|$))" => s"\g<x>1")

    # Expand parens
    for substr ∈ eachmatch(r"\(((\p{L}|\d)+)\)(\d+)", str)
        capture = replace(
            substr.captures[1],
            isdigit => x -> string(parse(Int, substr.captures[3]) * parse(Int, x))
        )
        str = replace(str, substr.match => capture)
    end

    # Expand compounds with '*', e.g. CuSO4*5H2O
    str = split(str, '*')
    for (i, substr) ∈ enumerate(str)
        if isdigit(substr[1])
            k, substr = match(r"(^\d+)(.+)", substr).captures
            k = parse(Int, k)
            substr = replace(substr, isdigit => x -> string(k * parse(Int, x)))
            str[i] = substr
        end
    end
    str = join(str)

    str = split(str, r"(?=\p{Lu})")
    for element ∈ str
        element, k = split(element, r"(?=\d)(?<!\d)")
        index = findfirst(x -> x[1] == element, tuples)

        if isnothing(index)
            push!(tuples, (element, parse(Int, k)))
        else
            tuples[index] = (element, tuples[index][2] + parse(Int, k))
        end
    end

    return tuples
end

"Extracts charge from compound's string."
function charge(str::AbstractString)
    if str == "e"
        return -1
    end

    match_1 = match(CHARGEREGEX_1, str)
    match_2 = match(CHARGEREGEX_2, str)
    if isnothing(match_1) && isnothing(match_2)
        charge = 0
    else
        if isnothing(match_1)
            charge = match_2.captures[2] * match_2.captures[1]
        else
            charge = match_1.captures[1]
        end
        if charge ∈ ("-", "+")
            charge *= "1"
        end
        charge = parse(Int, charge)
    end
    return charge
end

"""
Constructs a compound with `cc"str"` syntax, instead of `Compound(str)`.

# Examples
```jldoctest
julia> cc"H3O{+1}"
cc"H3O{+}"
```
"""
macro cc_str(str) Compound(str) end

"""
Checks whether two compounds are chemically equal.

# Examples
```jldoctest
julia> cc"MgOHOH" == cc"Mg(OH)2"
true
```
"""
function Base.:(==)(compound_1::Compound, compound_2::Compound)
    return sort(compound_1.tuples) == sort(compound_2.tuples) &&
        compound_1.charge == compound_2.charge
end

"""
Creates a string to represent the compound.

All elements are displayed only once (e.g. `"H2O"` and not `"HOH"`),
in the order in which they were originally given (e.g. `"MgO2H2"` from `cc"Mg(OH)2"`),
with coefficients equal to 1 not displayed (e.g. `"O"` and not `"O1"`).

# Examples
```jldoctest
julia> string(cc"CuSO4 * 5 H2O")
"CuSO9H10"
```
"""
function Base.string(compound::Compound)
    if compound == cc"e"
        return "e"
    end

    str = ""
    for (element, k) ∈ compound.tuples
        str *= element
        if k > 1
            str *= string(k)
        end
    end
    if hascharge(compound)
        str *= "{"
        if compound.charge > 0
            str *= "+"
        end
        if compound.charge == -1
            str *= "-"
        elseif compound.charge ≠ 1
            str *= string(compound.charge)
        end
        str *= "}"
    end
    return str
end

"Displays the compound using [`Base.string(::Compound)`](@ref)."
function Base.show(io::IO, compound::Compound)
    print(io, "cc", '"', string(compound), '"')
end

"""
Returns compound's elements as strings.

# Examples
```jldoctest
julia> elements(cc"CH3COOH")
3-element Array{String,1}:
 "C"
 "H"
 "O"
```
"""
function elements(compound::Compound)
    return first.(compound.tuples)
end

"True if the compound's charge is nonzero."
function hascharge(compound::Compound)
    return compound.charge ≠ 0
end
