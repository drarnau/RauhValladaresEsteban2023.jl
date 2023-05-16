## Functions available outside the package

## Functions
"""
    gss(f::Function, a::Float64, b::Float64, tol::Float64 = 1e-6)

Returns argument that maximises value of function `f` over the interval [a,b] and value of function `f` at the maximising point using the Golden search method.

**Arguments**:
- `f`: Univariate function.
- `a`: Lower bound.
- `b`: Upper bound.
- `tol`: Tolerance of the stopping.
"""
function gss(f, a::Float64, b::Float64, tol::Float64 = 1e-6)::Tuple{Float64,Float64}
    Gratio = Base.MathConstants.golden
    c = b - (b - a) / Gratio
    d = a + (b - a) / Gratio
    while abs(c - d) > tol
        if f(c) > f(d)
            b = d
        else
            a = c
        end

        c = b - (b - a) / Gratio
        d = a + (b - a) / Gratio
    end
    return (b + a) / 2, f((b + a) / 2)
end

"""
    findn(h::Float64, a::Float64, uᴴ::Float64, fV′, p::ModelParameters)

Returns the optimal hours worked and the utility value associated to the optimal hours.

# Arguments
- `h::Float64`: Human capital.
- `a::Float64`: Ability to accumulate human capital.
- `uᴴ::Float64`: Utility of staying at home.
- `fV′`: Function computing the continuation value of the next period with respect to hours worked in the current period.
- `p::ModelParameters`: Instance of `ModelParameters` containing parameter values β.
"""
function findn(h::Float64, a::Float64, uᴴ::Float64, fV′, p::ModelParameters)
    @unpack β = p

    # Compute optimal hours (n) and value of work (W)
    n, W = gss(x -> fuᵂ(h, x, p) + (β*fV′(fh′(h, a, x, p))), 0., 1.)

    # Compute value of staying at home
    H = uᴴ + (β*fV′(fh′(h, a, 0., p)))

    return (W >= H)*n, max(W, H)
end

"""
    policyfunction(ia::Int64, p::ModelParameters)

Returns the policy function for optimal labor supply decisions.

# Arguments
- `ia::Int64`: Index of the ability to accumulate human capital.
- `p::ModelParameters`: Instance of `ModelParameters` containing relevant model parameters.
"""
function policyfunction(ia::Int64, p::ModelParameters)
    @unpack J, gp_h, grids_h, grid_a, gp_κ, P_κ, grid_κ = p

    # Initialise value and policy functions
    V = Vector{Array{Float64,2}}(undef, J+1)
    V[J+1] = zeros(gp_κ, gp_h)
    n = Vector{Array{Float64,2}}(undef, J)

    # Iterate over all periods backwards
    for j ∈ J:-1:1
        # Create in-period matrices
        Vⱼ = Array{Float64,2}(undef, gp_κ, length(grids_h[ia, j]))
        nⱼ = similar(Vⱼ)

        # Iterate over staying at home shocks
        for (iκ, κ) ∈ enumerate(grid_κ)
            # Value function tomorrow
            fV′ = interpolate((grids_h[ia,j+1],), vec(P_κ[iκ,:]'*V[j+1]), Gridded(Linear()))

            # Find optimal labour supply for each level of human capital
            for (ih, h) ∈ enumerate(grids_h[ia,j])
                nⱼ[iκ,ih], Vⱼ[iκ,ih] = findn(h, grid_a[ia], fuᴴ(h,κ,j,p), fV′, p)
            end
        end

        # Add period solucions to value and policy functions
        V[j] = copy(Vⱼ)
        n[j] = copy(nⱼ)
    end

    return n
end
