using GLMakie
using LinearAlgebra

# === Icosahedron vertices ===
function icosahedron_vertices()
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

function cube_vertices()
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

function cube_edges()
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

# === Edges of the icosahedron ===
function icosahedron_edges()
    vertices = icosahedron_vertices()

    edges = []

    for (i, start_vertex) in pairs(vertices)
        for (j, end_vertex) in pairs(vertices)

            dx = start_vertex[1] - end_vertex[1]
            dy = start_vertex[2] - end_vertex[2]
            dz = start_vertex[3] - end_vertex[3]
            distance = sqrt(dx^2 + dy^2 + dz^2)

            if round(distance) != 2
                continue
            end

            if distance != 2
                continue
            end

            if (i, j) in edges || (j, i) in edges
                continue
            end

            push!(edges, (i, j))
        end
    end
    println(length(edges))

    return edges
end

function project_vertices(vertices; azimuth=80, elevation=20)
    # Set up camera angles
    θ = deg2rad(azimuth)
    φ = deg2rad(elevation)

    # View matrix: simple orbital camera (yaw and pitch only)
    R = [cos(θ) 0 sin(θ);
        sin(φ)*sin(θ) cos(φ) -sin(φ)*cos(θ);
        -cos(φ)*sin(θ) sin(φ) cos(φ)*cos(θ)]

    projected = [R * v for v in vertices]
    return projected
end

function to_2d(projected)
    return [v[1:2] for v in projected]
end

# === Plot and output 2D projection ===
function plot_icosahedron()

    GLMakie.activate!

    fig = Figure(size=(1000, 1000))

    vertices = icosahedron_vertices()
    edges = icosahedron_edges()
    proj3d = project_vertices(vertices)
    proj2d = to_2d(proj3d)

    # Fix: Create figure and axis manually
    ax = Axis(fig[1, 1]; aspect=1)

    for (i, j) in edges
        p1 = proj2d[i]
        p2 = proj2d[j]
        lines!([p1[1], p2[1]], [p1[2], p2[2]], color=:black)
    end

    println(count)

    scatter!([v[1] for v in proj2d], [v[2] for v in proj2d], color=:red)
    #fig

    # Output vertex coordinates
    println("2D Projected Vertex Coordinates:")
    for (i, v) in enumerate(proj2d)
        println("v$i = ($(round(v[1], digits=3)), $(round(v[2], digits=3)))")
    end

    println("\nEdge List:")
    for (i, j) in edges
        println("v$i -- v$j")
    end

    display(fig)

    return fig
end

plot_icosahedron()
