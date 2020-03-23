import Voronoi

using Random
using Printf
include("Draw.jl")


function randf(start, finish, n)
   v = rand(n)
   return map(x -> start + x*(finish-start), v)
end

function gradientDescent()
   WIDTH = 100.0
   HEIGHT = 100.0

   seed = 100
   println("Random seed: ", seed)
   Random.seed!(seed)

   command = nothing
   for n in 3:100
      if sqrt(n) == floor(sqrt(n))
         continue
      end
      points = convert(Array{Tuple{Real, Real}}, collect(zip(randf(1, WIDTH-1, n), randf(1, HEIGHT-1, n))))


      iterations = 1
      fortunes = 1

      time = @elapsed V, f, ∇f, ξ = Voronoi.Optimization.init(points, WIDTH, HEIGHT)

      μ = 0.5
      α = 0.01
      ϵ = 10^-1
      λ₀ = 0.01

      times = time

      while ξ > ϵ
         @printf("f = %.10g\t\t|∇f| = %.10g\t\ttime: %s seconds\n", f, ξ, time)
         Draw.init(WIDTH, HEIGHT)
         Draw.voronoiDiagram(V)

         d = ∇f

         time = @elapsed V, f, ∇f, ξ, forts = Voronoi.Optimization.lineSearch(points, d, α, λ₀, μ, ϵ, V, f, ∇f, ξ)

         times += time
         fortunes += forts
         iterations += 1

         if command != "a"
            println("Press Return for a step or enter \"a\" to animate until the end.")
            command = readline(stdin)
         else
            sleep(0.0000001) # make sure stuff is drawn
         end
      end

      println("n: ", n, "\t\titer: ", iterations, "\t\tfortunes: ", fortunes, "\t\ttime: ", times)
      #Draw.init(WIDTH, HEIGHT)
      #Draw.voronoiDiagram(V)
      #command = readline(stdin)
   end
end

gradientDescent()
