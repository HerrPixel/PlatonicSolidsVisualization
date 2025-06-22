using GLMakie
using LinearAlgebra

function rotate_vertices(vertices::Vector{Vector{Float64}}; yaw=0, pitch=0, roll=0)
    α = deg2rad(yaw)
    β = deg2rad(pitch)
    γ = deg2rad(roll)

    R_α = [cos(α) -sin(α) 0;
        sin(α) cos(α) 0;
        0 0 1]

    R_β = [cos(β) 0 sin(β);
        0 1 0;
        -sin(β) 0 cos(β)]

    R_γ = [1 0 0;
        0 cos(γ) -sin(γ);
        0 sin(γ) cos(γ)]

    rotated_vertices = [R_α * R_β * R_γ * v for v in vertices]

    return rotated_vertices
end

function project_to_2D(vertices::Vector{Vector{Float64}})
    projected_vertices = [v[1:2] for v in vertices]

    return projected_vertices
end

function plot_3D_object(vertices::Vector{Vector{Float64}}, edges::Vector{Tuple{Int,Int}})
    GLMakie.activate!

    figure = Figure()

    projected_vertices = project_to_2D(rotate_vertices(vertices))

    axis = Axis(figure[1, 1])

    for (i, j) in edges
        p1 = projected_vertices[i]
        p2 = projected_vertices[j]

        lines!([p1[1], p2[1]], [p1[2], p2[2]], color=:black)
    end

    display(figure)
end
