function octahedron_vertices()::Vector{Vector{Float64}}
    vertices = [
        [1,0,0],
        [-1,0,0],
        [0,1,0],
        [0,-1,0],
        [0,0,1],
        [0,0,-1]
    ]

    return vertices
end

function octahedron_edges()::Vector{Tuple{Int,Int}}
    edges = [
        (1,3),
        (1,4),
        (1,5),
        (1,6),
        (2,3),
        (2,4),
        (2,5),
        (2,6),
        (3,5),
        (3,6),
        (4,5),
        (4,6)
    ]
    return edges
end

function octahedron_faces()::Vector{Vector{Int}}
    faces = [
        [1,3,6],
        [1,6,4],
        [1,5,3],
        [1,4,5],
        [2,6,3],
        [2,4,6],
        [2,3,5],
        [2,5,4]
    ]

    return faces
end

function plot_octahedron()
    plot_platonic_solids("Octahedron")
end
