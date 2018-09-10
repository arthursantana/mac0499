module Intersect


using ..Geometry
using ..Diagram


mutable struct Rectangle
   w::Real
   h::Real
end

function inbounds(box::Rectangle, p::Tuple{Real, Real})
   return (0 <= p[1] <= box.w) && (0 <= p[2] <= box.h)
end

function intersectLine(box::Rectangle, a::Tuple{Real, Real}, b::Tuple{Real, Real})
   dir = Geometry.subVector(b, a)
   
   if dir[1] == 0
      if !(0 <= a[1] <= box.w) # no intersection
         return nothing, nothing
      end

      if a[2] < b[2]
         return (a[1], 0), (a[1], box.h)
      else
         return (0, a[1]), (box.h, a[1])
      end
   elseif dir[2] == 0
      if !(0 <= a[2] <= box.h) # no intersection
         return nothing, nothing
      end

      if a[1] < b[1]
         return (0, a[2]), (box.w, a[2])
      else
         return (box.w, a[2]), (0, a[2])
      end
   else
      # intersection points with each line that delimits the box
      l = (0, a[2] - (a[1])*(dir[2]/dir[1]))
      d = (a[1] - (a[2])*(dir[1]/dir[2]), 0)
      r = (box.w, a[2] - (a[1]-box.w)*(dir[2]/dir[1]))
      u = (a[1] - (a[2]-box.h)*(dir[1]/dir[2]), box.h)

      p = Array{Union{Tuple{Real, Real}, Nothing}, 1}([nothing, nothing])
      i = 1
      for q in [l, d, r, u]
         if inbounds(box, q)
            p[i] = q
            i += 1
         end
      end

      if (a[1] < b[1] && p[1] < p[2]) || (a[1] > b[1] && p[1] > p[2])
         return p[1], p[2]
      else
         return p[2], p[1]
      end
   end
end

function intersectEdge(box::Rectangle, he::Diagram.HalfEdge)
   if he.origin == nothing
      return nothing, nothing # no intersection
   end

   cp1, cp2 = intersectLine(box, he.origin, he.twin.origin)
   if cp1 == nothing
      return nothing, nothing # no intersection
   end

   # calculate relative distance to p1, using x if possible, y otherwise
   dir = Geometry.subVector(cp2, cp1)
   if dir[1] == 0
      p2 = cp2[2] - cp1[2]
      q1 = he.origin[2] - cp1[2]
      q2 = he.twin.origin[2] - cp1[2]
   else
      p2 = cp2[1] - cp1[1]
      q1 = he.origin[1] - cp1[1]
      q2 = he.twin.origin[1] - cp1[1]
      if dir[1] < 0
         p2 *= -1
         q1 *= -1
         q2 *= -1
      end
   end

   p1 = 0

   if !he.isFixed
      q1 = -Inf
   end

   if !he.twin.isFixed
      q2 = Inf
   end

   #println(p1, ", ", p2)
   #println(q1, ", ", q2)
   #println()

   # it's guaranteed by construction that p1 < p2 and q1 < q2
   if q2 < p1 || p2 < q1
      return nothing, nothing # no intersection
   end

   if p1 < q1 < p2
      ret1 = he.origin
   else
      ret1 = cp1
   end

   if p1 < q2 < p2
      ret2 = he.twin.origin
   else
      ret2 = cp2
   end

   return ret1, ret2
end

function nextCorner(box::Rectangle, p::Tuple{Real, Real})
   if p[1] == 0 && p[2] > 0
      return (0, 0)
   elseif p[2] == 0 && p[1] < box.w
      return (box.w, 0)
   elseif p[1] == box.w && p[2] < box.h
      return (box.w, box.h)
   else
      return (0, box.h)
   end
end

function join!(array::Array{Diagram.HalfEdge}, box::Rectangle, a::Diagram.HalfEdge, b::Diagram.HalfEdge)
   ao = a.origin
   bo = b.origin

   if (ao[1] == bo[1] == 0 && ao[2] > bo[2]) ||
      (ao[1] == bo[1] == box.w && ao[2] < bo[2]) ||
      (ao[2] == bo[2] == 0 && ao[1] < bo[1]) ||
      (ao[2] == bo[2] == box.h && ao[1] > bo[1])
      Diagram.concat(a, b)
   else
      new = Diagram.HalfEdge(nextCorner(box, ao), false, nothing, nothing, nothing)
      push!(array, new)
      Diagram.concat(a, new)
      return join!(array, box, new, b)
   end
end

function intersect(V::Diagram.DCEL, box::Rectangle)
   for region in V.regions
      he = region.borderHead

      # find the "leftmost" edge in the region, or determine that it's closed
      while he.isFixed && he.prev != region.borderHead
         he = he.prev
      end

      if he.prev == region.borderHead
         he = he.prev
      end

      region.borderHead = he

      if !he.isFixed && !he.twin.isFixed # unlimited line
         p1, p2 = intersectLine(box, he.origin, he.twin.origin)
         he.origin = p1
         he.twin.origin = p2
         new = Diagram.HalfEdge(p2, false, nothing, nothing, nothing)
         push!(V.halfEdges, new)
         Diagram.concat(he, new)
         join!(V.halfEdges, box, new, he)
      else
         while true
            he.origin, he.twin.origin = intersectEdge(box, he)

            if he.next == nothing
               he.next = region.borderHead
            end

            he = he.next
            if he == region.borderHead
               break
            end
         end

         while he.origin == nothing
            he = he.next
         end
         region.borderHead = he

         while true
            while he.next.origin == nothing
               he.next = he.next.next
            end

            next = he.next

            if he.twin.origin != he.next.origin
               new = Diagram.HalfEdge(he.twin.origin, false, nothing, nothing, nothing)
               push!(V.halfEdges, new)
               Diagram.concat(he, new)
               join!(V.halfEdges, box, new, next)
            end

            he = next
            if he == region.borderHead
               break
            end
         end
      end
   end
end


end # module
