## Functions available outside the package
export plotmvsd

## Functions
"""
    plotmvsd(
        m::Vector{Float64},
        d::Vector{Float64};
        de::Union{Vector{Float64}, Nothing} = nothing,
        haxis = 1:length(d),
        ttl = "",
        mlbl = "Model",
        dlbl = "Data",
        xlbl = "Age",
        flllph = 0.1,
        zα = 1.96
        )

Plots the model simulated data and _real_ data with error bars representing the standard error.

# Arguments
- `m::Vector{Float64}`: Model simulated data.
- `d::Vector{Float64}`: _Real_ data.
- `de::Union{Vector{Float64}, Nothing} = nothing`: Optional vector of standard errors for the data. If not provided (default), error bars will not be shown.
- `haxis`: Horizontal axis values for the plot. Defaults to `1:length(d)`.
- `ttl::String = ""`: Optional title for the plot.
- `mlbl::String = "Model"`: Label for the model predictions in the legend.
- `dlbl::String = "Data"`: Label for the data in the legend.
- `xlbl::String = "Age"`: Label for the x-axis.
- `flllph::Float64 = 0.1`: Fill alpha value for the error bars. Defaults to 0.1.
- `zα::Float64 = 1.96`: Z-value corresponding to the desired level of confidence for the error bars. Defaults to 1.96, representing the 95% confidence level.
"""
function plotmvsd(
    m::Vector{Float64},
    d::Vector{Float64};
    de::Union{Vector{Float64}, Nothing} = nothing,
    haxis = 1:length(d),
    ttl = "", mlbl = "Model", dlbl = "Data", xlbl = "Age", flllph = 0.1, zα = 1.96
    )

    # Assing vector of NaN if de is nothing
    de = (de == nothing ? fill(NaN, length(d)) : de)

    plot(haxis, m, label = mlbl, linewidth = 3)
    plot!(haxis, d, ribbon = (zα*de), label = dlbl, fillalpha = flllph)
    plot!(xlabel = xlbl, title = ttl)
end

"""
    plotmvsd(
        fn::Symbol,
        m::Vector{AgeData},
        d::Vector{AgeData};
        de::Union{Vector{AgeData}, Nothing} = nothing,
        plt_ttl::String = "",
        lyt = (1, 5),
        sz = (2000, 500),
        mrgn = (50, :px),
        ylms = (0, NaN),
        haxis = 1:length(d),
        spttls = fill("", length(d)),
        mlbl = "Model",
        dlbl = "Data",
        xlbl = "Age",
        flllph = 0.1,
        zα = 1.96
        )

Plots multiple subplots the model simulated data and _real_ data with error bars representing the standard error.

# Arguments
- `fn::Symbol`: Field name to plot from `AgeData` instances.
- `m::Vector{AgeData}`: Vector of `AgeData` structures of model simulated data.
- `d::Vector{AgeData}`: Vector of `AgeData` structures of _real_ data.
- `de::Union{Vector{AgeData}, Nothing} = nothing`: Optional vector of `AgeData` instances representing standard errors for the data. If not provided (default), error bars will not be shown.
- `plt_ttl::String = ""`: Optional title for the overall plot.
- `lyt::Tuple{Int64, Int64} = (1, 5)`: Layout of subplots in rows and columns.
- `sz::Tuple{Int64, Int64} = (2000, 500)`: Size of the overall plot.
- `mrgn::Tuple{Int64, Symbol} = (50, :px)`: Margin size and unit for the overall plot.
- `ylms::Tuple{Float64, Float64} = (0, NaN)`: Y-axis limits for the overall plot.
- `haxis`: Horizontal axis values for each subplot. Defaults to `1:length(d)`.
- `spttls::Vector{String} = fill("", length(d))`: Titles for each subplot. Defaults to an empty string for each subplot.
- `mlbl::String = "Model"`: Label for the model predictions in the legend.
- `dlbl::String = "Data"`: Label for the data in the legend.
- `xlbl::String = "Age"`: Label for the x-axis.
- `flllph::Float64 = 0.1`: Fill alpha value for the error bars. Defaults to 0.1.
- `zα::Float64 = 1.96`: Z-value corresponding to the desired level of confidence for the error bars. Defaults to 1.96, representing the 95% confidence level.
"""
function plotmvsd(
    fn::Symbol,
    m::Vector{AgeData},
    d::Vector{AgeData};
    de::Union{Vector{AgeData}, Nothing} = nothing,
    plt_ttl::String = "", lyt = (1, 5), sz = (2000, 500), mrgn = (50, :px), ylms = (0, NaN),
    haxis = 1:length(d),
    spttls = fill("", length(d)),
    mlbl = "Model", dlbl = "Data", xlbl = "Age", flllph = 0.1, zα = 1.96
    )

    # Assert AgeData data (d) and AgeData model (m) vectors have the same length
    ld = length(d)
    @assert ld == length(m) "data (d) and model(m) vectors length must be equal"

    # Assert AgeData data (d) and AgeData sterror (de) vectors have the same length
    if de != nothing
        @assert ld == length(de) "data (d) and sterror (de) vectors length must be equal"
    end

    # Initialise vector to store subplots
    subplts = Vector{Any}(undef, ld)

    # Iterate over vector elements
    for l ∈ 1: ld
        subplts[l] = plotmvsd(
            getfield(m[l], fn),
            getfield(d[l], fn),
            de = (de != nothing ? getfield(de[l], fn) : nothing),
            ttl = spttls[l],
            haxis = haxis, mlbl = mlbl, dlbl = dlbl, xlbl = xlbl, flllph = flllph, zα = zα
            )
    end

    plot(subplts...,
        plot_title = plt_ttl,
        layout = lyt,
        size = sz,
        margin = mrgn,
        ylims = ylms,
        link = :all
        )
end
