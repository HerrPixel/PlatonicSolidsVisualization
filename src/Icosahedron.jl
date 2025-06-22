function icosahedron_vertices()::Vector{Vector{Float64}}
    φ = (1 + sqrt(5)) / 2  # golden ratio

    vertices = [
        [-1, φ, 0],
        [1, φ, 0],
        [-1, -φ, 0],
        [1, -φ, 0],
        [0, -1, φ],
        [0, 1, -φ],
        [0, -1, -φ],
        [0, 1, φ],
        [φ, 0, -1],
        [φ, 0, 1],
        [-φ, 0, -1],
        [-φ, 0, 1]
    ]
    return vertices
end

function icosahedron_edges()::Vector{Tuple{Int,Int}}
    edges = [
        (1, 2),
        (1, 6),
        (1, 8),
        (1, 11),
        (1, 12),
        (2, 6),
        (2, 8),
        (2, 9),
        (2, 10),
        (3, 4),
        (3, 5),
        (3, 7),
        (3, 11),
        (3, 12),
        (4, 5),
        (4, 7),
        (4, 9),
        (4, 10),
        (5, 8),
        (5, 10),
        (5, 12),
        (6, 7),
        (6, 9),
        (6, 11),
        (7, 9),
        (7, 11),
        (8, 10),
        (8, 12),
        (9, 10),
        (11, 12)
    ]

    return edges
end

function plot_icosahedron()
    vertices = icosahedron_vertices()
    edges = icosahedron_edges()

    plot_3D_object(vertices, edges)
end
