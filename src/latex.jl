## Functions available outside the package
export latexcf

## Functions
"""
    latexcf(gaps::Dict{String, AggregateData})

Generates a LaTeX table with counterfactual results based on the provided `gaps` dictionary.

# Arguments
- `gaps::Dict{String, AggregateData}`: Dictionary containing counterfactual results for different scenarios. The keys are scenario names, and the values are `AggregateData` instances representing the gaps.

# Note
- This function generates a LaTeX document and saves it as a file named "counterfactuals.tex" in the "tables" directory. The LaTeX document contains a table displaying the counterfactual results.
"""
function latexcf(gaps::Dict{String, AggregateData})
    # Auxiliary function to print gaps
    function printgaps(gaps::AggregateData, d::Int64 = 3, mf = myfile)
        # Define rounding function
        f(x) = round(x, digits=d)

        # Write gaps
        write(mf, " $(f(gaps.employment)) &")
        write(mf, " $(f(gaps.hours)) &")
        write(mf, " $(f(gaps.wage)) &")
        write(mf, " $(f(gaps.incomeemp)) &")
        write(mf, " $(f(gaps.incomeall)) \\\\ \n")
    end

    # Define dictionary with row names
    rname = Dict("Benchmark" => "Benchmark gap")
    rname["Utility home"] =
        "Utility home (\$\\kappa_0\$, \$\\kappa_1\$, \$\\kappa_2\$, and \$\\eta\$)"
    rname["Utility employed"] = "Utility employed (\$\\psi\$ and \$\\gamma\$)"
    rname["Utilities home & employed"] = "Utilities home \\& employed"
    rname["Distribution"] = "Distribution \$(a,h_0)\$"
    rname["Constant labor supply"] = "Distrib.\\ \$(a,h_0)\$ - constant labor supply"
    rname["Distribution & utility home"] = "Distribution \\& utility home"
    rname["Distribution & utility employed"] = "Distribution \\& utility employed"

    # Write LaTeX document
    myfile = open("tables/counterfactuals.tex", "w")
    write(myfile, "\\documentclass[a4paper,12pt]{article} \n")
    write(myfile, "\\usepackage[capposition=top]{floatrow} \n")
    write(myfile, "\\newcommand{\\rowgroup}[1]{\\hspace{-1em}#1} \n")
    write(myfile, "\\usepackage{fullpage} \n \n")
    write(myfile, "\\begin{document} \n")
    write(myfile, "\\date{} \n")
    write(myfile, "\\thispagestyle{empty} \n \n")
    write(myfile, "\\begin{table}[H] \n")
    write(myfile, "\\centering \n")
    write(myfile, "\\begin{tabular}{llccccc} \n")
    write(myfile, "\\hline \n")
    write(myfile, "\\hline \n")
    write(myfile, "& & & & & \\multicolumn{2}{c}{Earnings} \\\\ \n")
    write(myfile, "\\cline{6-7} \n")
    write(myfile, "& & Emp. Rate &  Hours & Wage & Employed & All \\\\ \n")
    write(myfile, "\\hline \n")

    write(myfile, "$(rname["Benchmark"]) & &")
    printgaps(gaps["Benchmark"])
    write(myfile, "\\vspace{-0.2cm} \\\\ \n")

    write(myfile, "\\rowgroup{\\textit{Experiments}} \\\\ \n")

    for nexp ∈ ["Utility home", "Utility employed", "Utilities home & employed",
        "Distribution", "Constant labor supply",
        "Distribution & utility home", "Distribution & utility employed"
        ]
        write(myfile, "$(rname[nexp]) & &")
        printgaps(gaps[nexp])

        if (nexp == "Utilities home & employed") | (nexp == "Constant labor supply")
            write(myfile, "\\vspace{-0.2cm} \\\\ \n")
        end
    end

    write(myfile, "\\hline \n")
    write(myfile, "\\hline \n")
    write(myfile, "\\end{tabular} \n")
    write(myfile, "\\end{table} \n")
    write(myfile, "\\end{document}")
    close(myfile)
end
