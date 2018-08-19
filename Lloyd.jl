module Lloyd


using Diagram


function centroid(region::Diagram.Region)
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

   return (Cx, Cy)
end

function centroids(V::Diagram.DCEL)
   array = Array{Tuple{Number, Number}, 1}([])
   for region in V.regions
      push!(array, centroid(region))
   end

   return array
end


end # module
