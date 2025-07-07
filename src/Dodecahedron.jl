function dodecahedron_vertices()::Vector{Vector{Float64}}
    ϕ = (1 + sqrt(5)) / 2

    vertices = [
        [1, 1, 1],
        [1, 1, -1],
        [1, -1, 1],
        [1, -1, -1],
        [-1, 1, 1],
        [-1, 1, -1],
        [-1, -1, 1],
        [-1, -1, -1],
        [1 / ϕ, 0, ϕ],
        [1 / ϕ, 0, -ϕ],
        [-1 / ϕ, 0, ϕ],
        [-1 / ϕ, 0, -ϕ],
        [0, ϕ, 1 / ϕ],
        [0, ϕ, -1 / ϕ],
        [0, -ϕ, 1 / ϕ],
        [0, -ϕ, -1 / ϕ],
        [ϕ, 1 / ϕ, 0],
        [ϕ, -1 / ϕ, 0],
        [-ϕ, 1 / ϕ, 0],
        [-ϕ, -1 / ϕ, 0]
    ]

    return vertices
end

function dodecahedron_edges()::Vector{Tuple{Int,Int}}
    edges = [
        (1, 9)
        (1, 13)
        (1, 17)
        (2, 10)
        (2, 14)
        (2, 17)
        (3, 9)
        (3, 15)
        (3, 18)
        (4, 10)
        (4, 16)
        (4, 18)
        (5, 11)
        (5, 13)
        (5, 19)
        (6, 12)
        (6, 14)
        (6, 19)
        (7, 11)
        (7, 15)
        (7, 20)
        (8, 12)
        (8, 16)
        (8, 20)
        (9, 11)
        (10, 12)
        (13, 14)
        (15, 16)
        (17, 18)
        (19, 20)
    ]
    return edges
end

function dodecahedron_faces()::Vector{Vector{Int}}
    faces = [
        [1, 13, 14, 2, 17],
        [1, 17, 18, 3, 9],
        [1, 9, 11, 5, 13],
        [2, 14, 6, 12, 10],
        [2, 10, 4, 18, 17],
        [3, 18, 4, 16, 15],
        [3, 15, 7, 11, 9],
        [4, 10, 12, 8, 16],
        [5, 19, 6, 14, 13],
        [5, 11, 7, 20, 19],
        [6, 19, 20, 8, 12],
        [7, 15, 16, 8, 20]
    ]

    return faces
end

function plot_dodecahedron()
    vertices = dodecahedron_vertices()
    edges = dodecahedron_edges()
    faces = dodecahedron_faces()

    plot_3D_object(vertices, edges, faces)

end
