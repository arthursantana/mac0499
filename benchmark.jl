include("Geometry.jl")
include("Diagram.jl")
include("EventQueue.jl")
include("BeachLine.jl")
include("Fortune.jl")
include("Intersect.jl")
include("Optimization.jl")
include("Draw.jl")

using Random
using Printf


function randf(start, finish, n)
   v = rand(n)
   return map(x -> start + x*(finish-start), v)
end
Random.seed!(100)

WIDTH = 100.0
HEIGHT = 100.0

function benchmarkLloyd(Z::Array{Tuple{Real, Real}, 1}, ϵ::Number)
   global WIDTH, HEIGHT

   points = deepcopy(Z)

   results = Array{Tuple{Real, Real, Real, Real}}([])

   times = @elapsed V, f, ∇f, ξ = Optimization.init(points, WIDTH, HEIGHT)
   evaluations = 1
   push!(results, (f, ξ, evaluations, times))

   while ξ > ϵ
      time = @elapsed V, f, ξ = Optimization.lloydIteration(points, V)

      evaluations += 1
      times += time

      push!(results, (f, ξ, evaluations, times))
   end

   return results
end

function benchmarkGradient(Z::Array{Tuple{Real, Real}, 1}, ϵ::Number)
   global WIDTH, HEIGHT

   points = deepcopy(Z)

   results = Array{Tuple{Real, Real, Real, Real}}([])

   times = @elapsed V, f, ∇f, ξ = Optimization.init(points, WIDTH, HEIGHT)
   evaluations = 1
   push!(results, (f, ξ, evaluations, times))
   μ = 0.5
   α = 0.01
   λ₀ = 0.01

   while ξ > ϵ
      d = ∇f

      time = @elapsed V, f, ∇f, ξ, evals = Optimization.lineSearch(points, d, α, λ₀, μ, ϵ, V, f, ∇f, ξ)

      evaluations += evals
      times += time

      push!(results, (f, ξ, evaluations, times))
   end

   return results
end

function benchmark(n, ϵ)
   global WIDTH, HEIGHT

   points = convert(Array{Tuple{Real, Real}}, collect(zip(randf(1, WIDTH-1, n), randf(1, HEIGHT-1, n))))

   lloyd_results = benchmarkLloyd(points, ϵ)
   gradient_results = benchmarkGradient(points, ϵ)

   lloyd_f = Array{Number}([])
   lloyd_ξ = Array{Number}([])
   lloyd_evals = Array{Number}([])
   lloyd_time = Array{Number}([])
   gradient_f = Array{Number}([])
   gradient_ξ = Array{Number}([])
   gradient_evals = Array{Number}([])
   gradient_time = Array{Number}([])

   i = 1
   t₀ = lloyd_results[1][4]
   for (fᵢ, ξᵢ, evalsᵢ, timeᵢ) in lloyd_results
      push!(lloyd_f, fᵢ)
      push!(lloyd_ξ, ξᵢ)
      push!(lloyd_evals, evalsᵢ)
      push!(lloyd_time, timeᵢ - t₀)
      i += 1
   end

   i = 1
   t₀ = gradient_results[1][4]
   for (fᵢ, ξᵢ, evalsᵢ, timeᵢ) in gradient_results
      push!(gradient_f, fᵢ)
      push!(gradient_ξ, ξᵢ)
      push!(gradient_evals, evalsᵢ)
      push!(gradient_time, timeᵢ - t₀)
      i += 1
   end

   #@printf("f = %.10g\t\t|∇f| = %.10g\t\ttime: %s seconds\n", f, ξ, time)
   #@printf("f = %.10g\t\t|∇f| = %.10g\t\ttime: %s seconds\n", f, ξ, time)

   Draw.init(0, 0)
   Draw.clear(string("n = ", n))
   Draw.plot(lloyd_time, lloyd_f, "xkcd:azure", "Algoritmo de Lloyd", "-")
   Draw.plot(gradient_time, gradient_f, "xkcd:tomato", "Método do Gradiente", ":")
   Draw.legend("Tempo (s)", "Valor da Função Objetivo")
   Draw.commit()
   println("Press Return to finish.")
   command = readline(stdin)

   Draw.init(0, 0)
   Draw.clear(string("n = ", n))
   Draw.plot(lloyd_time, lloyd_ξ, "xkcd:azure", "Algoritmo de Lloyd", "-")
   Draw.plot(gradient_time, gradient_ξ, "xkcd:tomato", "Método do Gradiente", ":")
   Draw.legend("Tempo (s)", "Norma do Gradiente")
   Draw.commit()
   println("Press Return to finish.")
   command = readline(stdin)
end

ϵ = 10^-2
benchmark(3, ϵ)
benchmark(30, ϵ)
benchmark(100, ϵ)
benchmark(300, ϵ)
benchmark(1000, ϵ)
