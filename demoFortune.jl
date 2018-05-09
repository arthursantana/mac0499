import Geometry
import Diagram
import BeachLine
import EventQueue
import Fortune
import Draw

WIDTH = 100.0
HEIGHT = 100.0
n = 10

points = convert(Array{Tuple{Number, Number}}, collect(zip(rand(1.0:WIDTH-1, n), rand(1.0:HEIGHT-1, n))))
#points = convert(Array{Tuple{Number, Number}}, [(70,50), (30, 50), (50, 70), (50, 30), (1, 1)])
#points = convert(Array{Tuple{Number, Number}}, [(100,40), (20, 5), (40, 5), (3, 2), (1, 1)])
#points = convert(Array{Tuple{Number, Number}}, [(80,40), (70, 40), (40, 5), (3, 2), (1, 1)])
#points = convert(Array{Tuple{Number, Number}}, [(100,100), (20, 80), (40, 80), (30, 70), (10, 60), (20, 20), (30, 20), (40, 20)])
#points = convert(Array{Tuple{Number, Number}}, [(60,70), (50, 60), (30, 55), (20, 30), (30, 39)])
#points = convert(Array{Tuple{Number, Number}}, [(22.0, 2.0), (15.0, 57.0), (51.0, 22.0), (82.0, 50.0), (18.0, 81.0), (48.0, 52.0), (85.0, 74.0), (36.0, 21.0), (63.0, 72.0), (89.0, 53.0)])
#println(points)

V, T, Q = Fortune.init(points)

Draw.init(WIDTH, HEIGHT)

while (event = EventQueue.pop(Q)) != nothing
   ly = event.coordinates[2] # sweep line

   Fortune.handleEvent(V, T, Q, event) # multiple dispatch decides if it's a site event or circle event

	Draw.clear()

   # draw points
   for p in points
      Draw.point(p, "xkcd:navy", (ly <= p[2]))
      if ly < p[2]
         f = Geometry.parabola(p, ly)
         Draw.plot(f, "xkcd:silver", 0, WIDTH)
      end
   end

   # calculate parabolas and breakpoints
	beachLineFoci = BeachLine.beachLine(T, ly)

   ### DEBUGGING SECTION
   #BeachLine.printTree(T)
   #println(beachLineFoci)

   ## print x foci of beach line, without breakpoints
   #i = 1
   #while i <= size(beachLineFoci)[1]
   #   print(beachLineFoci[i][1], " ")
   #   i += 2
   #end
   #println()

   ## print forward list of beachline arcs x's
   #a = T.root
   #if a != nothing
   #   while !isa(a, BeachLine.Arc)
   #      a = a.leftChild
   #   end
   #   while a != nothing
   #      print(a.focus[1], " ")
   #      a = a.next
   #   end
   #end
   #println()

   ## print backwards list of beachline arcs x's
   #a = T.root
   #if a != nothing
   #   while !isa(a, BeachLine.Arc)
   #      a = a.rightChild
   #   end
   #   while a != nothing
   #      print(a.focus[1], " ")
   #      a = a.prev
   #   end
   #end
   #println()
   ### DEBUGGING SECTION END

   # draw beachline
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

   # draw circumcircles
   i = 1
   while i < Q.pos
      if isa(Q.data[i], EventQueue.CircleEvent) && !(Q.data[i].removed)
         b = Q.data[i].disappearingArc
         a = b.prev
         c = b.next
         O = Q.data[i].center
         r = O[2] - Q.data[i].coordinates[2]
         Draw.circle(O, "xkcd:orangered", r)
         Draw.thinLine(O, b.focus, "xkcd:orangered")
         Draw.point(O, "xkcd:magenta", true)
         Draw.point((O[1], O[2] - r), "xkcd:orangered", true)
      end

      i += 1
   end

   for he in V.halfEdges
      Draw.line(he.origin, he.twin.origin, "xkcd:lime")
   end

   # draw sweepline
	Draw.line((0, ly), (WIDTH, ly), "xkcd:gold")
	Draw.commit()
   println("press Return to continue...")
   readline(STDIN)
end







#f1 = Diagram.Face(nothing)
#f2 = Diagram.Face(nothing)
#
# e1 = Diagram.HalfEdge((0, 0), f1,      nothing, nothing, nothing)
# e2 = Diagram.HalfEdge((0, 1), f1,      nothing, nothing, nothing)
# e3 = Diagram.HalfEdge((1, 0), f1,      nothing, nothing, nothing)
# 
# e4 = Diagram.HalfEdge((1, 0), f2,      nothing, nothing, nothing)
# e5 = Diagram.HalfEdge((0, 1), f2,      nothing, nothing, nothing)
# e6 = Diagram.HalfEdge((1, 1), f2,      nothing, nothing, nothing)
# 
# e7 = Diagram.HalfEdge((0, 0), nothing, nothing, nothing, nothing)
# e8 = Diagram.HalfEdge((0, 1), nothing, nothing, nothing, nothing)
# e9 = Diagram.HalfEdge((1, 1), nothing, nothing, nothing, nothing)
#e10 = Diagram.HalfEdge((1, 0), nothing, nothing, nothing, nothing)
#
#makeTwins(e1,e7)
#makeTwins(e2,e4)
#makeTwins(e3,e10)
#makeTwins(e5,e8)
#makeTwins(e6,e9)
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
#l = Diagram.DCEL([f1, f2], [e1, e2, e3, e4, e5, e6, e7, e8, e9, e10])
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
#r = Diagram.regions(l)
#
#for region in r
#   ax[:fill](region[1], region[2])
#end
#
#plt.show()
