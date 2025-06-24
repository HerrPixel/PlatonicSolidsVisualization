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

#function filter_visible_vertices(vertices::Vector{Vector{Float64}},vision_vector::Vector{Float64},faces::Vector{Vector{Int}})
function filter_visible_vertices(vertices, vision_vector, faces)
    is_vertex_visible = similar(vertices, Bool)

    # keep the winding order of the faces in mind!

    for face in faces
        is_visible = true

        v₁ = vertices[face[1]]
        v₂ = vertices[face[2]]
        v₃ = vertices[face[3]]

        e₁ = v₂ - v₁
        e₂ = v₃ - v₁
        normal_vector = e₁ × e₂ 

        # face is not visible
        if normal_vector ⋅ vision_vector < 0
            is_visible = false
        end

        for v in face
            is_vertex_visible[v] = is_vertex_visible[v] || is_visible
        end
    end

    return is_vertex_visible
    end

function filter_visible_faces(vertices, faces; vision_vector=[0, 0, 1])
    is_face_visible = similar(faces, Bool)

    for face_index in eachindex(faces)
        face = faces[face_index]
        is_visible = true

        v₁ = vertices[face[1]]
        v₂ = vertices[face[2]]
        v₃ = vertices[face[3]]

        e₁ = v₂ - v₁
        e₂ = v₃ - v₁
        normal_vector = e₁ × e₂

        is_face_visible[face_index] = normal_vector ⋅ vision_vector < 0

    end

    return is_face_visible
end

function project_to_2D(vertices::Vector{Vector{Float64}})
    projected_vertices = [(x=v[1],y=v[2]) for v in vertices]

    return projected_vertices
end

function plot_3D_object(vertices::Vector{Vector{Float64}}, edges::Vector{Tuple{Int,Int}},faces::Vector{Vector{Int}})
    GLMakie.activate!

    figure = Figure()

    axis = Axis(figure[1, 1]; aspect=DataAspect())

    slider_pitch = Slider(figure[2, 1], range=0:1:360, startvalue=0)
    slider_roll = Slider(figure[1,2], range=0:1:360, horizontal=false,startvalue=0)

    projected_vertices = lift(slider_pitch.value, slider_roll.value) do pitch, roll
        project_to_2D(rotate_vertices(vertices, pitch=pitch, roll=roll))
    end

    visible_vertices = lift(slider_pitch.value, slider_roll.value) do pitch, roll
        filter_visible_vertices(rotate_vertices(vertices,pitch=pitch,roll=roll),[0,0,1],faces)
    end

    projected_edges = []

    for (i, j) in edges
        edge = lift(projected_vertices) do vertices
            a = Point2f(vertices[i].x, vertices[i].y)
            b = Point2f(vertices[j].x, vertices[j].y)

                [a, b]
        end

        push!(projected_edges, edge)
    end

    is_vertex_visible = lift(slider_pitch.value, slider_roll.value) do pitch, roll
        filter_visible_vertices(rotate_vertices(vertices, pitch=pitch, roll=roll), [0, 0, 1], faces)
    end

    is_face_visible = lift(slider_pitch.value, slider_roll.value) do pitch, roll
        filter_visible_faces(rotate_vertices(vertices, pitch=pitch, roll=roll), faces)
    end

    is_edge_visible = []

    for (i, j) in edges
        is_curr_edge_visible = lift(is_face_visible) do is_face_visible
            face_indices = []

            for face_index in eachindex(faces)
                f = faces[face_index]
                if issubset([i, j], f) && is_face_visible[face_index]
                    return true
                end
            end

            return false
        end

        push!(is_edge_visible, is_curr_edge_visible)
    end

    for edge_index in eachindex(projected_edges)
        lines!(projected_edges[edge_index], color=:black, visible=is_edge_visible[edge_index])
    end

    display(figure)
end
