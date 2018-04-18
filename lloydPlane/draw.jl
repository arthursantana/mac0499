module Draw

import PyPlot
using PyCall
@pyimport matplotlib.patches as patch


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
   ax[:grid]("off")
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

function plot(f, color, start, finish)
   global plt

   x = linspace(start, finish, 1000)
   y = map(f, x)

   plt.plot(x, y, color=color, linewidth=3, zorder=2)
end


end # module
