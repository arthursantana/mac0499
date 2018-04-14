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

function point(p::Tuple{Number, Number}, color, fill)
   global ax

   ax[:add_artist](patch.Circle((p[1], p[2]), alpha=0.5, color=color, radius=0.5, fill=fill))
end

function line(p1::Tuple{Number, Number}, p2::Tuple{Number, Number}, color)
   global plt

   plt.plot([p1[1], p2[1]], [p1[2], p2[2]], color=color, linestyle="-", linewidth=2, alpha=0.5)
end

function plot(f, color)
   global plt
   global WIDTH, HEIGHT

   x = linspace(0, WIDTH, 1000)
   y = map(f, x)

   plt.plot(x, y, color=color, alpha=0.5, linewidth=2)
end


end # module
