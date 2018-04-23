import Geometry
import DCEL
import BeachLine
import EventQueue
import Fortune
import Draw

WIDTH = 100.0
HEIGHT = 100.0
n = 10

#points = convert(Array{Tuple{Number, Number}}, collect(zip(rand(1.0:WIDTH-1, n), rand(1.0:HEIGHT-1, n))))
points = convert(Array{Tuple{Number, Number}}, [(100,100), (20, 80), (40, 80), (30, 70), (10, 60)])
#points = convert(Array{Tuple{Number, Number}}, [(40,40), (30, 30), (10, 25), (0, 0), (10, 9)])

V, T, Q = Fortune.init(points)

Draw.init(WIDTH, HEIGHT)

while (event = EventQueue.pop(Q)) != nothing
   ly = event.coordinates[2] # sweep line

   Fortune.handleEvent(V, T, Q, event) # multiple dispatch decides if it's a site event or circle event

	Draw.clear()

   for p in points
      Draw.point(p, "xkcd:navy", (ly <= p[2]))
      if ly < p[2]
         f = Geometry.parabola(p, ly)
         Draw.plot(f, "xkcd:silver", 0, WIDTH)
      end
   end

	beachLineFoci = BeachLine.beachLine(T, ly)

   BeachLine.printTree(T)
   println(beachLineFoci)

   start = (0, HEIGHT)
   i = 2
   while i <= size(beachLineFoci)[1] + 2
      if i <= size(beachLineFoci)[1]
         finish = beachLineFoci[i]
      else
         finish = (WIDTH, start[2])
      end

      p = beachLineFoci[i-1]
		f = Geometry.parabola(p, ly)

		if f == nothing # point is over the sweep line
         Draw.line((p[1], ly), (p[1], start[2]), "xkcd:azure")
		else
         if 0 <= start[1]
            st = start[1]
         else
            st = 0
         end

         if finish[1] <= WIDTH
            fn = finish[1]
         else
            fn = WIDTH
         end

			Draw.plot(f, "xkcd:azure", st, fn)
		end

      start = finish
      i += 2
	end

   i = 1
   while i < Q.pos
      if isa(Q.data[i], EventQueue.CircleEvent)
         b = Q.data[i].disappearingArc
         a = b.prev
         c = b.next
         O, r = Geometry.circumcircle(a.focus, b.focus, c.focus)
         Draw.circle(O, "xkcd:orangered", r)
         Draw.thinLine(O, b.focus, "xkcd:orangered")
         Draw.point(O, "xkcd:magenta", true)
         Draw.point((O[1], O[2] - r), "xkcd:orangered", true)
      end

      i += 1
   end

	Draw.line((0, ly), (WIDTH, ly), "xkcd:gold")
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
