# Examples

## Textbook exercises

Equations can be written conveniently, with many different forms supported.
They are written as strings with `ce` prefix (**c**hemical **e**quation),
similar to `r` prefix for regex in Julia.

```julia-repl
julia> equation = ce"Fe + Cl2 = FeCl3"
ce"Fe + Cl2 = FeCl3"
julia> balance(equation)
ce"2 Fe + 3 Cl2 = 2 FeCl3"
```

Parsing the input is insensitive to whitespace, so you don't have to be pedantic if you don't want to.

```julia-repl
julia> balance(ce"KMnO4+ HCl = KCl+MnCl2 +H2O + Cl2")
ce"2 KMnO4 + 16 HCl = 2 KCl + 2 MnCl2 + 8 H2O + 5 Cl2"
```

Parentheses (`()`), compounds written with `*` and electrical charges are all supported.
Electron will be recognized if you write `e`, `{-}`, `{-1}` or `{1-}`.
Charge is also supposed to be in any of those forms.

```julia-repl
julia> balance(ce"K4Fe(CN)6 + H2SO4 + H2O = K2SO4 + FeSO4 + (NH4)2SO4 + CO")
ce"K4FeC6N6 + 6 H2SO4 + 6 H2O = 2 K2SO4 + FeSO4 + 3 N2H8SO4 + 6 CO"

julia> balance(ce"Cr2O7{-2} + H{+} + {-} = Cr{+3} + H2O")
ce"Cr2O7{-2} + 14 H{+} + 6 e = 2 Cr{+3} + 7 H2O"

julia> balance(ce"CuSO4*5H2O = CuSO4 + H2O")
CuSO9H10 = CuSO4 + 5 H2O
```

Even the hardest exercises are in the reach:
```julia-repl
julia> balance(ce"K4Fe(CN)6 + KMnO4 + H2SO4 = KHSO4 + Fe2(SO4)3 + MnSO4 + HNO3 + CO2 + H2O")
ce"10 K4FeC6N6 + 122 KMnO4 + 299 H2SO4 = 162 KHSO4 + 5 Fe2S3O12 + 122 MnSO4 + 60 HNO3 + 60 CO2 + 188 H2O"
```

Writing equations with a different equal sign is also possible
(see [`ChemEquation(::AbstractString)`](@ref) for reference):
```julia-repl
julia> ce"N2+O2⇌2NO"
ce"N2 + O2 = 2 NO"

julia> ce"
ce"H2 + O2 = H2O"
```

Are two chemical equations identical? Let's find out:
```julia-repl
julia> ce"CH3CH2OH + O2 = CO2 + HOH" == ce"C2H5OH + O2 → H2O + CO2"
true
```

The syntax flexibility comes at no additional costs.
Scroll down to [Using unicode characters](#Using-unicode-characters) section for more interesting examples.

## Compounds

The package also supports writing compounds, independent of an equation.
The syntax is similar, just with `cc` prefix (**c**hemical **c**ompound) instead of `ce`.

```julia-repl
julia> cc"CuSO4*5H2O"
cc"CuSO9H10"

julia> cc"H3O{+1}"
cc"H3O{+}
```

As you could notice, input string is transformed so that every atom appears only once.
You can use this to compare two compounds written in different forms:
```julia-repl
julia> cc"CH3CH2CH2CH2CH2OH" == cc"C5H12O"
true
```

## Using unicode characters

All unicode characters that are letters (such as α and β) or symbols (such as × and ÷) are supported in the input.

Compounds are composed of elements, where an element begins with an uppercase unicode letter and
ends with a lowercase unicode letter or a unicode symbol.

!!! info
    An element can also begin with a symbol if
    the symbol is the first character (e.g. `"⬡H"`).

It's even more interesting to use unicode symbols that resemble chemical symbols.
Examples of those are ⎔ (`\hexagon`), ⬡ (`varhexagon`), ⬢ (`\varhexagonblack`), ⌬ (`\varhexagonlrbonds`) and ⏣ (`\benzenr`).

Unicode input allows writing some equations very nicely:
```julia-repl
julia> ce"⏣H + Cl2 = ⏣Cl + HCl"
ce"⏣H + Cl2 = ⏣Cl + HCl"
```

## Advanced usage

```julia-repl

```
