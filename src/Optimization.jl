module Optimization

using ..Diagram
using ..Fortune
using ..Intersect


pointsₖ = nothing # temporary points array for backtracking

function norm2(v)
   sum = 0

   for vᵢ in v
      sum += vᵢ[1]^2 + vᵢ[2]^2
   end

   return sum
end

function normInf(v)
   max = 0

   for vᵢ in v
      if (vᵢ[1]^2) > max
         max = vᵢ[1]^2
      end
      if (vᵢ[2]^2) > max
         max = vᵢ[2]^2
      end
   end

   return max
end

function errorInTriangle(z, a, b)
   p = [a[1] - z[1], a[2] - z[2]]
   q = [b[1] - z[1], b[2] - z[2]]

   jacobian = abs(p[1]q[2] - p[2]q[1])

   # error = c∫∫x² + y² dudv, see the monograph appendix for a derivation
   # u and v are variables such that Triangle(x,y) -> Triangle(u,v) right triangle with catheti of size 1
   # c is just so that I can take the common factor 1/12 out of both integrals and multiply once

   c∫x²dudv = p[1]^2 + q[1]^2 + p[1]*q[1]
   c∫y²dudv = p[2]^2 + q[2]^2 + p[2]*q[2]

   return jacobian * ((c∫x²dudv + c∫y²dudv) / 12) # testing with area
end

function errorInRegion(region::Diagram.Region)
   z = region.generator

   edge = region.borderHead

   sum = errorInTriangle(z, edge.origin, edge.next.origin)
   edge = edge.next
   while edge != region.borderHead
      sum += errorInTriangle(z, edge.origin, edge.next.origin)
      edge = edge.next
   end

   return sum
end

function defaultf(V::Diagram.DCEL)
   sum = 0
   for region in V.regions
      sum += errorInRegion(region)
   end

   return sum
end

function default∇f(V::Diagram.DCEL, points::Array{Tuple{Real, Real}, 1})
   function weightedDifference(a::Array{Tuple{Real, Real}, 1}, b::Array{Tuple{Real, Real}, 1}, c::Array{Real, 1})
      r = Array{Tuple{Real, Real}}([])

      for i in 1:size(a)[1]
         push!(r, (c[i]*(a[i][1] - b[i][1]), c[i]*(a[i][2] - b[i][2])))
      end

      return r
   end

   centroids, areas = Diagram.centroidsAndAreas(V)

   return weightedDifference(points, centroids, areas)
end

function modf(V::Diagram.DCEL)
   function g(V)
   end

   return defaultf(V) + g(V)
end

function mod∇f(V::Diagram.DCEL, points::Array{Tuple{Real, Real}, 1})
   function ∇g(V, points)
   end

   return default∇f(V, points) + ∇g(V, points)
end

function f(V::Diagram.DCEL)
   return defaultf(V)
end

function ∇f(V::Diagram.DCEL, points::Array{Tuple{Real, Real}, 1})
   return default∇f(V, points)
end

function init(points::Array{Tuple{Real, Real}, 1}, w::Number, h::Number)
   global WIDTH, HEIGHT, pointsₖ

   WIDTH = w
   HEIGHT = h
   pointsₖ = deepcopy(points)

   V = Fortune.compute(points, w, h)
   Intersect.intersect(V, Intersect.Rectangle(WIDTH, HEIGHT))

   f = Optimization.f(V)
   ∇f = Optimization.∇f(V, points)
   ξ = Optimization.normInf(∇f)

   return V, f, ∇f, ξ
end

function lloydIteration(points::Array{Tuple{Real, Real}, 1}, V::Diagram.DCEL)
   points, areas = Diagram.centroidsAndAreas(V)

   V = Fortune.compute(points)
   Intersect.intersect(V, Intersect.Rectangle(WIDTH, HEIGHT))

   f = Optimization.f(V)
   ∇f = Optimization.∇f(V, points)
   ξ = Optimization.normInf(∇f)

   return V, f, ξ
end

function lineSearch(points::Array{Tuple{Real, Real}, 1}, d::Array{Tuple{Real, Real}, 1}, α::Number, λ₀::Number, μ::Number, ϵ::Number, V::Diagram.DCEL, f::Number, ∇f::Array{Tuple{Real, Real}, 1}, ξ)
   global WIDTH, HEIGHT, pointsₖ

   evaluations = 0

   n = size(points)[1]

   # backtracking
   λ = λ₀
   while true
      outOfBounds = false

      for i in 1:n
         x = points[i][1] - λ*d[i][1]
         y = points[i][2] - λ*d[i][2]

         if !(0 <= x <= WIDTH && 0 <= y <= HEIGHT)
            outOfBounds = true

            break
         end

         pointsₖ[i] = (x, y)
      end

      dᵗ∇f = 0
      if outOfBounds
         fₖ = Inf
         ∇fₖ = Inf
         ξₖ = Inf
         V = nothing
      else
         Vₖ = Fortune.compute(pointsₖ)
         Intersect.intersect(Vₖ, Intersect.Rectangle(WIDTH, HEIGHT))
         evaluations += 1

         fₖ = Optimization.f(Vₖ)
         ∇fₖ = Optimization.∇f(Vₖ, pointsₖ)
         ξₖ = Optimization.normInf(∇fₖ)

         for i in 1:n
            dᵗ∇f += d[i][1]*∇f[i][1]
            dᵗ∇f += d[i][2]*∇f[i][2]
         end
      end

      #println("fₖ = ", fₖ, "\t\tf = ", f, "\t\tλ = ", λ, "\t\tξₖ = ", ξₖ)
      # armijo's condition || failsafes
      if fₖ < f - α*λ*dᵗ∇f || ξₖ <= ϵ || λ == 0
         for i in 1:n
            points[i] = pointsₖ[i]
         end

         V = Vₖ
         f = fₖ
         ∇f = ∇fₖ
         ξ = ξₖ
         break
      else
         old = λ
         λ *= μ
         if old == λ
            ξ = ϵ
            break
         end
      end
   end

   return V, f, ∇f, ξ, evaluations
end

end # module
