import Voronoi

using Random
include("Draw.jl")


function randf(start, finish, n)
   v = rand(n)
   return map(x -> start + x*(finish-start), v)
end

function demoFortune()
   WIDTH = 100.0
   HEIGHT = 100.0
   n = 2
   for i in 1:1000
      #println("Random seed: ", i)
      #Random.seed!(i)
      points = convert(Array{Tuple{Real, Real}}, collect(zip(randf(1, WIDTH-1, n), randf(1, HEIGHT-1, n))))
      #points = convert(Array{Tuple{Real, Real}}, [(90.0, 90.0), (90.0, 50), (90, 30)])
      #points = convert(Array{Tuple{Real, Real}}, [(90.0, 90.0),# (80.0, 50), (70.0, 55.0), (30.0, 85.0), (30, 45), (35.0, 44.0),
      #                                            #(1, 90),
      #                                            (5, 90), (10, 90), (15, 90),
      #                                            (10, 55), (10,60), (10, 20), (80, 20), (30, 20),
      #                                            (1, 1.1), (2, 1.2), (3, 1.3),
      #                                           ])

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

      V, T, Q = Voronoi.Fortune.init(points)
      command = nothing
      ly = HEIGHT
      Draw.init(WIDTH, HEIGHT)

      while (event = Voronoi.EventQueue.pop(Q)) != nothing
         Voronoi.Fortune.handleEvent(V, T, Q, event) # multiple dispatch decides if it's a site event or circle event

         ly = Voronoi.EventQueue.coordinates(event)[2] # sweep line height
         Draw.fortuneIteration(V, T, Q, points, ly)
         if command != "a"
            println("Press Return for a step or enter \"a\" to animate until the end.")
            command = readline(stdin)
         else
            sleep(0.001)
         end
      end

      Voronoi.Intersect.intersect(V, Voronoi.Intersect.Rectangle(WIDTH, HEIGHT))
      Draw.init(WIDTH, HEIGHT)
      Draw.voronoiDiagram(V)

      println("Press Return to finish.")
      readline(stdin)
      n += 1
   end
end

demoFortune()
