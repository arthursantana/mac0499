include("Geometry.jl")
include("Diagram.jl")
include("EventQueue.jl")
include("BeachLine.jl")
include("Fortune.jl")
include("Intersect.jl")
include("Draw.jl")

using Random


function randf(start, finish, n)
   v = rand(n)
   return map(x -> start + x*(finish-start), v)
end

function demoFortune()
   WIDTH = 100.0
   HEIGHT = 100.0
   n = 100
   for i in 1:1000
      println("Random seed: ", i)
      Random.seed!(i)
      points = convert(Array{Tuple{Real, Real}}, collect(zip(randf(1, WIDTH-1, n), randf(1, HEIGHT-1, n))))
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

      Draw.init(WIDTH, HEIGHT)

      command = nothing

      ly = HEIGHT
      while (event = EventQueue.pop(Q)) != nothing
         Fortune.handleEvent(V, T, Q, event) # multiple dispatch decides if it's a site event or circle event

         ly = EventQueue.coordinates(event)[2] # sweep line height
         Draw.fortuneIteration(V, T, Q, points, ly)
         if command != "a"
            println("Press Return for a step or enter \"a\" to animate until the end.")
            command = readline(stdin)
         else
            sleep(0.001)
         end
      end

      println("Press Return to finish.")
      readline(stdin)
      n += 1
   end
end

demoFortune()
