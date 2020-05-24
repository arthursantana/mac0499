import Voronoi

#using Random
include("Draw.jl")


function randf(start, finish, n)
   v = rand(n)
   return map(x -> start + x*(finish-start), v)
end

function demoLloyd()
   WIDTH = 100.0
   HEIGHT = 100.0
   #n = 10

   #seed = 100
   #println("Random seed: ", seed)
   #Random.seed!(seed)

   command = nothing
   for n in 2:100
      points = convert(Array{Tuple{Real, Real}}, collect(zip(randf(1, WIDTH-1, n), randf(1, HEIGHT-1, n))))
      max = 20*n
      if max > 100
         max = 100
      end
      for i in 1:max
         # test for repeated points
         repeat = false
         for i in 1:length(points)
            for j in 1:length(points)
               if j == i
                  continue
               end

               if points[i][1] == points[j][1] && points[i][2] == points[j][2]
                  repeat = true
               end
            end
         end
         if repeat
            println("REPEATED POINTS!")
            continue
         end

         V = Voronoi.Fortune.compute(points)

         Voronoi.Intersect.intersect(V, Voronoi.Intersect.Rectangle(WIDTH, HEIGHT))

         gradient = Voronoi.Optimization.∇f(V, points)
         println(Voronoi.Optimization.f(V), "\t\t\t", Voronoi.Optimization.norm2(gradient))

         Draw.init(WIDTH, HEIGHT)
         Draw.voronoiDiagram(V)

         points, areas = Voronoi.Diagram.centroidsAndAreas(V)

         if command != "a"
            println("Press Return for a step or enter \"a\" to animate until the end.")
            command = readline(stdin)
         else
            sleep(0.0000001) # make sure stuff is drawn
         end
         n += 1
      end
   end
end

demoLloyd()
