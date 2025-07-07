using GLMakie
using LinearAlgebra
using Printf

# Helper function for the selection menu
function get_platonic_solid(name::String)
    if name == "Tetrahedon"
        return tetrahedon_vertices(), tetrahedon_edges(), tetrahedon_faces()
    end

    if name == "Cube"
        return cube_vertices(), cube_edges(), cube_faces()
    end

    if name == "Dodecahedron"
        return dodecahedron_vertices(), dodecahedron_edges(), dodecahedron_faces()
    end

    if name == "Icosahedron"
        return icosahedron_vertices(), icosahedron_edges(), icosahedron_faces()
    end
end

# Rotate a set of 3-dimensional points around the origin by specifying yaw,pitch and roll as angles of rotation around the 3 main axis.
# For an explanation why we use Observables here, see the README
function rotate_vertices(vertices; yaw=Observable(0), pitch=Observable(0), roll=Observable(0))
    rotated_vertices = []

    for v in vertices
        # See the Makie section in the README, we lift the observables at the last moment
        # as to make the observables the innermost struct.
        # I.e. rotated_vertices is a vector of observables, not an observable vector.
        rotated_vertex = lift(yaw, pitch, roll) do yaw, pitch, roll
            α = deg2rad(yaw)
            β = deg2rad(pitch)
            γ = deg2rad(roll)

            # Matrices describing the rotations around the 3 main axis
            R_α = [cos(α) -sin(α) 0;
                sin(α) cos(α) 0;
                0 0 1]

            R_β = [cos(β) 0 sin(β);
                0 1 0;
                -sin(β) 0 cos(β)]

            R_γ = [1 0 0;
                0 cos(γ) -sin(γ);
                0 sin(γ) cos(γ)]

            s = R_α * R_β * R_γ * v
            return s
        end

        push!(rotated_vertices, rotated_vertex)
    end

    rotated_vertices
end

# Project a set of 3-dimensional points to 2-dimensional coordinates using a central 1-point projection.
# One can optionally specify the view point and view plane used for the projection
function project_to_2D(vertices, view_point=[0, 0, 10], view_plane=[[1, 0, -10], [0, 1, -10]])
    projected_vertices = []

    # The plane is now all points p for which (p - plane_basepoint) ⋅ plane_normal = 0
    plane_normal = [0, 0, 1]
    plane_basepoint = [0, 0, -10]

    for v in vertices

        # See the Makie section in the README, we lift the observables at the last moment
        # as to make the observables the innermost struct.
        # I.e. projected_vertices is a vector of observables, not an observable vector.
        projected_vertex = lift(v) do v

            # The ray is now v + x ⋅ direction_vector
            direction_vector = v - view_point

            # line-plane intersection: we substitute 'p' from above with the line equation v + x ⋅ direction_vector
            # ((v + x ⋅ direction_vector) - plane_basepoint) ⋅ plane_normal = 0
            # solving for x gives
            # x = ((plane_basepoint - v) ⋅ plane_normal) / (direction_vector ⋅ plane_normal)

            x = ((plane_basepoint - v) ⋅ plane_normal) / (direction_vector ⋅ plane_normal)

            projected_vertex = v + x * direction_vector

            (x=projected_vertex[1], y=projected_vertex[2])
        end


        push!(projected_vertices, projected_vertex)
    end
    return projected_vertices
end

# Given a 3-dimensional convex solid by their vertices, edges and faces,
# returns for each component a vector of booleans describing if that component is visible when view from the view point
function filter_visibles(vertices, edges, faces, view_point=[0, 0, 10])
    is_vertex_visible = fill(Observable(false), length(vertices))
    is_edge_visible = fill(Observable(false), length(edges))
    is_face_visible = []

    # Test for visibility of faces;
    # If the normal vector away from the center of the solid is in the same directional half plane as the vision vector, the face is visible
    # I.e. if the dot product is negative.
    # Informally, if the normal vector point in "roughly" same direction as the vision vector, it is not visible.
    # In order to get the normal vector that faces away from the center, the winding order of the vertices on the face is important,
    # this is given in my definitions but keep it in mind, when adding new solids
    for face_index in eachindex(faces)
        face = faces[face_index]

        # See the Makie section in the README, we lift the observables at the last moment
        # as to make the observables the innermost struct.
        # I.e. is_face_visible is a vector of observable booleans, not an observable vector of booleans.
        is_current_face_visible = lift(vertices[face[1]], vertices[face[2]], vertices[face[3]]) do v₁, v₂, v₃

            e₁ = v₂ - v₁
            e₂ = v₃ - v₁
            normal_vector = e₁ × e₂
            view_vector = view_point - v₁

            normal_vector ⋅ view_vector < 0
        end

        push!(is_face_visible, is_current_face_visible)
    end

    # Platonic solids are convex; all vertices on visible faces are themselves visible
    for face_index in eachindex(faces)
        for v in faces[face_index]
            is_vertex_visible[v] = lift((a, b) -> a || b, is_face_visible[face_index], is_vertex_visible[v])
        end
    end

    # Platonic solids are convex; edges bounding visible faces are visible
    # Importantly, only because it's endpoint are visible, does not mean the edge itself is visible
    for edge_index in eachindex(edges)
        (i, j) = edges[edge_index]
        for face_index in eachindex(faces)
            if issubset([i, j], faces[face_index])
                is_edge_visible[edge_index] = lift((a, b) -> a || b, is_face_visible[face_index], is_edge_visible[edge_index])
            end
        end
    end

    return is_vertex_visible, is_edge_visible, is_face_visible
end

function plot_platonic_solids(preset="Icosahedron")
    platonic_solid_name = preset
    vertices, edges, faces = get_platonic_solid(platonic_solid_name)

    GLMakie.activate!

    # The whole window
    figure = Figure(size=(1500, 1000))

    # The actual render
    axis = Axis(figure[1, 1]; limits=((-5, 5), (-5, 5)), aspect=DataAspect(), xrectzoom=false, yrectzoom=false)

    # The two sliders for rotating the solid
    slider_pitch = Slider(figure[2, 1], range=0:1:360, startvalue=0, linewidth=40)
    slider_roll = Slider(figure[1, 2], range=0:1:360, horizontal=false, startvalue=0, linewidth=40)

    # text element containing the list of visible vertices in the current frame
    visible_vertices_label = Observable("Visible Vertices:")
    Label(figure[1, 3][2, 1], visible_vertices_label, tellwidth=true, tellheight=false, fontsize=15, justification=:left, halign=:left, valign=:top, font="DejaVu Sans Mono", width=500)

    # text element containing the list of visible edges in the current frame
    visible_edges_label = Observable("Visible Edges:")
    Label(figure[1, 3][3, 1], visible_edges_label, tellwidth=true, tellheight=false, fontsize=15, justification=:left, halign=:left, valign=:top, font="DejaVu Sans Mono", width=500)

    # Whenever we change the platonic solid with the dropdown menu, we need to manually adjust certain observables,
    # we do this by calling this helper function that resets the axis element
    function plot_solid(vertices, edges, faces)
        empty!(axis)

        rotated_vertices = rotate_vertices(vertices, pitch=slider_pitch.value, roll=slider_roll.value)
        projected_vertices = project_to_2D(rotated_vertices)

        # calculate the lanes we want to draw by replacing an edge (i,j) with a pair ((x,y),(x,y)) describing the coordinates of start/end point
        projected_edges = []
        for (i, j) in edges
            edge = lift(projected_vertices[i], projected_vertices[j]) do pointA, pointB
                a = Point2f(pointA.x, pointA.y)
                b = Point2f(pointB.x, pointB.y)

                [a, b]
            end

            push!(projected_edges, edge)
        end

        is_vertex_visible, is_edge_visible, is_face_visible = filter_visibles(rotated_vertices, edges, faces)

        # Render the platonic solid by rendering the edges
        # We draw every edge but mark invisible edges as ... well ... invisible
        for edge_index in eachindex(projected_edges)
            lines!(projected_edges[edge_index], color=:black, visible=is_edge_visible[edge_index])

            # If you want to also see invisible edges, uncomment this line
            # lines!(projected_edges[edge_index], color=:grey, visible=lift(x -> !x, is_edge_visible[edge_index]))
        end

        # Display coordinates of visible vertices by conditionally adding their coordinates onto a label-string
        lift(is_vertex_visible..., projected_vertices...) do args...
            is_vertex_visible = args[1:length(vertices)]
            projected_vertices = args[length(vertices)+1:end]

            str = "Visible Vertices:\n"
            for i in eachindex(vertices)

                # Skip invisible vertices
                if is_vertex_visible[i]

                    # Pad all numbers to the same length with 3 decimal places
                    x = @sprintf("%6.3f", projected_vertices[i].x)
                    y = @sprintf("%6.3f", projected_vertices[i].y)

                    # Pad the index of the vertices to the same length
                    str *= @sprintf("%2d", i) * ": (" * x * " " * y * ")\n"
                end
            end

            # Adjusting the actual visible label
            visible_vertices_label[] = str
            notify(visible_vertices_label)
        end

        # Display visible edges by conditionally adding them onto a label-string
        lift(is_edge_visible...) do is_edge_visible...
            str = "Visible Edges:\n"
            for i in eachindex(edges)
                if is_edge_visible[i]
                    x = @sprintf("%2d", edges[i][1])
                    y = @sprintf("%2d", edges[i][2])
                    str *= "(" * x * "," * y * ")\n"
                end
            end

            # Adjusting the actual visible label
            visible_edges_label[] = str
            notify(visible_edges_label)
        end
    end

    # menu with which you can select a different platonic solid, calls the above helper function when changed
    menu = Menu(figure[1, 3][1, 1], options=["Tetrahedon", "Cube", "Dodecahedron", "Icosahedron"], default=platonic_solid_name)
    on(menu.selection) do solid
        vertices, edges, faces = get_platonic_solid(solid)

        plot_solid(vertices, edges, faces)
    end
    notify(menu.selection)

    display(figure)
end
