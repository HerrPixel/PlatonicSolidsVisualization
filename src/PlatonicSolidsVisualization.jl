module PlatonicSolidsVisualization
include("Visualizer.jl")
include("Icosahedron.jl")
include("Cube.jl")
include("Dodecahedron.jl")
include("Tetrahedon.jl")
include("Octahedron.jl")

export plot_icosahedron
export plot_cube
export plot_tetrahedon
export plot_dodecahedron
export plot_octahedron
export plot_platonic_solids
end
