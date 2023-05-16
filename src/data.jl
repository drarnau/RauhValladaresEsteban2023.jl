## Functions available outside the package
export loadnlsydata, statsfbyage, sterror, catmicrodata, groupingmean, gap, meangap, AggregateData

## Structures
"""
MicroData

A composite type that represents individual-level data on wages, hours worked, employment status, and individual population weights. Each row corresponds to an agent/individual, and each column represents a period.

# Fields
- `wage::Matrix{Union{Missing, Float64}}`: Hourly wage.
- `hours::Matrix{Union{Missing, Float64}}`: Hours worked.
- `employed::Matrix{Union{Missing, Bool}}`: Employment indicator.
- `weights::Matrix{Union{Missing, Int64}}`: Individual frequency weights.
"""
struct MicroData
    wage::Matrix{Union{Missing, Float64}}   # Hourly wage [rows:agent, columns: periods]
    hours::Matrix{Union{Missing, Float64}}  # Hours worked [rows:agent, columns: periods]
    employed::Matrix{Union{Missing, Bool}}  # Employment indicator [rows:agent, columns: periods]
    weights::Matrix{Union{Missing, Int64}}  # Indivividual weights [rows:agent, columns: periods]

    function MicroData(;
        wage,
        hours = fill(missing, size(wage)),
        employed = fill(missing, size(wage)),
        weights = ones(size(wage))
        )

        # Assert matrices have correct size
        wsize = size(wage)
        @assert size(hours) == wsize "hours has the wrong size"
        @assert size(employed) == wsize "employed has the wrong size"
        @assert size(weights) == wsize "weights has the wrong size"

        new(wage, hours, employed, weights)
    end
end

"""
AgeData

A composite type that represents a summary statistic by age for hourly wages, hours worked, and employment status. For example, average wages by age.

# Fields
- `wage::Vector{Float64}`: Hourly wage.
- `hours::Vector{Float64}`: Hours worked.
- `employed::Vector{Float64}`: Employment status.
"""
struct AgeData
    wage::Vector{Float64}       # Hourly wage
    hours::Vector{Float64}      # Hours worked
    employed::Vector{Float64}   # Employment

    function AgeData(; wage, hours, employed)
        # Assert vectors have the correct length
        wlength = length(wage)
        @assert length(hours) == wlength "wage has the wrong length"
        @assert length(employed) == wlength "employed has the wrong length"

        new(wage, hours, employed)
    end
end

"""
    AggregateData

Composite type that contains a summary statistic for hourly wages among the employed, hours worked among the employed, employment rate, income among all, and income among the employed. For example, average wages.

# Fields
- `wage::Float64`: Average wage among the employed.
- `hours::Float64`: Hours worked among the employed.
- `employment::Float64`: Employment rate.
- `incomeall::Float64`: Average income among all.
- `incomeemp::Float64`: Average income among the employed.
"""
struct AggregateData
    wage::Float64           # Average wage among the employed
    hours::Float64          # Hours worked among the employed
    employment::Float64     # Employment rate
    incomeall::Float64      # Average income among all
    incomeemp::Float64        # Average income among the employed

    function AggregateData(; wage, hours, employment, incomeall, incomeemp)
        new(wage, hours, employment, incomeall, incomeemp)
    end
end

## Functions
"""
    loaddeciledata(filename::String, group::String = "")

Loads decile data from a predefined CSV file and returns it as a `MicroData` structure.

# Arguments
- `filename::String`: The path to the CSV file containing the decile data. Example: `nlsydata/afqt_decile_1.csv`.
- `group::String`: (optional) The group to which the data should be restricted. Valid values are "Black", "White", or an empty string (default).

# Returns
A `MicroData` instance containing the loaded decile data.

# Notes
- The CSV file is expected to have the following columns: "wage", "hours", "employed", and "weights" (or columns that contain these strings as substrings).
- If `group` is specified, the data will be restricted to the specified group ("Black" or "White") based on the values in the "black" column.

# Examples
```julia
data = loaddeciledata("nlsydata/afqt_decile_1.csv")  # Load all decile data
data = loaddeciledata("nlsydata/afqt_decile_1.csv", "black")  # Load decile data for the black group only
```
"""
function loaddeciledata(filename::String, group::String = "")
    # Load raw data from CSV
    rawdata = CSV.File(filename) |> DataFrame

    # Apply sample restriction if group is specified
    if group != ""
        # Lowercase group
        group = lowercase(group)
        if (group == "black") | (group == "white")
            rawdata = rawdata[rawdata.black .== (group == "black"), :]
        else
            error("group must be either 'black', 'white', or empty")
        end
    end

    # Return mircrodata structure
    return MicroData(
        wage = Matrix(select(rawdata, [x for x ∈ names(rawdata) if occursin("inch_norm", x)])),
        hours = Matrix(select(rawdata, [x for x ∈ names(rawdata) if occursin("hours_norm", x)])),
        employed = Matrix(select(rawdata, [x for x ∈ names(rawdata) if occursin("E", x)])),
        weights = Matrix(select(rawdata, [x for x ∈ names(rawdata) if occursin("weight", x)]))
        )
end

"""
    loadnlsydata(group::String = "")

Loads NLSY (National Longitudinal Survey of Youth) data from the `nlsy_data` folder and returns it as an vector of `MicroData`.

# Arguments
- `group::String`: (optional) The group to which the data should be restricted. Valid values are "Black", "White", or an empty string (default).

# Notes
- The function reads all files in the `nlsy_data` folder and assumes that each file contains AFQT decile data in the expected format.
- If `group` is specified, the data will be restricted to the specified group ("black" or "white") for each file.

# Examples
```julia
data = loadnlsydata()  # Load NLSY data for all groups
data = loadnlsydata("black")  # Load NLSY data for the black group only
```
"""
function loadnlsydata(group::String = "")
    # Read path to all files in `nlsy_data` folder
    nlsyfiles = readdir("nlsy_data", join = true)

    # Initialise vector to store data
    nlsydata = Vector{MicroData}(undef, length(nlsyfiles))

    # Iterate over files in `nlsy folder`
    for filename ∈ nlsyfiles
        # Read index for vector
        i = parse(Int64,(filter(isdigit, filename)))

        # Load data
        nlsydata[i] = loaddeciledata(filename, group)
    end

    return nlsydata
end

"""
    catmicrodata(v::Vector{MicroData})

Concatenates multiple instances of `MicroData` structures stored in vector (`v`) and returns a new `MicroData` instance with the concatenated data.

# Arguments
- `v::Vector{MicroData}`: A vector of `MicroData` instances to be concatenated.

# Notes
- The function assumes that all `MicroData` instances in the input vector have the same structure.
- The concatenation is performed by vertically stacking the corresponding fields of each `MicroData` instance.
- The resulting `MicroData` instance will have the same field names as the input instances.
"""
function catmicrodata(v::Vector{MicroData})
    # Read field names of MicroData
    fns = fieldnames(MicroData)

    # Initialise vector to store results before creating inmutable struct
    z = Vector{Matrix{Any}}(undef, length(fns))

    # Read length MicroData vector
    l = length(v)

    # Iterate over field names of MicroData stucture
    for (ifn, fn) ∈ enumerate(fns)
        # Allocate first element in return object
        z[ifn] = getfield(v[1], fn)

        # Concatenate remaining elements
        for i ∈ 2:l
            z[ifn] = cat(z[ifn], getfield(v[i], fn), dims = 1)
        end
    end

    # Return MicroData structure
    return MicroData(; NamedTuple{fns}(z)...)
end
catmicrodata(md::MicroData) = md

"""
    catmicrodata(grps::Vector, v::Vector{MicroData})

Concatenates multiple `MicroData` instances based on groupings provided in `grps`.

# Arguments
- `grps::Vector`: Vector of groupings, where each element is a single index (an `Int64`) or a range of indices (`UnitRange{Int64}`). The indices correspond to the positions of `MicroData` instances in the input vector `v`.
- `v::Vector{MicroData}`: Vector of `MicroData` instances to be concatenated.

# Notes
- The length of the `grps` vector must be less than or equal to the length of the `v` vector.
- Each element in `grps` specifies a grouping of `MicroData` instances to be concatenated together.
- The output vector `z` has the same length as the `grps` vector.
"""
function catmicrodata(grps::Vector, v::Vector{MicroData})
    # Assert expanded elements in grps are smaller or equal than v
    lgrps = length([i for gp ∈ grps for i ∈ gp])
    @assert lgrps <= length(v) "Groupings length must be <= length MicroData vector"

    # Initialise return MicroData Vector
    z = Vector{MicroData}(undef, length(grps))

    # Iterate over groupings
    for (i, gp) ∈ enumerate(grps)
        z[i] = catmicrodata(v[gp])
    end

    return z
end

"""
    sterror(v::AbstractVector{<:Real}, w::AbstractWeights)

Calculates the standard error of a weighted sample vector `v` using the provided weights `w`.

# Arguments
- `v::AbstractVector{<:Real}`: A vector of real values representing the sample data.
- `w::AbstractWeights`: An abstract type representing the weights associated with each data point in `v`.

# Notes
- The weights `w` must have the same length as the vector `v`.
- The standard error is calculated as the standard deviation of `v` weighted by `w`, divided by the square root of the sample size (`length(w)`).
"""
function sterror(v::AbstractVector{<:Real}, w::AbstractWeights)
    return (std(v, w)) / (sqrt(length(w)))
end

"""
    statsfbyage(f, y::Matrix)

Applies the statistical function `f` to each column of the matrix `y`, treating missing values as skipped.

# Arguments
- `f`: A statistical function to apply to each column of `y`.
- `y::Matrix`: A matrix containing the data for which the statistics will be calculated.
"""
function statsfbyage(f, y::Matrix)
    return map(x -> f(skipmissing(x)), eachcol(y))
end

"""
    statsf(f, y::Matrix)

Applies the statistical function `f` to the matrix `y`, skipping missing values.

# Arguments
- `f`: A statistical function to apply to the matrix `y`.
- `y::Matrix`: A matrix containing the data for which the statistic will be calculated.
"""
statsf(f, y::Matrix) = f(skipmissing(y))

"""
    statsfbyage(f, y::Matrix, w::Matrix)

Applies the statistical function `f` to each column of the matrix `y` weighted by corresponding elements in the matrix `w`, skipping missing values.

# Arguments
- `f`: A statistical function to apply to each column of the matrix `y` weighted by `w`.
- `y::Matrix`: A matrix containing the data for which the statistic will be calculated.
- `w::Matrix`: A matrix containing the weights to be applied to each element of `y`. The size of `w` should match the size of `y`.
"""
function statsfbyage(f, y::Matrix, w::Matrix)
    # Read size of y
    (yrows, ycols) = size(y)

    # Assert size of y and w match
    @assert (yrows, ycols) == size(w) "sizes of y and w do not match"

    # Create vector to store column means
    z = Vector(undef, ycols)

    # Iterate over columns of y
    for j ∈ 1:ycols
        # Find elements not missing in y neither w
        idx = (.!ismissing.(y[:,j])) .& (.!ismissing.(w[:,j]))

        # Compute column weighted mean
        z[j] = f(disallowmissing(y[idx,j]), fweights(disallowmissing(w[idx,j])))
    end

    return z
end

"""
    statsf(f, y::Matrix, w::Matrix)

Applies the statistical function `f` to a matrix `y` weighted by corresponding elements in the matrix `w`, after skipping missing values.

# Arguments
- `f`: A statistical function to apply to the matrix `y` weighted by `w`.
- `y::Matrix`: A matrix containing the data for which the statistic will be calculated.
- `w::Matrix`: A matrix containing the weights to be applied to each element of `y`. The size of `w` should match the size of `y`.
"""
function statsf(f, y::Matrix, w::Matrix)
    # Assert size of y and w match
    @assert size(y) == size(w) "sizes of y and w do not match"

    # Find elements not missing in y neither w
    idx = (.!ismissing.(y)) .& (.!ismissing.(y))

    return f(disallowmissing(y[idx]), fweights(disallowmissing(w[idx])))
end

"""
    statsfbyage(f, d::MicroData)

Applies the statistical function `f` to each column of the wage, hours, and employed fields in the `MicroData` instance `d` weighted by the corresponding elements in the weights field, after skipping missing values.

# Arguments
- `f`: A statistical function to apply to each column of the fields in `d`.
- `d::MicroData`: A `MicroData` object containing wage, hours, employed, and weights fields.
"""
function statsfbyage(f, d::MicroData)
    return AgeData(
        wage = statsfbyage(f, d.wage, d.weights),
        hours = statsfbyage(f, d.hours, d.weights),
        employed = statsfbyage(f, d.employed, d.weights)
        )
end
statsfbyage(f, v::Vector{MicroData}) = statsfbyage.(Ref(f), v)

"""
    groupingmean(m::Vector{AgeData}, w::Vector{Float64})

Computes the weighted mean of each field in the vector of `AgeData` instnaces `m` using the corresponding weights in the vector `w`.

# Arguments
- `m::Vector{AgeData}`: A vector of `AgeData` instances.
- `w::Vector{Float64}`: A vector of weights. The length of `w` must be equal to the length of `m`.
"""
function groupingmean(m::Vector{AgeData}, w::Vector{Float64})
    # Assert AgeData means (m) and weights (w) have the same length
    @assert length(m) == length(w) "AgeData means (m) and weights (m) length must be equal"

    # Assert vector of weights (w) sums up to one
    @assert isapprox(sum(w),1) "weights (w) must sum up to one"

    # Read field names of AgeData
    fns = fieldnames(AgeData)

    # Initialise vector to store results before creating inmutable struct
    z = Vector{Vector{Float64}}(undef, length(fns))

    # Read length wage, hours, employment vectors in AgeData struct
    l = length(m[1].wage)

    # Iterate over field names of AgeData stucture
    for (ifn, fn) ∈ enumerate(fns)
        # Allocate vectors of zeros in return object
        z[ifn] = zeros(l)

        # Iterate over elements in vector of AgeData means
        for (i, d) ∈ enumerate(m)
            z[ifn] = z[ifn] + (w[i]*getfield(d, fn))
        end
    end

    # Return AgeData structure
    return AgeData(; NamedTuple{fns}(z)...)
end
groupingmean(ad::AgeData, w::Float64) = ad

"""
    groupingmean(grps::Vector, v::Vector{AgeData}, p::ModelParameters)

Computes the weighted mean of each field in the vector of `AgeData` instances `v` for specific groupings defined by the indices in `grps`, using the `popshare` field from the `ModelParameters` object `p` as weights.

# Arguments
- `grps::Vector`: Vector of groupings, where each element is a single index (an `Int64`) or a range of indices (`UnitRange{Int64}`). The indices correspond to the positions of `MicroData` instances in the input vector `v`.
- `v::Vector{AgeData}`: A vector of `AgeData` instances.
- `p::ModelParameters`: A `ModelParameters` instance.

# Notes
- The length of the `grps` vector must be less than or equal to the length of the `v` vector.
- Each element in `grps` specifies a grouping of `MicroData` instances to be concatenated together.
- The output vector `z` has the same length as the `grps` vector.
"""
function groupingmean(grps::Vector, v::Vector{AgeData}, p::ModelParameters)
    @unpack popshare = p

    # Assert expanded elements in grps are smaller or equal than v
    lgrps = length([i for gp ∈ grps for i ∈ gp])
    @assert lgrps <= length(v) "Groupings length must be <= length MicroData vector"

    # Initialise return MicroData Vector
    z = Vector{AgeData}(undef, length(grps))

    # Iterate over groupings
    for (i, gp) ∈ enumerate(grps)
        z[i] = groupingmean(v[gp], (popshare[gp]./sum(popshare[gp])))
    end

    return z
end

"""
    micro2aggregate(f, d::MicroData)

Computes aggregate statistics from the `MicroData` instance `d` using the specified statistical function `f`. The function computes aggregate statistics for wage, hours, employment, total income (all individuals), and income (employed individuals).

# Arguments
- `f`: A function that computes the desired aggregate statistic.
- `d::MicroData`: A `MicroData` instance containing agent/individual-level data.

# Note
- The function handles missing values by replacing them with zeros for the total income variable.
"""
function micro2aggregate(f, d::MicroData)
    # Compute income
    income = d.hours .* d.wage

    return AggregateData(
        wage = statsf(f, d.wage),
        hours = statsf(f, d.hours),
        employment = statsf(f, d.employed),
        incomeall = statsf(f, replace(income, missing => 0)),
        incomeemp = statsf(f, income)
        )
end
micro2aggregate(f, v::Vector{MicroData}) = micro2aggregate.(Ref(f), v)

"""
    aggregatemeans(v::Vector{MicroData}, w::Vector{Float64})

Computes aggregate means from the vector of `MicroData` instances `v` using weights `w`. Returns an `AggregateData` instance.

# Arguments
- `v::Vector{MicroData}`: A vector of `MicroData` instances containing agent/individual-level data.
- `w::Vector{Float64}`: A vector of weights. The length of `w` must be equal to the length of `v`.
"""
function aggregatemeans(v::Vector{MicroData}, w::Vector{Float64})
    # Assert MicroData vector and weight vector length are equal
    @assert length(v) == length(w) "MicroData (v) and weight (w) vectors length must be equal"

    # Read field names of AggregateData
    fns = fieldnames(AggregateData)

    # Compute aggregate data for each level
    ad = micro2aggregate(mean, v)

    # Initialise vector to store results before creating inmutable struct
    z = zeros(length(fns))

    # Iterate over levels
    for (i, d) ∈ enumerate(ad)
        # Iterate over field names of AggregateData structure
        for (ifn, fn) ∈ enumerate(fns)
            z[ifn] = z[ifn] + (w[i]*getfield(d, fn))
        end
    end

    # Return AggregateData structure
    return AggregateData(; NamedTuple{fns}(z)...)
end

"""
    gap(b::Float64, w::Float64)

Calculates the gap between the two values `b` and `w` as ``1 - \\frac{b}{w}``.

# Arguments
- `b::Float64`: The numerator value.
- `w::Float64`: The denominator value.
"""
gap(b::Float64, w::Float64) = 1 - (b/w)

"""
    gap(b::AggregateData, w::AggregateData)

Calculates the gap between two `AggregateData` instances `b` and `w` for each corresponding field.

# Arguments
- `b::AggregateData`: The numerator `AggregateData` instance.
- `w::AggregateData`: The denominator `AggregateData` instance.
"""
function gap(b::AggregateData, w::AggregateData)
    # Read field names of AggregateData
    fns = fieldnames(AggregateData)

    # Initialise vector to store results before creating inmutable struct
    z = zeros(length(fns))

    # Iterate over field names of AggregateData structure
    for (ifn, fn) ∈ enumerate(fns)
        z[ifn] = gap(getfield(b,fn), getfield(w,fn))
    end

    # Return AggregateData structure
    return AggregateData(; NamedTuple{fns}(z)...)
end

"""
    meangap(b::Vector{MicroData}, wb::Vector{Float64}, w::Vector{MicroData}, ww::Vector{Float64})

Calculates the mean gap between the two vectors of `MicroData` instances, `b` and `w`, weighted by the corresponding weight vectors `wb` and `ww`.

# Arguments
- `b::Vector{MicroData}`: The numerator vector of `MicroData` instances.
- `wb::Vector{Float64}`: The weight vector corresponding to the numerator vector.
- `w::Vector{MicroData}`: The denominator vector of `MicroData` instances.
- `ww::Vector{Float64}`: The weight vector corresponding to the denominator vector.
"""
function meangap(
    b::Vector{MicroData}, wb::Vector{Float64}, w::Vector{MicroData}, ww::Vector{Float64}
    )
    return gap(aggregatemeans(b, wb), aggregatemeans(w, ww))
end
