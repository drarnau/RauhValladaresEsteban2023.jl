## Load packages
using Plots
using RauhValladaresEsteban2023
using StatsBase
using Tectonic

## Define race groups and load parameters for each group
groups = ["Black", "White"]
p = Dict(r => generateparameters(r) for r ∈ groups)

## Model simulated wages (using data labour supply) vs. data
# Load NLSY microdata
nlsymd = Dict(r => loadnlsydata(r) for r ∈ groups)
nlsymd["All"] = loadnlsydata()

# Simulate wages microdata based on NLSY labour supply
simwmd = simulatewages(nlsymd["All"], p[rand(groups)])

# Plot and export
plotmvsd(:wage,
    statsfbyage(mean, simwmd),
    statsfbyage(mean, nlsymd["All"]),
    de = statsfbyage(sterror, nlsymd["All"]),
    haxis = p[rand(groups)].agerange,
    spttls = ["Ability/AFQT Decile $i" for i ∈ 1:length(nlsymd["All"])],
    lyt = (2, 5),
    sz = (2000, 1000)
    )
png("figures/mvsd_wage_dataLS")

## Model simulated hours and employment vs. data
# Simulate model microdata for both groups
benchmarkmd = Dict(r => solvemodel(p[r]) for r ∈ groups)

# Define ability groupings
groupings = [1, 2, 3, 4, 5:10]

for r ∈ groups
    # Create vector of subplot titles
    spttls = ["$r Ability Decile $i" for i ∈ groupings]

    # Plot hours and employment rates
    for s ∈ [:hours, :employed]
        plotmvsd(s,
            groupingmean(groupings, statsfbyage(mean, benchmarkmd[r]), p[r]),
            statsfbyage(mean, catmicrodata(groupings, nlsymd[r])),
            de = statsfbyage(sterror, catmicrodata(groupings, nlsymd[r])),
            haxis = p[r].agerange,
            spttls = spttls,
            ylms = (0, 1.1)
            )
        png("figures/mvsd_$(string(s))_$r")
    end
end

## Counterfactual experiements
# Initialise dictionary to store counterfactual experiments
experiments = Dict{String, Any}()

# Utility of staying at home (κ₀ , κ₁, κ₂, and η)
experiments["Utility home"] = solvemodel(modifyparameters(p["Black"],
    κ₀ = p["White"].κ₀, κ₁ = p["White"].κ₁, κ₂ = p["White"].κ₂, η = p["White"].η
    ))

# Utility employed (ψ and γ)
experiments["Utility employed"] = solvemodel(modifyparameters(p["Black"],
    ψ = p["White"].ψ, γ = p["White"].γ
    ))

# Utilities home & employed
experiments["Utilities home & employed"] = solvemodel(modifyparameters(p["Black"],
    κ₀ = p["White"].κ₀, κ₁ = p["White"].κ₁, κ₂ = p["White"].κ₂, η = p["White"].η,
    ψ = p["White"].ψ, γ = p["White"].γ
    ))

# Constant labor supply
experiments["Constant labor supply"] = solveconstantls(p["Black"], p["White"])

## Counterfactual gaps
# Define function to compute gaps with respect to benchmark Whites
fgap(cf, cfps = p["Black"].popshare, w = benchmarkmd["White"], wps = p["White"].popshare) =
    meangap(cf, cfps, w, wps)

# Initialise dictionary to store counterfactual experiments
gaps = Dict{String, AggregateData}()

# Iterate over saved experiments
for (nexp, mdexp) ∈ experiments
    gaps[nexp] = fgap(mdexp)
end

# Benchmark
gaps["Benchmark"] = fgap(benchmarkmd["Black"])

# Distribution (a, h₁)
gaps["Distribution"] = fgap(benchmarkmd["Black"], p["White"].popshare)

# Distribution & utility home
gaps["Distribution & utility home"] = fgap(experiments["Utility home"], p["White"].popshare)

# Distribution & utility employed
gaps["Distribution & utility employed"] = fgap(experiments["Utility employed"], p["White"].popshare)

# Print LaTeX table with gaps
latexcf(gaps)

# Compile LaTeX
tectonic() do bin
   run(`$bin tables/counterfactuals.tex`)
end

## Model racial gaps over the life cycle vs. data
# Aggregate NLSY data to group age means
nlsyad = Dict(r => statsfbyage(mean, catmicrodata(nlsymd[r])) for r ∈ groups)

# Aggregate model data to group age means
benchmarkad =
    Dict(r => groupingmean(statsfbyage(mean, benchmarkmd[r]), p[r].popshare) for r ∈ groups)

# Aggregate distribution counterfactual age means
distributionad = groupingmean(statsfbyage(mean, benchmarkmd["Black"]), p["White"].popshare)

# Plot wage and employment rates
for s ∈ [:wage, :employed]
    plotmvsd(
        gap.(getfield(benchmarkad["Black"], s), getfield(benchmarkad["White"],s)),
        gap.(getfield(nlsyad["Black"], s), getfield(nlsyad["White"], s)),
        haxis = p[rand(groups)].agerange,
        mlbl = "Benchmark"
        )
    plot!(p[rand(groups)].agerange,
        gap.(getfield(distributionad, s), getfield(benchmarkad["White"], s)),
        label = "Equal initial conditions", linecolor = :gray, linewidth = 3, linestyle = :dash,
        ylims = (0, NaN)
        )
    png("figures/mvsdcf_$(string(s))")
end
