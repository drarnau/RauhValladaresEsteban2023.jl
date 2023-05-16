using Documenter
using RauhValladaresEsteban2023

makedocs(
    sitename = "RauhValladaresEsteban2023.jl",
    format = Documenter.HTML(),
    modules = [RauhValladaresEsteban2023],
    pages = [
        "Home" => "index.md",
        "Model" => "model.md",
        "Library" => [
            "Public" => "lib/public.md",
            "Internal" => "lib/internals.md"
        ]
    ]
)
