function tetrahedon_vertices()::Vector{Vector{Float64}}
    δ = (1 / sqrt(2))

    vertices = [
        [1, 0, -δ],
        [-1, 0, -δ],
        [0, 1, δ],
        [0, -1, δ]
    ]

    return vertices
end

function tetrahedon_edges()::Vector{Tuple{Int,Int}}
    edges = [
        (1, 2),
        (1, 3),
        (1, 4),
        (2, 3),
        (2, 4),
        (3, 4)
    ]
    return edges
end

function tetrahedon_faces()::Vector{Vector{Int}}
    faces = [
        [1, 2, 3],
        [1, 3, 4],
        [1, 4, 2],
        [2, 4, 3]
    ]

    return faces
end

function plot_tetrahedon()
    plot_platonic_solids("Tetrahedon")
end
