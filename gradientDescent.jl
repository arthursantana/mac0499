include("Geometry.jl")
include("Diagram.jl")
include("EventQueue.jl")
include("BeachLine.jl")
include("Fortune.jl")
include("Intersect.jl")
include("Lloyd.jl")
include("Draw.jl")

#using Random

function randf(start, finish, n)
   v = rand(n)
   return map(x -> start + x*(finish-start), v)
end

function gradientDescent()
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
         #points = convert(Array{Tuple{Real, Real}}, [(10,90), (10,70)])
         #points = convert(Array{Tuple{Real, Real}}, [(10,90), (20,80), (30,70)])
         #println(points)

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
         else
         end

         V, T, Q = Fortune.init(points)

         ly = HEIGHT
         while (event = EventQueue.pop(Q)) != nothing
            Fortune.handleEvent(V, T, Q, event) # multiple dispatch decides if it's a site event or circle event

            ly = EventQueue.coordinates(event)[2] # sweep line height
         end
         Intersect.intersect(V, Intersect.Rectangle(WIDTH, HEIGHT))
         centroids, areas = Lloyd.centroidsAndAreas(V)

         function weightedDifference(a::Array{Tuple{Real, Real}, 1}, b::Array{Tuple{Real, Real}, 1}, c::Array{Real, 1})
            r = Array{Tuple{Real, Real}}([])

            for i in 1:size(a)[1]
               push!(r, (c[i]*(a[i][1] - b[i][1]), c[i]*(a[i][2] - b[i][2])))
            end

            return r
         end

         gradient = weightedDifference(points, centroids, areas)

         α = 0.0005
         for i in 1:size(points)[1]
            points[i] = (points[i][1] - α*gradient[i][1], points[i][2] - α*gradient[i][2])
         end

         println(points)

         Draw.init(WIDTH, HEIGHT)
         #println("Drawing...")
         Draw.voronoiDiagram(V)

         if command != "a"
            println("Press Return for a step or enter \"a\" to animate until the end.")
            command = readline(stdin)
         else
            sleep(0.0000001)
         end
         n += 1
      end
   end
end

gradientDescent()
