# Examples

```@meta
DocTestSetup = quote
    using ChemEquations
end
```

## Textbook exercises

Equations can be written conveniently, with many different forms supported.
They are written as strings with `ce` prefix (**c**hemical **e**quation),
similar to `r` prefix for regex in Julia.

```jldoctest
julia> equation = ce"Fe + Cl2 = FeCl3"
Fe + Cl2 = FeCl3

julia> balance(equation)
2 Fe + 3 Cl2 = 2 FeCl3
```

Parsing the input is insensitive to whitespace and to state symbols (`(s)`, `(l)`, `(g)`, `(aq)`),
so you don't have to be pedantic if you don't want to.

```jldoctest
julia> balance(ce"KMnO4+ HCl = KCl+MnCl2 +H2O + Cl2")
2 KMnO4 + 16 HCl = 2 KCl + 2 MnCl2 + 8 H2O + 5 Cl2

julia> balance(ce"Zn(s) + O2(g) = ZnO(s)")
2 Zn + O2 = 2 ZnO
```

Parentheses (`()`), compounds written with `*` and electrical charges are all supported.
Electron will be recognized if you write `e`, `{-}`, `{-1}` or `{1-}`.
Charge is also supposed to be in any of those forms.

```jldoctest
julia> balance(ce"K4Fe(CN)6 + H2SO4 + H2O = K2SO4 + FeSO4 + (NH4)2SO4 + CO")
K4FeC6N6 + 6 H2SO4 + 6 H2O = 2 K2SO4 + FeSO4 + 3 N2H8SO4 + 6 CO

julia> balance(ce"Cr2O7{-2} + H{+} + {-} = Cr{+3} + H2O")
Cr2O7{-2} + 14 H{+} + 6 e = 2 Cr{+3} + 7 H2O

julia> balance(ce"CuSO4*5H2O = CuSO4 + H2O")
CuSO9H10 = CuSO4 + 5 H2O
```

Even the hardest exercises are in the reach:
```jldoctest
julia> balance(ce"K4Fe(CN)6 + KMnO4 + H2SO4 = KHSO4 + Fe2(SO4)3 + MnSO4 + HNO3 + CO2 + H2O")
10 K4FeC6N6 + 122 KMnO4 + 299 H2SO4 = 162 KHSO4 + 5 Fe2S3O12 + 122 MnSO4 + 60 HNO3 + 60 CO2 + 188 H2O
```

Writing equations with a different equal sign is also possible
(see [`ChemEquation(::AbstractString)`](@ref) for reference):
```jldoctest
julia> ce"N2+O2⇌2NO"
N2 + O2 = 2 NO

julia> ce"H2 + O2 → H2O"
H2 + O2 = H2O
```

Are two chemical equations identical? Let's find out:
```jldoctest
julia> ce"CH3CH2OH + O2 = CO2 + HOH" == ce"C2H5OH + O2 → H2O + CO2"
true
```

The syntax flexibility comes at no additional costs.
Scroll down to [Using unicode characters](#Using-unicode-characters) section for more interesting examples.

## Compounds

The package also supports writing compounds, independent of an equation.
The syntax is similar, just with `cc` prefix (**c**hemical **c**ompound) instead of `ce`.

```jldoctest
julia> cc"CuSO4*5H2O"
CuSO9H10

julia> cc"H3O{+1}"
H3O{+}
```

As you could notice, input string is transformed so that every atom appears only once.
You can use this to compare two compounds written in different forms:
```jldoctest
julia> cc"CH3CH2CH2CH2CH2OH" == cc"C5H12O"
true
```

## Using unicode characters

All unicode characters that are letters (such as α and β) or symbols (such as × and ÷) are supported in the input.
That allows some exotic examples:
```jldoctest
julia> ce"Σ{+1} + Θ{-1} = Θ2 + Σ2"
Σ{+} + Θ{-} = Θ2 + Σ2
```

This works because compounds are parsed by elements, where an element begins with an uppercase unicode letter and
ends with a lowercase unicode letter or a unicode symbol.

!!! info
    An element can also begin with a symbol if
    the symbol is the first character (e.g. `"⬡H"`).

It's even more interesting to use unicode symbols that resemble chemical symbols.
Examples of those are ⎔ (`\hexagon`), ⬡ (`varhexagon`), ⬢ (`\varhexagonblack`), ⌬ (`\varhexagonlrbonds`) and ⏣ (`\benzenr`).

Unicode input allows writing some equations very nicely:
```jldoctest
julia> ce"⏣H + Cl2 = ⏣Cl + HCl"
⏣H + Cl2 = ⏣Cl + HCl

julia> ce"C + α = O + γ" # a reaction from triple-α process
C + α = O + γ
```

## Non-integer coefficients

Sometimes coefficients in a chemical equation are written as fractions or decimals.

To initialize such equation, you need to specify the appropriate Julia type for the coefficients.
`Rational` or `Rational{Int}` is appropriate for exact fractions, while `Float64` is appropriate for decimals.
```jldoctest
julia> ChemEquation{Rational}("1//2 H2 + 1//2 Cl2 → HCl")
1//2 H2 + 1//2 Cl2 = HCl

julia> ChemEquation{Float64}("0.5 H2 + 0.5 Cl2 = HCl")
0.5 H2 + 0.5 Cl2 = HCl
```
Previous two examples are equivalent (test it with `==`!), thanks to the way that numbers are stored in Julia.

You can also initialize the equation normally:
```jldoctest label_1
julia> eq = ce"H2 + Cl2 → HCl"
H2 + Cl2 = HCl
```

and then choose to balance it with rational fractions as coefficients:
```jldoctest label_1
julia> balance(eq, fractions=true)
1//2 H2 + 1//2 Cl2 = HCl
```
