## Functions available outside the package
export generateparameters, modifyparameters

## Structures
"""
    ModelParameters

Composite type that contains all the parameters that describe a model economy.

# Fields
## Prices
- `r::Float64`: Interest rate.
- `ω::Float64`: Wage rate.

## Human capital function parameters
- `ϕ::Float64`: Curvature with respect to hours worked.
- `δ::Float64`: Depreciation.

## Preferences
- `β::Float64`: Discount rate.
- `ψ::Float64`: Weight of leisure in utility function.
- `γ::Float64`: Curvature of leisure in utility function.
- `κ₀::Float64`: Intercept value staying at home.
- `κ₁::Float64`: Slope value staying at home.
- `κ₂::Float64`: Curvature value staying at home.
- `η::Float64`: Curvature of human capital in value staying at home.
- `ρ_κ::Float64`: Persistance value staying at home.
- `σ_κ::Float64`: Standard deviation value staying at home.

## Model size
- `gp_h::Int64`: Grid points human capital policy funtion.
- `gp_κ::Int64`. Grid points value staying at home.
- `J::Int64`: Number of periods.
- `nagents::Int64`: Number of agents in Monte Carlo per ability level.
- `nlevels::Int64`: umber of ability levels.

## Grids & Markov Chains
- `grid_a::Vector{Float64}`: Grid ability.
- `grid_h₁::Vector{Float64}`: Grid initial human capital.
- `grids_h::Array{Vector{Float64}, 2}`: Array of grids of human capital.
- `grid_κ::Vector{Float64}`: Grid stochastic value staying at home.
- `MCκ::MarkovChain`: Markov Chain utility staying at home.
- `P_κ::Array{Float64,2}`: Transition probabilities utility staying at home.

## Conversion/comparison to real data
- `popshare::Vector{Float64}`: Population shares; weight of each AFQT decile.
- `lbhours::Float64`: Lower bound hours worked for being employed.
- `initialage::Int64`: Real age at model/data entry.
- `agerange::UnitRange{Int64}`: Range of ages in model/data.
"""
struct ModelParameters
    # Prices
    r::Float64                          # Interest rate
    ω::Float64                          # Wage rate

    # Human capital function parameters
    ϕ::Float64                          # Curvature wrt hours worked
    δ::Float64                          # Depreciation

    # Preferences
    β::Float64                          # Discount rate
    ψ::Float64                          # Weight of leisure in utility
    γ::Float64                          # Curvature of leisure
    κ₀::Float64                         # Intercept value staying at home
    κ₁::Float64                         # Slope value staying at home
    κ₂::Float64                         # Curvature value staying at home
    η::Float64                          # Curvature of human capital in value staying at home
    ρ_κ::Float64                        # Persistance value staying at home
    σ_κ::Float64                        # Standard deviation value staying at home

    # Model size
    gp_h::Int64                         # Grid points human capital policy funtion
    gp_κ::Int64                         # Grid points value staying at home
    J::Int64                            # Number of periods
    nagents::Int64                      # Number of agents in Monte Carlo per ability level
    nlevels::Int64                      # Number of ability levels

    # Grids & Markov Chains
    grid_a::Vector{Float64}             # Grid ability
    grid_h₁::Vector{Float64}            # Grid initial human capital
    grids_h::Array{Vector{Float64}, 2}  # Array of grids of human capital
    grid_κ::Vector{Float64}            # Grid stochastic value staying at home
    MCκ::MarkovChain                    # Markov Chain utility staying at home
    P_κ::Array{Float64,2}               # Transition probabilities utility staying at home

    # Conversion/comparison to real data
    popshare::Vector{Float64}           # Population shares
    lbhours::Float64                    # Lower bound hours worked for being employed
    initialage::Int64                    # Real age at model/data entry
    agerange::UnitRange{Int64}          # Range of ages in model/data

    function ModelParameters(;
        r, ω, ϕ, δ, ψ, γ, κ₀, κ₁, κ₂, η, lbhours, initialage,
        grid_a, grid_h₁, popshare,
        ρ_κ::Float64 = 0.,
        σ_κ::Float64 = 1.,
        gp_h::Int64 = 201,
        gp_κ::Int64 = 101,
        J::Int64 = 32,
        nagents::Int64 = 10000
        )

        # Read number of ability levels
        nlevels = length(grid_a)

        # Assert grids have proper length
        @assert length(grid_h₁) == nlevels "grid_h₁ has wrong length"
        @assert length(popshare) == nlevels "popshare has wrong length"

        # Discount rate
        β = 1 / (1+r)

        # Array of grids for human capital
        grids_h = Array{Vector{Float64}, 2}(undef, nlevels, J+1)

        # Fill grids of human capital
        for ia ∈ 1:nlevels
            # Compute min/max human capital in all periods
            minh = Vector{Float64}(undef, J+1)
            maxh = similar(minh)
            minh[1] = grid_h₁[ia]
            maxh[1] = grid_h₁[ia]

            for j ∈ 2:(J+1)
                minh[j] = (1-δ)*minh[j-1]
                maxh[j] = ((1-δ)*maxh[j-1]) + (grid_a[ia]*(1^ϕ))
            end

            # Assemble grids
            fullgrid = range(minh[1], stop = maxh[J+1], length = gp_h)
            for j ∈ 1:(J+1)
                grids_h[ia,j] = range(
                    minh[j],
                    stop = maxh[j],
                    length = length(fullgrid[fullgrid .< maxh[j]]) + 1
                    )
            end
        end

        # Stochastic value staying at home
        MCκ = rouwenhorst(gp_κ, ρ_κ, σ_κ)
        grid_κ = MCκ.state_values
        P_κ = MCκ.p

        # Create age range
        agerange = initialage:(initialage + J - 1)

        new(r, ω,
            ϕ, δ,
            β, ψ, γ, κ₀, κ₁, κ₂, η, ρ_κ, σ_κ,
            gp_h, gp_κ, J, nagents, nlevels,
            grid_a, grid_h₁, grids_h, grid_κ, MCκ, P_κ,
            popshare, lbhours, initialage, agerange
            )
    end
end

## Functions
"""
    loadCSVinput(inputname::String, group::String)

Loads data from a CSV file located in the `model_inputs` folder and returns a DataFrame containing data specific to the provided `group`.

# Arguments
- `inputname::String`: The relative path to the CSV file, including the file name. For example, `model_inputs/parameters.csv`.
- `group::String`: The name of the column in the CSV file that contains the group information. For example: `Black`.

# Notes
- The function assumes that the CSV file has a header row containing column names.
- The `group` column in the loaded DataFrame is converted to lowercase for consistent matching.
"""
function loadCSVinput(inputname::String, group::String)
    # Load CSV
    df = CSV.read("model_inputs/$(inputname).csv", DataFrame)

    # Change group to lowercase in loaded DataFrame
    df[:, :group] .= lowercase.(df.group)

    # Select group's data
    df = df[df.group .== lowercase(group), Not(:group)]

    return df
end

"""
    generateparameters(group::String)

Generates an instance of `ModelParameters` by loading and processing input data specific to the provided `group`.

# Arguments
- `group::String`: The name of the predefined group. Valid options are 'Black' or 'White'.
"""
function generateparameters(group::String)
    # Lowercase group
    group = lowercase(group)

    # Initialise empty dictionary of DataFrames to store input data
    df = Dict{String, DataFrame}()

    # Load data from CSV files into dictionary
    for inputname ∈ [
        "conversion", "level_ability", "level_h1", "level_weight", "parameters"
        ]

        df[inputname] = loadCSVinput(inputname, group)
    end

    # Return instance of ModelParameters
    return ModelParameters(
        r = df["parameters"].r[1],
        ω = df["parameters"].omega[1],
        ϕ = df["parameters"].phi[1],
        δ = df["parameters"].delta[1],
        ψ = df["parameters"].psi[1],
        γ = df["parameters"].gamma[1],
        κ₀ = df["parameters"].kappa_0[1],
        κ₁ = df["parameters"].kappa_1[1],
        κ₂ = df["parameters"].kappa_2[1],
        η = df["parameters"].eta[1],
        lbhours = df["conversion"].lbhours[1],
        initialage = df["conversion"].initialage[1],
        grid_a = df["level_ability"].ability,
        grid_h₁ = df["level_h1"].h1,
        popshare = df["level_weight"].weight
        )
end

"""
    modifyparameters(p::ModelParameters; np...)

Creates a new instance of `ModelParameters` by modifying the specified fields while copying the remaining fields from the input `p`.

# Arguments:
- `p::ModelParameters`: The original instance of `ModelParameters`.
- `np...`: Keyword arguments representing the fields of `ModelParameters` to be modified along with their desired values. Example: `ψ = 1.0, γ = 2.0`.

# Note
- The function assumes that the specified keyword arguments correspond to the fields of `ModelParameters`.
"""
function modifyparameters(p::ModelParameters; np...)
    return ModelParameters(
        r = (haskey(np, :r) ? np[:r] : p.r),
        ω = (haskey(np, :ω) ? np[:ω] : p.ω),
        ϕ = (haskey(np, :ϕ) ? np[:ϕ] : p.ϕ),
        δ = (haskey(np, :δ) ? np[:δ] : p.δ),
        ψ = (haskey(np, :ψ) ? np[:ψ] : p.ψ),
        γ = (haskey(np, :γ) ? np[:γ] : p.γ),
        κ₀ = (haskey(np, :κ₀) ? np[:κ₀] : p.κ₀),
        κ₁ = (haskey(np, :κ₁) ? np[:κ₁] : p.κ₁),
        κ₂ = (haskey(np, :κ₂) ? np[:κ₂] : p.κ₂),
        η = (haskey(np, :η) ? np[:η] : p.η),
        lbhours = (haskey(np, :lbhours) ? np[:lbhours] : p.lbhours),
        initialage = (haskey(np, :initialage) ? np[:initialage] : p.initialage),
        grid_a = (haskey(np, :grid_a) ? np[:grid_a] : p.grid_a),
        grid_h₁ = (haskey(np, :grid_h₁) ? np[:grid_h₁] : p.grid_h₁),
        popshare = (haskey(np, :popshare) ? np[:popshare] : p.popshare)
        )
end

"""
    modifyparameters(group::String; np...)

Creates a new instance of `ModelParameters` by modifying the fields specified in `np...` while copying the remaining fields from the `generateparameters(group)` function.

# Arguments
- `group::String`: The name of the predefined group. It can be either "Black" or "White".
- `np...`: Keyword arguments representing the fields of `ModelParameters` with their desired values. Example: `ψ = 1.0, γ = 2.0`.

# Note
- The function assumes that the specified keyword arguments correspond to the fields of `ModelParameters`.
"""
function modifyparameters(group::String; np...)
    return modifyparameters(generateparameters(group); np...)
end
