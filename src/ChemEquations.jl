"""
    ChemEquations

Write and balance chemical equations elegantly and efficiently.
"""
module ChemEquations

using LinearAlgebraX: I, nullspacex, IntegerX
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
    equationmatrix, balancematrix, balance

include("compound.jl")
include("chemequation.jl")
include("balance.jl")

end # module
