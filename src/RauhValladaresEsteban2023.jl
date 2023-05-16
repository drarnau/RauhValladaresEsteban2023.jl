module RauhValladaresEsteban2023

## Functions available outside the package
export solvemodel, solveconstantls

## Packages used
using CSV
using DataFrames
using Interpolations
using Missings
using Plots
using QuantEcon
using Random
using StatsBase
using UnPack

## Add files to package
include("modelparameters.jl")
include("data.jl")
include("auxiliaryfunctions.jl")
include("policyfunction.jl")
include("montecarlo.jl")
include("plotting.jl")
include("latex.jl")

"""
    solvemodel(p::ModelParameters, empsample::Bool = true)

Solves the model based on the parameters provided.

# Arguments
- `p::ModelParameters`: Instance of `ModelParameters` containing the model's parameter values.
- `empsample::Bool = true`: (Optional) Flag indicating whether to use treshold to allocate employment indicator.

# Note
- This function returns a vector of simulated data for each level of ability/h₁. Each element in the vector represents the simulated data for one level and is of type `MicroData`.
"""
function solvemodel(p::ModelParameters, empsample::Bool = true)
    @unpack grid_a, MCκ, nagents, J = p

    # Read number of ability/h₁ levels
    levels = 1:length(grid_a)

    # Compute vector of labour supply policy function (n) for each level
    ns = policyfunction.(levels, Ref(p))

    # Simulate shocks value of staying at home (same for all levels)
    iκs = simulateindices(MCκ, nagents, J)

    # Return MonteCarlo simulation for all levels
    return simulate.(levels, Ref(iκs), ns, Ref(p), Ref(empsample))
end

"""
    solveconstantls(pb::ModelParameters, pw::ModelParameters)

Solves the model using the labor supply decisions of the economy defined by `pb` while using the human capital parameters of `pw`.

# Arguments
- `pb::ModelParameters`: Instance of `ModelParameters` to compute labor supply decisions.
- `pw::ModelParameters`: Instance of `ModelParameters` to use human capital parameters.

# Note
- This function returns a vector of simulated data for each level of ability/h₁. Each element in the vector represents the simulated data for one level and is of type `MicroData`.
"""
function solveconstantls(pb::ModelParameters, pw::ModelParameters)
    # Get uncensored labor supply for all levels
    b = solvemodel(pb, false)

    # Initialise vector of MicroData to return
    lb = length(b)
    z = Vector{MicroData}(undef, lb)

    for l ∈ 1:lb
        z[l] = raw2micro(pw,
            hours = disallowmissing(b[l].hours),
            hk = sum(pw.popshare.*
                disallowmissing.(simulatewages.(Ref(b[l].hours), pw.grid_a, pw.grid_h₁, Ref(pw))))
            )
    end

    return z
end


end
