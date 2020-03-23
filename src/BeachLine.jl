module BeachLine


using ..Geometry
using ..EventQueue
using ..Diagram



@enum SIDE LEFT RIGHT


mutable struct Arc
   region::Diagram.Region
   disappearsAt::Union{EventQueue.CircleEvent, Nothing}
   parent#::Union{Breakpoint, Nothing}
   prev::Union{Arc, Nothing}
   next::Union{Arc, Nothing}
end


mutable struct Breakpoint
   leftFocus::Tuple{Real, Real}
   rightFocus::Tuple{Real, Real}
   parent::Union{Breakpoint, Nothing}
   leftChild::Union{Arc, Breakpoint}
   rightChild::Union{Arc, Breakpoint}
   halfEdge::Union{Diagram.HalfEdge, Nothing}
end

mutable struct BST
   root::Union{Arc, Breakpoint, Nothing}
end

function BST()
   return BST(nothing)
end


function insert(T::BST, region::Diagram.Region, ly::Real)
   arc = Arc(region, nothing, nothing, nothing, nothing)

   if T.root == nothing
      T.root = arc
      node = nothing
   else # look for the parabola immediately over arc.region.generator
      parent = nothing
      node = T.root
      side = LEFT # indicate which pointer from parent points to node

      while !isa(node, Arc)
         parent = node

         bp = Geometry.parabolaIntersection(node.leftFocus, node.rightFocus, ly)

         if bp == nothing
            println("SPECIAL CASE: FIRST COUPLE OF POINTS ARE ON THE SAME Y. NOT IMPLEMENTED YET")
         else
            if arc.region.generator[1] <= bp[1]
               node = node.leftChild
               side = LEFT
            else
               node = node.rightChild
               side = RIGHT
            end
         end
      end

      # arrived at a leaf 'node'; switch it for subtree with tree leaves, 'arc' being the middle one, 'node' being on both the others
      newNode = Arc(node.region, nothing, nothing, arc, node.next)
      arc.prev = node
      arc.next = newNode
      if node.next != nothing
         node.next.prev = newNode
      end
      node.next = arc

      childTree = Breakpoint(arc.region.generator, node.region.generator, nothing, arc, newNode, nothing)
      newSubTree = Breakpoint(node.region.generator, arc.region.generator, parent, node, childTree, nothing)
      
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

function remove(T::BST, arc::Arc)
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
   newBreakpoint = nothing

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
            if parent.leftFocus != rightExtreme.region.generator
               parent.leftFocus = rightExtreme.region.generator
               newBreakpoint = parent
            end
            rightExtreme = nothing # nothing means no change
         end
      else
         if leftExtreme != nothing
            if parent.rightFocus != leftExtreme.region.generator
               parent.rightFocus = leftExtreme.region.generator
               newBreakpoint = parent
            end
            leftExtreme = nothing # nothing means no change
         end
      end

      subTree = subTree.parent
      parent = subTree.parent
   end

   return newBreakpoint

   # TODO: BALANCE TREE
end


# traverses tree returning only the leaves and the breakpoint x coordinates
# between them; updates positions of the extremes of the Voronoi edges
# lazy version. if we wanted speed, should be iterative
# this is also O(n), it's only used so we can draw the beachLine
# production version should not use this (see Fortune.compute())
function beachLine(T::BST, ly)
   function beachLine(node::Arc)
      return [node.region.generator]
   end

   function beachLine(node::Breakpoint)
      bp = Geometry.parabolaIntersection(node.leftFocus, node.rightFocus, ly)
      node.halfEdge.origin = bp

      return vcat(beachLine(node.leftChild), [bp], beachLine(node.rightChild))
   end

   if T.root == nothing
      return []
   else
      return beachLine(T.root)
   end
end


function printNode(node::Nothing, depth) # for debugging
   return
end

function printNode(node::Arc, depth) # for debugging
   for i in 1:depth
      print(".")
   end
   if node.parent == nothing
      print(node.region.generator, "; orphan")
   else
      print(node.region.generator, "; parent = ", node.parent.leftFocus, ",", node.parent.rightFocus)
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


end # module
