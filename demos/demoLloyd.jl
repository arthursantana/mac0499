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
      #n = 55
      #points = convert(Array{Tuple{Real, Real}}, [(90.0, 90.0),# (80.0, 50), (70.0, 55.0), (30.0, 85.0), (30, 45), (35.0, 44.0),
      #                                            #(1, 90),
      #                                            #(5, 90), (10, 90), (15, 90),
      #                                            (10, 5), (10,10), (10, 20), (80, 20), (30, 20),
      #                                            (1, 1.1), (2, 1.2), (3, 1.3),
      #                                           ])
      #points = convert(Array{Tuple{Real, Real}}, [ (100*0.2219056800797507, 100*0.7000658172436546), (100*0.49169960385155936, 100*0.6636482987025588), (100*0.7618642131758435, 100*0.7432736698473899), (100*0.8846773855975993, 100*0.6317667493965284) ])

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

         V = Voronoi.Fortune.compute(points, WIDTH, HEIGHT)

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
