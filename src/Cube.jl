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

function cube_edges()::Vector{Tuple{Int,Int}}
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

function cube_faces()::Vector{Vector{Int}}
    faces = [
        [1, 2, 4, 3],
        [1, 5, 6, 2],
        [1, 3, 7, 5],
        [2, 6, 8, 4],
        [3, 4, 8, 7],
        [5, 7, 8, 6],
    ]

    return faces
end

function plot_cube()
    vertices = cube_vertices()
    edges = cube_edges()
    faces = cube_faces()

    plot_3D_object(vertices, edges, faces)

end
