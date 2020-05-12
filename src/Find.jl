"""
This module provides `findvolume` methods to find the volume at a given
pressure, energy, or bulk modulus with(out) units.
"""
module Find

using Roots:
    find_zero,
    Halley,
    Schroder,
    Bisection,
    BisectionExact,
    FalsePosition,
    A42,
    AlefeldPotraShi,
    Esser,
    King,
    KumarSinghAkanksha,
    Order0,
    Order16,
    Order1B,
    Order2,
    Order2B,
    Order5,
    Order8,
    Secant,
    Steffensen,
    Thukral16,
    Thukral8,
    Brent,
    Newton
using Unitful: AbstractQuantity, ustrip

using ..Collections: PhysicalProperty

export findvolume

"""
    findvolume(eos(prop), y, x0, method)
    findvolume(eos(prop), y, x0::Union{AbstractVector,Tuple})

Find a volume which leads to the given pressure, energy, or bulk modulus based on an `eos`.

# Arguments
- `eos::EquationOfState`: an equation of state. If it has units, `y` and `x0` must also have.
- `prop::PhysicalProperty`: a `PhysicalProperty` instance.
- `y`: a pressure, energy, or bulk modulus.
- `x0`: can be either a range of volumes (`Vector`, `Tuple`, etc.) or just a single volume.
    Units can be provided if necessary.
- `method::Roots.AbstractUnivariateZeroMethod`: a method used to find the root of an equation.
    If it is omitted, the algorithm will traverse all possible methods of
    [Roots.jl](https://github.com/JuliaMath/Roots.jl). And the `x0` parameter must be
    an array or a tuple, of which only the maximum and minimum values will be used in the
    root-finding process.
"""
function findvolume(f, y, x0, method)
    v0 = find_zero(v -> f(v) - y, x0, method)
    if v0 < zero(v0)
        error("the volume found is negative!")
    else
        return v0
    end
end # function findvolume
function findvolume(f, y, x0; silent = false)
    for T in [Bisection, BisectionExact, FalsePosition, A42, AlefeldPotraShi]
        silent || @info("using method `$T`...")
        try
            # `maximum` and `minimum` also works with `AbstractQuantity`s.
            return findvolume(f, y, (minimum(x0), maximum(x0)), T())
        catch e
            silent || @info("method `$T` failed because of $e.")
            continue
        end
    end
    for T in [
        Brent,
        Halley,
        Schroder,
        Newton,
        Esser,
        King,
        KumarSinghAkanksha,
        Order0,
        Order16,
        Order1B,
        Order2,
        Order2B,
        Order5,
        Order8,
        Secant,
        Steffensen,
        Thukral16,
        Thukral8,
    ]
        silent || @info("using method `$T`...")
        try
            return findvolume(f, y, (minimum(x0) + maximum(x0)) / 2, T())
        catch e
            silent || @info("method `$T` failed because of $e.")
            continue
        end
    end
end # function findvolume

end
