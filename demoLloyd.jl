include("Geometry.jl")
include("Diagram.jl")
include("EventQueue.jl")
include("BeachLine.jl")
include("Fortune.jl")
include("Intersect.jl")
include("Optimization.jl")
include("Draw.jl")

#using Random


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
   for n in 3:100
      points = convert(Array{Tuple{Real, Real}}, collect(zip(randf(1, WIDTH-1, n), randf(1, HEIGHT-1, n))))
      if sqrt(n) == floor(sqrt(n))
         continue
      end
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

         V = Fortune.compute(points)

         Intersect.intersect(V, Intersect.Rectangle(WIDTH, HEIGHT))

         gradient = Optimization.∇f(V, points)
         println(Optimization.f(V), "\t\t\t", Optimization.norm2(gradient))

         Draw.init(WIDTH, HEIGHT)
         Draw.voronoiDiagram(V)

         points, areas = Diagram.centroidsAndAreas(V)

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
