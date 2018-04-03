module DCEL # Doubly-connected edge list


abstract type halfEdge end # this hack is currently necessary for definition of circular types in Julia, see https://github.com/JuliaLang/julia/issues/269

mutable struct Face
   border::Union{halfEdge, Void} # first half edge of the border; we can traverse the border with he = he.next;
end

mutable struct HalfEdge <: halfEdge
   origin::Tuple{Number, Number}

   incidentFace::Union{Face, Void}

   twin::Union{HalfEdge, Void}
   next::Union{HalfEdge, Void}
   prev::Union{HalfEdge, Void}
end

mutable struct List
   faces::Array{Face}
   halfEdges::Array{HalfEdge}
end


function borderCoordinates(f::Face)
   x = []
   y = []

   if f.border == nothing
      return x, y
   end

   he = f.border

   append!(x, he.origin[1])
   append!(y, he.origin[2])
   he = he.next

   while he != f.border
      append!(x, he.origin[1])
      append!(y, he.origin[2])
      he = he.next
   end

   return x, y
end

function regions(l::List)
   borders = []

   for face in l.faces
      append!(borders, [borderCoordinates(face)])
   end

   return borders
end

export List
export HalfEdge
export Face
export regions


end # module
