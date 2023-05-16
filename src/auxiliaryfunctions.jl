"""
    fh′(h::Float64, a::Float64, n::Float64, p::ModelParameters)::Float64

Returns the value of human capital in the next period.

# Arguments
- `h::Float64`: Human capital in the current period.
- `a::Float64`: Ability to acumulate human capital.
- `n::Float64`: Hours worked.
- `p::ModelParameters`: Instance of `ModelParameters` containing parameter values ϕ and δ.
"""
function fh′(h::Float64, a::Float64, n::Float64, p::ModelParameters)::Float64
    @assert n >= 0.0 "Hours worked (n) cannot be smaller than 0"
    @assert n <= 1.0 "Hours worked (n) cannot be bigger than 1"

    @unpack ϕ, δ = p

    return ((1-δ)*h) + (a*(n^ϕ))
end

"""
    fuᴴ(h::Float64, κ::Float64, j::Int64, p::ModelParameters)::Float64

Returns the utility value of staying at come.

# Arguments
- `h::Float64`: Human capital.
- `κ::Float64`: Realisation of the stay-at-home value shock.
- `j::Int64`: Age.
- `p::ModelParameters`: Instance of `ModelParameters` containing parameter values ψ, γ, η, κ₀, κ₁, and κ₂.
"""
function fuᴴ(h::Float64, κ::Float64, j::Int64, p::ModelParameters)::Float64
    @unpack ψ, γ, η, κ₀, κ₁, κ₂ = p

    return (ψ/(1-γ))*(h^η)*(exp(κ₀ + (κ₁*j) + (κ₂*(j^2)) + κ))
end

"""
    fuᵂ(h::Float64, n::Float64, p::ModelParameters)::Float64

Returns the utility value of working.

# Arguments
- `h::Float64`: Human capital.
- `n::Float64`: Hours worked.
- `p::ModelParameters`: Instance of `ModelParameters` containing parameter values ω, γ, and ψ.
"""
function fuᵂ(h::Float64, n::Float64, p::ModelParameters)::Float64
    @assert n >= 0.0 "Hours worked (n) cannot be smaller than 0"
    @assert n <= 1.0 "Hours worked (n) cannot be bigger than 1"

    @unpack ω, γ, ψ = p

    if isapprox(γ, 1)
        return (ω*h*n) + (ψ*h*(log(1-n)))
    else
        return (ω*h*n) + (ψ*h*(((1-n)^(1-γ))/(1-γ)))
    end
end
