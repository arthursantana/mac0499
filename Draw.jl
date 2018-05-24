module Draw

import PyPlot
using PyCall
@pyimport matplotlib.patches as patch

using Geometry
using Diagram
using BeachLine
using EventQueue


plt = PyPlot
ax = nothing
WIDTH = nothing
HEIGHT = nothing


function init(w, h)
   global plt, ax
   global WIDTH, HEIGHT

   plt.pygui(true)
   plt.ion()
   plt.clf()
   #plt.xkcd() # uncomment for generalized wobbliness (for some reason only the axes are wobbly :( )
   ax = plt.gca() # get current axes

   WIDTH = w
   HEIGHT = h
end

function clear()
   global plt, ax
   global WIDTH, HEIGHT

   plt.cla()
   plt.title("Computing Voronoi Diagram using Fortune's Algorithm")
   ax[:set_aspect]("equal")
   ax[:set_xlim]([0, WIDTH])
   ax[:set_ylim]([0, HEIGHT])
   ax[:grid](false)
   ax[:get_xaxis]()[:set_visible](false)
   ax[:get_yaxis]()[:set_visible](false)
end

function commit()
   global plt

   plt.draw()
end


function circle_Internal(p::Tuple{Number, Number}, color, fill, r, l)
   global ax

   ax[:add_artist](patch.Circle((p[1], p[2]), color=color, radius=r, fill=fill, zorder=3, linewidth=l))
end

function point(p::Tuple{Number, Number}, color, fill)
   circle_Internal(p, color, fill, 0.5, 1)
end

function circle(p::Tuple{Number, Number}, color, r)
   circle_Internal(p, color, false, r, 1)
end

function line(p1::Tuple{Number, Number}, p2::Tuple{Number, Number}, color)
   global plt

   plt.plot([p1[1], p2[1]], [p1[2], p2[2]], color=color, linestyle="-", linewidth=3, zorder=1)
end

function thinLine(p1::Tuple{Number, Number}, p2::Tuple{Number, Number}, color)
   global plt

   plt.plot([p1[1], p2[1]], [p1[2], p2[2]], color=color, linestyle="-", linewidth=1, zorder=1)
end

function plot(f, color, start, finish)
   global plt

   x = linspace(start, finish, 1000)
   y = map(f, x)

   plt.plot(x, y, color=color, linewidth=3, zorder=2)
end




function fortuneIteration(V::Diagram.DCEL, T::BeachLine.BST, Q::EventQueue.Heap, points::Array{Tuple{Number, Number}}, ly::Number)
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
end


end # module
