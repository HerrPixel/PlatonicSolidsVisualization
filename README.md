# Platonic Solid Visualization

3D interactive visualization for the five platonic solids.

![Visualization screenshot](https://github.com/user-attachments/assets/c88b25d0-891f-42d0-bff5-92049da6f574)

This project is a simple visualizer for the platonic solids, used for choosing an aesthetically pleasing viewing angle and projection. I used this for a graphic design project and didn't want to leave a dirty codebase so I created this.

## How to Use

Clone the repo and install Julia.

You then need to instantiate the project to set up the environment and download all dependencies:

```bash
$ julia --project=.

julia>

# Press ] to get into pkg

(PlatonicSolidsVisualization) pkg> instantiate
```

You only need to do this once in the beginning. You can then import the module and just run the specific functions:

```bash
$ julia --project=.

julia> using PlatonicSolidsVisualization

# You can preset specific platonic solids

julia> plot_cube()

# Or just call the general function

julia> plot_platonic_solids()
```

## How it works

We encode each platonic solid via a list of coordinates of its vertices (all platonic solids have some nice regular cartesian coordinates), a list of edges as indices of the corresponding vertices, and a list of faces in clockwise winding order, again as indices of its corresponding vertices.

For example, a cube has vertices:

```math
\begin{bmatrix} 1 \\ 1 \\ 1 \end{bmatrix}
\begin{bmatrix} 1 \\ 1 \\ -1 \end{bmatrix}
\begin{bmatrix} 1 \\ -1 \\ 1 \end{bmatrix}
\begin{bmatrix} 1 \\ -1 \\ -1 \end{bmatrix}
\begin{bmatrix} -1 \\ 1 \\ 1 \end{bmatrix}
\begin{bmatrix} -1 \\ 1 \\ -1 \end{bmatrix}
\begin{bmatrix} -1 \\ -1 \\ 1 \end{bmatrix}
\begin{bmatrix} -1 \\ -1 \\ -1 \end{bmatrix}
```

with edges

```math
(1, 2), (1, 3), (1, 5), (2, 4), (2, 6), (3, 4), (3, 7), (4, 8), (5, 6), (5, 7), (6, 8), (7, 8)
```

and faces

```math
(1,2,4,3), (1,5,6,2), (1,3,7,5), (2,6,8,4), (3,4,8,7), (5,7,8,6)
```

We then get rotation angles by the value of the interactive sliders and rotate the whole solid around the origin by using matrix-vector-multiplication with rotational matrices for rotations around the tree main axis in ℝ³.

Using $\alpha$, $\beta$ and $\gamma$ as the angles of rotation, the three rotational matrices are

```math
\begin{bmatrix} \cos(\alpha) & -\sin(\alpha) & 0 \\ \sin(\alpha) & \cos(\alpha) & 0  \\ 0 & 0 & 1 \end{bmatrix},
\begin{bmatrix} \cos(\beta) & 0 & \sin(\beta) \\ 0 & 1 & 0 \\ -\sin(\beta) & 0 & \cos(\beta) \end{bmatrix},
\begin{bmatrix} 1 & 0 & 0 \\ 0 & \cos(\gamma) & -\sin(\gamma) \\ 0 & \sin(\gamma) & \cos(\gamma) \end{bmatrix},
```

Calculating the visible vertices, edges and faces is done by looking at the normal vector of faces. To determine if an edge is visible, see if any of its two faces are visible. To determine if a vertex is visible, see if it is part of any visible face. To see if a face is visible, calculate its normal vector outwards (if you are using the correct winding order, you can do this by calculating the cross product of two consecutive edge vectors of this face). Now if this normal vector has a positive dot product (i.e. is facing in "roughly" the same direction) with the view vector from which you are looking at the figure, the face is **not** visible. If it instead has a negative dot product, the face is roughly "looking" at the view vector and is therefore visible.

Finally, we calculate a 2D-projection by using a view plane onto which we project and view point from which we look at the solid and trace every vertex (and therefore also faces and vertices) onto the plane.

For each vertex we do this by first calculating a line given by the view point and this vertex and calculate its intersection with the view plane. If $v$ is our vertex, $direction$ is the vector of the view point <-> vertex line, $basepoint$ is any point on the view plane and $normal$ is the normal vector of the view plane, this intersecting point can be calculated by:

Basic line-plane intersection: $z$ is on the plane if

$$(z - basepoint) \cdot normal = 0$$

Substituting $z$ with our line gives:

$$((v + x \cdot direction) - basepoint) \cdot normal = 0$$

Solving for $x$:

$$x = \frac{(basepoint - v) \cdot normal}{direction \cdot normal}$$

Finally, the intersection point $p$ is:

$$p = v + x \cdot direction$$

We then have projected 2D-coordinates of our vertices and can selectively only render the visible vertices, edges, faces.

## Some comments about the code and Makie.jl

This project uses [Makie.jl]("https://docs.makie.org/stable/"), a Julia library for data visualizations and plotting. The library is not specially suited for making such interactive plots, even though it has support for it. Therefore the performance might not be optimal when changing view angles or switching platonic solids and such.

The way Makie realizes this interactiveness is with Observables, plotted variables that change their value depending on the state of interactive elements like sliders or menus. Instead of calling the plotting function again on every change, these observables trace every source and functions they go through and reevaluate themselves when something changed. This means that the code must support these reevaluations and since the Observable type is very generic, it does not support most julia interfaces like being iterable.

This restricts the code one can write while using Observables. You can see this in many places in this codebase, here are some examples:

```julia
function example_where the observable_is_not_iterable(a)
    return lift(a) do a
        a^2, a + 2, a * 2
    end
end
```

When your return types depend on an observable, you will lift it in your function. If you this not multiple times with the innermost return types but instead once in the main function body, you return type will be `Observable{Any}`, which is normally not iterable. This is annoying when you will always return three values that are observables. For example, this function will return `Observable{Tuple{...}}` instead of `Tuple{Observable{...},Observable{...},Observable{...}}` so you cannot destructure the return of this function.

```julia
function example_with_optional_arguments(a=Observable(10))
    return lift(x -> x^2,a)
end
```

When a function has some optional arguments and if you might pass Observables to them, you need the default value to also be observables, since otherwise the lift function has some weird behaviour (it cannot lift integral type values).

In general, in this codebase, we have often opted to lift Observables multiple types in a function in order to have a type of `Vector{Observable{...}}` instead of `Observable{Vector{...}}`. In order to be able to iterate over them.

For static visualizations or less dynamic settings, Makie is probably excellent but these Observables-shenanigans have taught me that this approach is not best suited for these more complicated interactive visualizations.
