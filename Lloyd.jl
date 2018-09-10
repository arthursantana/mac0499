module Lloyd


using ..Diagram


function centroidAndArea(region::Diagram.Region)
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

function centroidsAndAreas(V::Diagram.DCEL)
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
