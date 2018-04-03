import PyPlot
using PyCall
plt = PyPlot
@pyimport matplotlib.patches as patch

include("DCEL.jl")
include("eventQueue.jl")

using DataStructures

Q = EventQueue.Heap()

WIDTH = 100
HEIGHT = 100
n = 2

points = zip(rand(1:WIDTH, n), rand(1:HEIGHT, n))

for p in points
   EventQueue.push(Q, EventQueue.Event(p))
end

#T = SortedDict{Int, Int}()

plt.pygui(true)
plt.title("Fortune's Algorithm")
plt.ion()
plt.clf()

ax = plt.gca() # get current axes
ax[:set_aspect]("equal")
ax[:set_xlim]([0, WIDTH])
ax[:set_ylim]([0, HEIGHT])
ax[:grid]("off")
ax[:get_xaxis]()[:set_visible](false)
ax[:get_yaxis]()[:set_visible](false)
plt.draw()

while true
   if (p = EventQueue.pop(Q)) == nothing
      break
   end
   
   l = p.coordinates[2]

   plt.cla()
   ax[:set_aspect]("equal")
   ax[:set_xlim]([0, WIDTH])
   ax[:set_ylim]([0, HEIGHT])
   ax[:grid]("off")
   ax[:get_xaxis]()[:set_visible](false)
   ax[:get_yaxis]()[:set_visible](false)
   for p in points
      if p[2] < l
         f = false
      else
         f = true
      end
      ax[:add_artist](patch.Circle((p[1], p[2]), alpha=0.5, color="k", radius=0.5, fill=f))
   end
   plt.plot([0, WIDTH], [l, l], color="b", linestyle="-", linewidth=2, alpha=0.5)
   plt.draw()
   println("aperte enter para continuar...")
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
