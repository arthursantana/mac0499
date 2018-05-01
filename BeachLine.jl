module BeachLine


using Geometry
using EventQueue
using Diagram



@enum SIDE LEFT RIGHT


mutable struct Arc
   focus::Tuple{Number, Number}
   disappearsAt::Union{EventQueue.CircleEvent, Void}
   parent#::Union{Breakpoint, Void}
   prev::Union{Arc, Void}
   next::Union{Arc, Void}
end


mutable struct Breakpoint
   leftFocus::Tuple{Number, Number}
   rightFocus::Tuple{Number, Number}
   parent::Union{Breakpoint, Void}
   leftChild::Union{Arc, Breakpoint}
   rightChild::Union{Arc, Breakpoint}
   
   #edge::Diagram.HalfEdge
end

function findBreakpoint(node::Breakpoint, ly)
   bp = Geometry.parabolaIntersection(node.leftFocus, node.rightFocus, ly)

   if bp == nothing
      println("ZERO INTERSECTIONS! SHOULDN'T HAPPEN")
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
   arc = Arc(coordinates, nothing, nothing, nothing, nothing)

   if T.root == nothing
      T.root = arc
      node = nothing
   else # look for the parabola immediately over arc.focus
      parent = nothing
      node = T.root
      side = LEFT # indicate which pointer from parent points to node

      while !isa(node, Arc)
         parent = node

         bp = findBreakpoint(node, ly)

         if arc.focus[1] <= bp[1]
            node = node.leftChild
            side = LEFT
         else
            node = node.rightChild
            side = RIGHT
         end
      end

      # arrived at a leaf 'node'; switch it for subtree with tree leaves, 'arc' being the middle one, 'node' being on both the others
      newNode = Arc(node.focus, nothing, nothing, arc, node.next)
      arc.prev = node
      arc.next = newNode
      if node.next != nothing
         node.next.prev = newNode
      end
      node.next = arc

      childTree = Breakpoint(arc.focus, node.focus, nothing, arc, newNode)
      newSubTree = Breakpoint(node.focus, arc.focus, parent, node, childTree)
      
      node.parent = newSubTree
      childTree.parent = newSubTree
      arc.parent = childTree
      newNode.parent = childTree

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

   return arc, node
end

function remove(T::BST, arc::Arc, coordinates::Tuple{Number, Number})
   if arc == T.root
      T.root = nothing

      return
   end


   parent = arc.parent

   if parent.leftChild == arc
      other = parent.rightChild
   else
      other = parent.leftChild
   end

   other.parent = parent.parent

   if parent.parent.leftChild == parent
      parent.parent.leftChild = other
   else
      parent.parent.rightChild = other
   end

   # fix breakpoints upwards
   subTree = other

   leftExtreme = rightExtreme = subTree
   while isa(leftExtreme, Breakpoint)
      leftExtreme = leftExtreme.leftChild
   end
   while isa(rightExtreme, Breakpoint)
      rightExtreme = rightExtreme.rightChild
   end

   parent = subTree.parent
   while parent != nothing
      if leftExtreme == rightExtreme == nothing
         break # nothing else upwards can change
      end

      if parent.leftChild == subTree
         if rightExtreme != nothing
            parent.leftFocus = rightExtreme.focus
            rightExtreme = nothing # nothing means no change
         end
      else
         if leftExtreme != nothing
            parent.rightFocus = leftExtreme.focus
            leftExtreme = nothing # nothing means no change
         end
      end

      subTree = subTree.parent
      parent = subTree.parent
   end

   # TODO: BALANCE TREE
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
         return vcat(beachLine(node.leftChild), [findBreakpoint(node, ly)], beachLine(node.rightChild))
      end
   end

   if T.root == nothing
      return []
   else
      return beachLine(T.root)
   end
end


function printNode(node::Void, depth) # for debugging
   return
end

function printNode(node::Arc, depth) # for debugging
   for i in 1:depth
      print(".")
   end
   if node.parent == nothing
      print(node.focus, "; orphan")
   else
      print(node.focus, "; parent = ", node.parent.leftFocus, ",", node.parent.rightFocus)
   end
   println()
end

function printNode(node::Breakpoint, depth) # for debugging
   for i in 1:depth
      print(".")
   end
   if node.parent == nothing
      print(node.leftFocus, node.rightFocus, "; orphan")
   else
      print(node.leftFocus, node.rightFocus, "; parent = ", node.parent.leftFocus, ",", node.parent.rightFocus)
   end
   println()
   printNode(node.leftChild, depth+1)
   printNode(node.rightChild, depth+1)
end

function printTree(T::BST) # for debugging
   if T.root != nothing
      printNode(T.root, 0)
   end
end


export BST
export Arc

end # module
