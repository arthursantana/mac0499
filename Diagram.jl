module Diagram


abstract type halfEdge end # this hack is currently necessary for definition of circular types in Julia, see https://github.com/JuliaLang/julia/issues/269

mutable struct Region
   generator::Tuple{Real, Real}
   borderHead::Union{halfEdge, Nothing} # first half edge of the border; we can traverse the border with he = he.next;
end

mutable struct HalfEdge <: halfEdge
   origin::Union{Tuple{Real, Real}, Nothing}

   isFixed::Bool

   twin::Union{HalfEdge, Nothing}
   next::Union{HalfEdge, Nothing}
   prev::Union{HalfEdge, Nothing}

   generator::Tuple{Real, Real}
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

function DCEL(points::Array{Tuple{Real, Real}, 1})
	n = size(points)[1]

   regions = Array{Region}(undef, 1, n)
   for i in 1:n
      regions[i] = Region(points[i], nothing)
   end

   halfEdges = HalfEdge[]

	return DCEL(regions, halfEdges)
end


function borderCoordinates(f::Region)
   x = []
   y = []

   if f.borderHead == nothing
      return x, y
   end

   he = f.borderHead

   if he.origin != nothing
      append!(x, he.origin[1])
      append!(y, he.origin[2])
   end
   he = he.next

   i = 0
   while he != nothing && he != f.borderHead
      if he.origin != nothing
         append!(x, he.origin[1])
         append!(y, he.origin[2])
      end
      he = he.next
      i += 1
   end

   return x, y
end

function regionBorders(V::DCEL)
   borders = []

   for region in V.regions
      append!(borders, [borderCoordinates(region)])
   end

   return borders
end

function centroidAndArea(region::Region)
   A = Cx = Cy = 0

   he = region.borderHead
   while true
      shoelace = he.origin[1]*he.next.origin[2] - he.origin[2]*he.next.origin[1]
      A += shoelace
      Cx += (he.origin[1] + he.next.origin[1]) * shoelace
      Cy += (he.origin[2] + he.next.origin[2]) * shoelace

      he = he.next
      if he == region.borderHead
         break
      end
   end

   A /= 2
   Cx /= 6*A
   Cy /= 6*A

   return ((Cx, Cy), A)
end

function centroidsAndAreas(V::DCEL)
   centroids = Array{Tuple{Real, Real}, 1}([])
   areas = Array{Real, 1}([])
   for region in V.regions
      res = centroidAndArea(region)
      push!(centroids, (res[1]))
      push!(areas, (res[2]))
   end

   return centroids, areas
end


end # module
