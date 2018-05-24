import Geometry
import Diagram
import BeachLine
import EventQueue
import Fortune
import Draw

WIDTH = 100.0
HEIGHT = 100.0
n = 50

for i in 1:50
   println(i)
   srand(i)
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

   ly = HEIGHT
   while (event = EventQueue.pop(Q)) != nothing
      Fortune.handleEvent(V, T, Q, event) # multiple dispatch decides if it's a site event or circle event

      #Draw.fortuneIteration(V, T, Q, points, event.coordinates[2]) # last parameter is the sweep line height ly
      #println("press Return to continue...")
      #readline(STDIN)
   end

   Draw.fortuneIteration(V, T, Q, points, -10000)
   println("press Return to finish...")
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
