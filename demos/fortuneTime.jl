import Voronoi

using Random
using Printf
include("Draw.jl")



function randf(start, finish, n)
   v = rand(n)
   return map(x -> start + x*(finish-start), v)
end
Random.seed!(100)

WIDTH = 100.0
HEIGHT = 100.0

function fortuneTime()
   global WIDTH, HEIGHT

   ns = Array{Number}([])
   times = Array{Number}([])

   # heating up cache or whatever
   n =100
   for i in 1:10
      points = convert(Array{Tuple{Real, Real}}, collect(zip(randf(1, WIDTH-1, n), randf(1, HEIGHT-1, n))))
      Voronoi.Fortune.compute(points)
   end
   
   for n in 3:10000
      println(n)
      if sqrt(n) == floor(sqrt(n))
         continue
      end

      points = convert(Array{Tuple{Real, Real}}, collect(zip(randf(1, WIDTH-1, n), randf(1, HEIGHT-1, n))))
      time = @elapsed Voronoi.Fortune.compute(points)

      push!(ns, n)
      push!(times, time)
   end

   println(ns, times)
   Draw.init(0, 0)
   Draw.clear("")
   Draw.plot(ns, times, "xkcd:azure", "", "-")
   Draw.legend("Número de Pontos Geradores", "Tempo (s)")
   Draw.commit()
   println("Press Return to finish.")
   command = readline(stdin)
end

fortuneTime()
