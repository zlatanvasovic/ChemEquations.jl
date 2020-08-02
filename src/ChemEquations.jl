"""
    ChemEquations

Write and balance chemical equations elegantly and efficiently.
"""
module ChemEquations

using LinearAlgebra: I
using AbstractAlgebra: matrix, ZZ, hnf
using DocStringExtensions
@template (CONSTANTS, MACROS) =
    """
        $FUNCTIONNAME
    $DOCSTRING
    """
@template TYPES =
    """
    $TYPEDEF
    $TYPEDFIELDS
    $DOCSTRING
    """
@template (FUNCTIONS, METHODS) =
    """
    $TYPEDSIGNATURES
    $DOCSTRING
    """

export Compound, ChemEquation,
    @ce_str, @cc_str, ==, string, show,
    compounds, elements, hascharge,
    equationmatrix, balance

include("compound.jl")
include("chemequation.jl")
include("balance.jl")

end # module
