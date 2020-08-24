using ChemEquations
using Documenter

DocMeta.setdocmeta!(ChemEquations, :DocTestSetup, :(using ChemEquations))

makedocs(;
    modules=[ChemEquations],
    authors="zdroid <zlatanvasovic@gmail.com> and contributors",
    repo="https://github.com/zdroid/ChemEquations.jl/blob/{commit}{path}#L{line}",
    sitename="ChemEquations.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://zdroid.github.io/ChemEquations.jl",
        assets=String[],
        analytics="UA-33643623-2",
    ),
    pages=[
        "Home" => "index.md",
        "Examples" => "examples.md",
        "Library" => [
            "lib/public.md",
            "lib/internals.md",
        ]
    ]
)

deploydocs(;
    repo="github.com/zdroid/ChemEquations.jl",
)
