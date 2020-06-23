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

function intersectLine(box::Rectangle, agen::Tuple{Real, Real}, bgen::Tuple{Real, Real})
   center = ((agen[1] + bgen[1])/2, (agen[2] + bgen[2])/2)

   println("intersect_gens(", agen, ", ", bgen, ")")
   println("center: ", center)
   dir_gen = Geometry.rotateVectorCCW(Geometry.subVector(bgen, agen))

   b = Geometry.addVector(center, dir_gen)
   a = Geometry.subVector(center, dir_gen)

   dir = Geometry.subVector(b, a)
   println("dir_gen: ", dir_gen)
   println("dir: ", dir)
   
   if dir[1] == 0
      if !(0 <= a[1] <= box.w) # no intersection
          println("NOTHING, NOTHING da hora I")
         return nothing, nothing
      end

      if a[2] < b[2]
          println("CASE a")
         return (a[1], 0), (a[1], box.h)
      else
          println("CASE b")
         return (a[1], box.h), (a[1], 0)
      end
   elseif dir[2] == 0
      if !(0 <= a[2] <= box.h) # no intersection
          println("CASE c")
          println("NOTHING, NOTHING da hora II")
         return nothing, nothing
      end

      if a[1] < b[1]
          println("CASE d")
         return (0, a[2]), (box.w, a[2])
      else
          println("CASE e")
         return (box.w, a[2]), (0, a[2])
      end
   else
      # intersection points with each line that delimits the box
      l = (0, a[2] - (a[1])*(dir[2]/dir[1]))
      d = (a[1] - (a[2])*(dir[1]/dir[2]), 0)
      r = (box.w, a[2] - (a[1]-box.w)*(dir[2]/dir[1]))
      u = (a[1] - (a[2]-box.h)*(dir[1]/dir[2]), box.h)

      println("L: ", l)
      println("R: ", r)
      println("D: ", d)
      println("U: ", u)

      p = Array{Union{Tuple{Real, Real}, Nothing}, 1}([nothing, nothing])
      i = 1
      for q in [l, r, d, u]
         if inbounds(box, q)
            p[i] = q
            i += 1

            if i > 2
                break
            end
         end
      end

      println("P1: ", p[1])
      println("P2: ", p[2])

      if p[1] == nothing
          if p[2] == nothing
              println("CASE f")
          println("NOTHING, NOTHING da hora III")
              return nothing, nothing
          else
              println("p[2]")
              println("CASE g")
              return p[2], p[2]
          end
      elseif p[2] == nothing
          println("p[1]")
          println("CASE h")
          return p[1], p[1]
      end

      println("Caso normal.")

      if (a[1] < b[1] && p[1] < p[2]) || (a[1] > b[1] && p[1] > p[2])
          println("CASE i")
         return p[1], p[2]
      else
          println("CASE j")
         return p[2], p[1]
      end
   end
end

function intersectEdge(box::Rectangle, he::Diagram.HalfEdge)
   if he.origin == nothing
          println("NOTHING, NOTHING da hora IV")
      return nothing, nothing # no intersection
   end

   if !inbounds(box, he.origin) && !inbounds(box, he.twin.origin)
       if (he.origin[1] < 0 && he.twin.origin[1] < 0) ||
           (he.origin[1] > box.w && he.twin.origin[1] > box.w) ||
           (he.origin[2] < 0 && he.twin.origin[2] < 0) ||
           (he.origin[2] > box.h && he.twin.origin[2] > box.h)
           return nothing, nothing
       end
   end

   println("HE, HE.TWIN: ", he.origin, he.twin.origin)
   cp1, cp2 = intersectLine(box, he.generator, he.twin.generator)
   if cp1 == nothing
          println("NOTHING, NOTHING da hora V")
      return nothing, nothing # no intersection
   end

   if he.isFixed && inbounds(box, he.origin)
       ret1 = he.origin
   else
       ret1 = cp1
   end

   if he.twin.isFixed && inbounds(box, he.twin.origin)
       ret2 = he.twin.origin
   else
       ret2 = cp2
   end

   return ret1, ret2
   #println("cp1,2: ", cp1, ", ", cp2)

   ## calculate relative distance to cp1, using x if possible, y otherwise
   #dir = Geometry.subVector(cp2, cp1)
   #if dir[1] == 0
   #   p2 = cp2[2] - cp1[2]
   #   q1 = he.origin[2] - cp1[2]
   #   q2 = he.twin.origin[2] - cp1[2]
   #   if dir[2] < 0
   #      p2 *= -1
   #      q1 *= -1
   #      q2 *= -1
   #   end
   #else
   #   p2 = cp2[1] - cp1[1]
   #   q1 = he.origin[1] - cp1[1]
   #   q2 = he.twin.origin[1] - cp1[1]
   #   if dir[1] < 0
   #      p2 *= -1
   #      q1 *= -1
   #      q2 *= -1
   #   end
   #end

   #p1 = 0

   #if !he.isFixed
   #   q1 = -Inf
   #end

   #if !he.twin.isFixed
   #   q2 = Inf
   #end

   ##println(p1, ", ", p2)
   ##println(q1, ", ", q2)
   ##println()

   ## it's guaranteed by construction that p1 <= p2 and q1 <= q2

   #if q2 < p1 || p2 < q1
   #    println("NOTHING, NOTHING da hora VI p:(", p1, ",", p2, "); q:(", q1, ",", q2, ")")
   #    if q2 < p1
   #        println("da hora, q2 < p1")
   #    end
   #    if p2 < q1
   #        println("da hora, p2 < q1")
   #    end
   #   return nothing, nothing # no intersection
   #end

   #if p1 < q1 < p2
   #   ret1 = he.origin
   #else
   #   ret1 = cp1
   #end

   #if p1 < q2 < p2
   #   ret2 = he.twin.origin
   #else
   #   ret2 = cp2
   #end

   #println("ret1,2: ", ret1, ", ", ret2)
   #println("")
   #println("")
   #return ret1, ret2
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

function joinAround!(array::Array{Diagram.HalfEdge}, box::Rectangle, a::Diagram.HalfEdge, b::Diagram.HalfEdge)
   ao = a.origin
   bo = b.origin

   println("ORIGINS: ", ao, ", ", bo)

   if (ao[1] == bo[1] == 0 && ao[2] > bo[2]) ||
      (ao[1] == bo[1] == box.w && ao[2] < bo[2]) ||
      (ao[2] == bo[2] == 0 && ao[1] < bo[1]) ||
      (ao[2] == bo[2] == box.h && ao[1] > bo[1])
      Diagram.concat(a, b)
   else
      new = Diagram.HalfEdge(nextCorner(box, ao), false, nothing, nothing, nothing, a.origin)
      push!(array, new)
      Diagram.concat(a, new)
      return joinAround!(array, box, new, b)
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
         he = he.prev
      end

      region.borderHead = he

      println("\n\n\nregião da hora ###")
      while he.next != nothing && he.next != region.borderHead
          println("região da hora | ", he.origin, " -> ", he.twin.origin)
          he = he.next
      end
      println("região da hora | ", he.origin, " -> ", he.twin.origin)
      he = region.borderHead

      if !he.isFixed && !he.twin.isFixed # unlimited line
         p1, p2 = intersectLine(box, he.generator, he.twin.generator)
         he.origin = p1
         he.twin.origin = p2
         new = Diagram.HalfEdge(p2, false, nothing, nothing, nothing, he.origin)
         push!(V.halfEdges, new)
         Diagram.concat(he, new)
         println("AH! Vou joinzar ", he.origin)
         joinAround!(V.halfEdges, box, new, he)
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

         println("região CORTADINHA da hora ###")
         while he.next != nothing && he.next != region.borderHead
             println("região CORTADINHA da hora | ", he.origin, " -> ", he.twin.origin)
             he = he.next
         end
         println("região CORTADINHA da hora | ", he.origin, " -> ", he.twin.origin)
         he = region.borderHead

         while true
            while he.next.origin == nothing
               he.next = he.next.next
            end

            next = he.next

            if he.twin.origin != he.next.origin
               new = Diagram.HalfEdge(he.twin.origin, false, nothing, nothing, nothing, he.origin)
               push!(V.halfEdges, new)
               Diagram.concat(he, new)
               println("Vou joinzar ", he.origin, ", ", he.twin.origin)
               joinAround!(V.halfEdges, box, new, next)
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
