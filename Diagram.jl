module Diagram


abstract type halfEdge end # this hack is currently necessary for definition of circular types in Julia, see https://github.com/JuliaLang/julia/issues/269

mutable struct Region
   generator::Tuple{Number, Number}
   borderHead::Union{halfEdge, Void} # first half edge of the border; we can traverse the border with he = he.next;
end

mutable struct HalfEdge <: halfEdge
   origin::Tuple{Number, Number}

   #incidentRegion::Union{Region, Void}

   twin::Union{HalfEdge, Void}
   next::Union{HalfEdge, Void}
   prev::Union{HalfEdge, Void}
end

function makeTwins(a::HalfEdge, b::HalfEdge)
   a.twin = b
   b.twin = a
end

function concat(a::HalfEdge, b::HalfEdge)
   a.next = b
   b.prev = a
end


mutable struct DCEL # Doubly-connected edge list
   regions::Array{Region}
   halfEdges::Array{HalfEdge}
end

function DCEL(points::Array{Tuple{Number, Number}, 1})
	n = size(points)[1]

   regions = Array{Region}(1, n)
   for i in 1:n
      regions[i] = Region(points[i], nothing)
   end

   halfEdges = HalfEdge[]

	return Diagram.DCEL(regions, halfEdges)
end


function borderCoordinates(f::Region)
   x = []
   y = []

   if f.borderHead == nothing
      return x, y
   end

   he = f.borderHead

   append!(x, he.origin[1])
   append!(y, he.origin[2])
   he = he.next

   i = 0
   while he != nothing && he != f.borderHead
      append!(x, he.origin[1])
      append!(y, he.origin[2])
      he = he.next
      i += 1
   end

   return x, y
end

function regionBorders(l::DCEL)
   borders = []

   for region in l.regions
      append!(borders, [borderCoordinates(region)])
   end

   return borders
end


export DCEL
export HalfEdge
export Region
export regions
export makeTwins
export concat


end # module
