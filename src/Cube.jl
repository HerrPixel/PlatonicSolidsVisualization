function cube_vertices()::Vector{Vector{Float64}}
    vertices = [
        [1, 1, 1],
        [1, 1, -1],
        [1, -1, 1],
        [1, -1, -1],
        [-1, 1, 1],
        [-1, 1, -1],
        [-1, -1, 1],
        [-1, -1, -1]
    ]

    return vertices
end

function cube_edges()::Vector{(Int, Int)}
    edges = [
        (1, 2),
        (1, 3),
        (1, 5),
        (2, 4),
        (2, 6),
        (3, 4),
        (3, 7),
        (4, 8),
        (5, 6),
        (5, 7),
        (6, 8),
        (7, 8)
    ]
    return edges
end
