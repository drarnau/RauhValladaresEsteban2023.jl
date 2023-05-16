## Functions available outside the package
export simulatewages

## Functions
"""
    simulatewages(hours::Matrix, a::Float64, h₁::Float64, p::ModelParameters)

Simulates wages based on hours worked, the ability to accumulate human capital, and the initial level of human capital.

# Arguments
- `hours::Matrix`: Matrix containing hours worked by agents (rows) for each period (columns).
- `a::Float64`: Ability to accumulate human capital.
- `h₁::Float64`: Initial level of human capital.
- `p::ModelParameters`: Instance of `ModelParameters` containing relevant model parameters.
"""
function simulatewages(hours::Matrix, a::Float64, h₁::Float64, p::ModelParameters)
    # Read number of agents (rows) and number of periods (columns)
    (hN, hJ) = size(hours)

    # Intialise matrices for wages and human capital (hk)
    wage = similar(hours)
    hk = similar(hours)
    hk[:,1] .= h₁

    # Iterate over periods
    for j ∈ 1:hJ
        # Iterate over agents
        for g ∈ 1:hN
            # Store wage if hours are not missing
            wage[g,j] = ismissing(hours[g,j]) ? missing : hk[g,j]

            # Compute human capital next period
            if j < hJ
                hk[g,j+1] = ismissing(hours[g,j]) ? hk[g,j] : fh′(hk[g,j], a, hours[g,j], p)
            end
        end
    end
    return wage
end

"""
    simulatewages(v::Vector{MicroData}, p::ModelParameters)

Simulates wages for each level of ability and initial human capital.

# Arguments
- `v::Vector{MicroData}`: Vector of `MicroData` containing amount of hours worked.
- `p::ModelParameters`: Instance of `ModelParameters` containing relevant model parameters.
"""
function simulatewages(v::Vector{MicroData}, p::ModelParameters)
    @unpack grid_a, grid_h₁ = p

    # Assert length of vector of microdata is equal to ability/h₁ levels
    levels = length(v)
    @assert levels == length(grid_a) "MicroData Vector and ability/h₁ vectors have different size"

    # Initialise vector to store simulated data
    simdata = Vector{MicroData}(undef, levels)

    # Iterate over levels
    for l ∈ 1:levels
        simdata[l] = MicroData(
            wage = simulatewages(v[l].hours, grid_a[l], grid_h₁[l], p)
            )
    end

    return simdata
end

"""
    simulateindices(MC::MarkovChain, nagents::Int64, nperiods::Int64; t₀::Int64 = 100)::Matrix{Int64}

Simulates indices for a given number of agents and periods using a Markov chain.

# Arguments
- `MC::MarkovChain`: `MarkovChain` instance.
- `nagents::Int64`: Number of agents.
- `nperiods::Int64`: Number of periods to simulate.
- `t₀::Int64 (optional)`: Amount of periods ignored when returning simulation (default: 100).

# Note
- The final matrix of simulated indices is returned, starting from period `t₀ + 1`.
"""
function simulateindices(
    MC::MarkovChain, nagents::Int64, nperiods::Int64; t₀::Int64 = 100
    )::Matrix{Int64}
    # Set seed
    Random.seed!(0)

    return reduce(
        hcat,
        simulate_indices.(Ref(MC), fill(nagents, t₀ + nperiods))
        )[:, (t₀+1):end]
end

"""
    simulateraw(ia::Int64, iκs::Matrix{Int64}, n::Vector{Matrix{Float64}}, p::ModelParameters)

Simulates hours worked and human capital based on realisations of the staying-at-home shock (`iκs`) and the policy function (`n`) for one level of ability to accumulate human capital.

# Arguments
- `ia::Int64`: Index of the ability to accumulate human capital.
- `iκs::Matrix{Int64}`: Matrix of the indices of realisations of the staying-at-home shock.
- `n::Vector{Matrix{Float64}}`: Policy function for hours worked.
- `p::ModelParameters`: Instance of `ModelParameters` containing model relevant parameter values.
"""
function simulateraw(ia::Int64, iκs::Matrix{Int64}, n::Vector{Matrix{Float64}}, p::ModelParameters)
    @unpack nagents, J, grid_h₁, grids_h, grid_a, gp_κ = p

    # Initialise matrices to store simulated hours and human capital
    hours = fill(NaN, nagents, J)
    hk = similar(hours)
    hk[:,1] .= grid_h₁[ia]

    # Iterate over periods
    for j ∈ 1:J
        # Create interpolation functions for polifcy functions
        fn = Vector{Any}(undef, gp_κ)
        for iκ ∈ 1:gp_κ
            fn[iκ] = (
                j == 1 ?
                (x -> n[j][iκ,1]) :
                (interpolate((grids_h[ia,j], ), n[j][iκ,:], Gridded(Linear())))
                )
        end

        # Iterate over agents
        for g ∈ 1:nagents
            # Compute hours using interpolated policy function
            hours[g,j] = fn[iκs[g,j]](hk[g,j])

            # Compute human capital next period
            if j < J
                hk[g,j+1] = fh′(hk[g,j], grid_a[ia], hours[g,j], p)
            end
        end
    end

    return NamedTuple{(:hours, :hk)}([hours, hk])
end

"""
    raw2micro(p::ModelParameters; hours::Matrix{Float64}, hk::Matrix{Float64}, empsample::Bool = true)

Converts simulation results of hours worked and human capital to MicroData format optionally applying constraints that allow comparison to NLSY data.

# Arguments
- `p::ModelParameters`: Instance of `ModelParameters` containing relevant parameter values.
- `hours::Matrix{Float64}`: Matrix of simulated hours worked.
- `hk::Matrix{Float64}`: Matrix of simulated human capital.
- `empsample::Bool = true`: (Optional) Flag indicating whether to use treshold to allocate employment indicator.
"""
function raw2micro(
    p::ModelParameters; hours::Matrix{Float64}, hk::Matrix{Float64}, empsample::Bool = true
    )
    @unpack lbhours = p

    # Create employment indicator
    e = hours .> lbhours

    if empsample # Store hours and wages for only the employed
        return MicroData(
            wage = [e[i] == true ? v : missing for (i,v) in enumerate(hk)],
            hours = [e[i] == true ? v : missing for (i,v) in enumerate(hours)],
            employed = e
            )
    else
        return MicroData(wage = hk, hours = hours, employed = e)
    end
end

"""
    simulate(ia::Int64, iκs::Matrix{Int64}, n::Vector{Matrix{Float64}}, p::ModelParameters, empsample::Bool = true)

Returns `MicroData` instance after simulating economy based on the realisations of the staying-at-home shock (`iκs`) and the policy function (`n`) for one level of ability to accumulate human capital.

# Arguments
- `ia::Int64`: Index of the ability to accumulate human capital.
- `iκs::Matrix{Int64}`: Matrix of the indices of realisations of the staying-at-home shock.
- `n::Vector{Matrix{Float64}}`: Policy function for hours worked.
- `p::ModelParameters`: Instance of `ModelParameters` containing relevant parameter values.
- `empsample::Bool = true`: Flag indicating whether to use treshold to allocate employment indicator.
"""
function simulate(
    ia::Int64,
    iκs::Matrix{Int64},
    n::Vector{Matrix{Float64}},
    p::ModelParameters,
    empsample::Bool = true
    )
    return raw2micro(p; simulateraw(ia, iκs, n, p)..., empsample = empsample)
end
