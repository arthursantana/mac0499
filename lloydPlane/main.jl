include("geometry.jl")
include("DCEL.jl")
include("eventQueue.jl")
include("beachLine.jl")
include("fortune.jl")
include("draw.jl")

WIDTH = 100.0
HEIGHT = 100.0
n = 10

points = convert(Array{Tuple{Number, Number}}, collect(zip(rand(0.0:WIDTH, n), rand(0.0:HEIGHT, n))))

V, T, Q = Fortune.init(points)

Draw.init(WIDTH, HEIGHT)

while (event = EventQueue.pop(Q)) != nothing
   ly = event.coordinates[2]

   Fortune.handleEvent(V, T, Q, event) # multiple dispatch decides if it's a site event or circle event

	Draw.clear()

   for p in points
		Draw.point(p, "black", (ly <= p[2]))
   end

	beachLineFoci = BeachLine.traverse(T)

	for p in beachLineFoci
		f = Geometry.parabola(p, ly)

		if f == nothing # point is over the sweep line
			Draw.line((p[1], ly), (p[1], HEIGHT), "green")
		else
			Draw.plot(f, "green")
		end
	end

   for p in beachLineFoci
      for q in beachLineFoci
         if p[1] < q[1]
            continue
         elseif p[1] == q[1] && p[2] <= q[2]
            continue
         end

         inter = Geometry.parabolaIntersection(p, q, ly)

         if inter == nothing || size(inter)[1] == 0
            continue
         end

         for point in inter
            if 0 <= point[1] <= WIDTH && 0 <= point[2] <= HEIGHT && point[2] >= ly
					Draw.point(point, "r", true)
            end
         end
      end
   end

	Draw.line((0, ly), (WIDTH, ly), "b")
	Draw.commit()
   println("press Return to continue...")
   readline(STDIN)
end








#push!(T, 131=>1)
#push!(Q, 32)
#push!(Q, 24)
#push!(Q, 55)
#






#function twins(a::DCEL.HalfEdge, b::DCEL.HalfEdge)
#   a.twin = b
#   b.twin = a
#end
#
#function concat(a::DCEL.HalfEdge, b::DCEL.HalfEdge)
#   a.next = b
#   b.prev = a
#end
#
#f1 = DCEL.Face(nothing)
#f2 = DCEL.Face(nothing)
#
# e1 = DCEL.HalfEdge((0, 0), f1,      nothing, nothing, nothing)
# e2 = DCEL.HalfEdge((0, 1), f1,      nothing, nothing, nothing)
# e3 = DCEL.HalfEdge((1, 0), f1,      nothing, nothing, nothing)
# 
# e4 = DCEL.HalfEdge((1, 0), f2,      nothing, nothing, nothing)
# e5 = DCEL.HalfEdge((0, 1), f2,      nothing, nothing, nothing)
# e6 = DCEL.HalfEdge((1, 1), f2,      nothing, nothing, nothing)
# 
# e7 = DCEL.HalfEdge((0, 0), nothing, nothing, nothing, nothing)
# e8 = DCEL.HalfEdge((0, 1), nothing, nothing, nothing, nothing)
# e9 = DCEL.HalfEdge((1, 1), nothing, nothing, nothing, nothing)
#e10 = DCEL.HalfEdge((1, 0), nothing, nothing, nothing, nothing)
#
#twins(e1,e7)
#twins(e2,e4)
#twins(e3,e10)
#twins(e5,e8)
#twins(e6,e9)
#
#concat(e1, e2)
#concat(e2, e3)
#concat(e3, e1)
#
#concat(e4, e5)
#concat(e5, e6)
#concat(e6, e4)
#
#f1.border = e1
#f2.border = e4
#
#l = DCEL.List([f1, f2], [e1, e2, e3, e4, e5, e6, e7, e8, e9, e10])
#
#plt.pygui(true)
#ax = plt.gca() # get current axes
#ax[:set_xlim]([0, 1])
#ax[:set_ylim]([0, 1])
#plt.title("Fortune's Algorithm")
#ax[:grid]("off")
#ax[:get_xaxis]()[:set_visible](false)
#ax[:get_yaxis]()[:set_visible](false)
#
#r = DCEL.regions(l)
#
#for region in r
#   ax[:fill](region[1], region[2])
#end
#
#plt.show()
