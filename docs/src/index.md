# ChemEquations

This is a Julia package for writing and balancing chemical equations.
Its goal is to be both elegant and efficient.

Writing a chemical equation like this:
```math
CH_4 + O_2 \to CO_2 + H_2 O
```

should be as simple as this:
```julia-repl
julia> using ChemEquations

julia> equation = ce"CH4 + O2 = CO2 + H2O"
ce"CH4 + O2 = CO2 + H2O"
```

and balancing it should be even easier:
```julia-repl
julia> balance(equation)
ce"CH4 + 2 O2 = CO2 + 2 H2O"
```

## Installation

You can install the package by pressing `]` in Julia REPL and typing:

```julia
add ChemEquations
```