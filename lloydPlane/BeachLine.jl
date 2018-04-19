module BeachLine


using Geometry
using EventQueue
using DCEL



@enum SIDE LEFT RIGHT


mutable struct Arc
   focus::Tuple{Number, Number}
   disappearsAt::Union{EventQueue.CircleEvent, Void}
   prev::Union{Arc, Void}
   next::Union{Arc, Void}
end


mutable struct Breakpoint
   leftFocus::Tuple{Number, Number}
   rightFocus::Tuple{Number, Number}
   side::SIDE # indicates if this breakpoint is the left or right intersection between the parabolas
   leftChild::Union{Arc, Breakpoint}
   rightChild::Union{Arc, Breakpoint}
   
   #edge::DCEL.HalfEdge
end

function breakpointX(node::Breakpoint, ly)
   inter = Geometry.parabolaIntersection(node.leftFocus, node.rightFocus, ly)
   s = size(inter)[1]

   if s == 0
      println("ZERO INTERSECTIONS! SHOULDN'T HAPPEN")
   elseif s == 1
      println("SINGLE INTERSECTION! SHOULDN'T HAPPEN")
   end

   if s == 2 # decide which is the correct breakpoint to use
      if node.side == LEFT
         if inter[1][1] <= inter[2][1]
            bp = inter[1]
         else
            bp = inter[2]
         end
      else # side == RIGHT
         if inter[1][1] >= inter[2][1]
            bp = inter[1]
         else
            bp = inter[2]
         end
      end
   else
      bp = inter[1]
   end

   return bp
end


mutable struct BST
   root::Union{Arc, Breakpoint, Void}
end

function BST()
   return BST(nothing)
end


function insert(T::BST, coordinates::Tuple{Number, Number}, ly::Number)
   arc = Arc(coordinates, nothing, nothing, nothing)

   if T.root == nothing
      T.root = arc
   else # look for the parabola immediately over arc.focus
      parent = nothing
      node = T.root
      side = LEFT # indicate which pointer from parent points to node

      while !isa(node, Arc)
         parent = node

         bp = breakpointX(node, ly)[1]

         if arc.focus[1] <= bp
            node = node.leftChild
            side = LEFT
         else
            node = node.rightChild
            side = RIGHT
         end
      end

      # arrived at a leaf 'node'; switch it for subtree with tree leaves, 'arc' being the middle one, 'node' being on both the others
      newNode = Arc(node.focus, node.disappearsAt, arc, node.next)
      arc.prev = node
      arc.next = newNode
      node.next = arc

      newSubTree = Breakpoint(node.focus, arc.focus, LEFT, node, Breakpoint(arc.focus, node.focus, RIGHT, arc, newNode))

      if parent == nothing
         T.root = newSubTree
      else
         if side == LEFT
            parent.leftChild = newSubTree
         else # RIGHT
            parent.rightChild = newSubTree
         end

         # TODO: BALANCE TREE
      end
   end

   return arc
end

function remove(T::BST, coordinates::Tuple{Number, Number})
   # TODO: fix breakpoints upwards (how exactly?)
end


# traverse tree returning only the leaves and the breakpoint x coordinates between them
# lazy version. if we wanted speed, should be iterative
# this is also O(n), it's only used so we can draw the beachLine
# production version should not use this (see Fortune.compute())
function beachLine(T::BST, ly)
   function beachLine(node::Union{Arc, Breakpoint})
      if isa(node, Arc)
         return [node.focus]
      else
         return vcat(beachLine(node.leftChild), [breakpointX(node, ly)], beachLine(node.rightChild))
      end
   end

   if T.root == nothing
      return []
   else
      return beachLine(T.root)
   end
end


export BST

end # module
