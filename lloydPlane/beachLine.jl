module BeachLine


mutable struct Arc
   coordinates::Tuple{Number, Number}
end

function key(a::Arc)
   return a.coordinates[1]
end


mutable struct Breakpoint
   leftPoint::Tuple{Number, Number}
   rightPoint::Tuple{Number, Number}
end

function key(b::Breakpoint)
   return b.key
end


mutable struct Node
   thing::Union{Arc, Breakpoint}
   left::Union{Node, Void}
   right::Union{Node, Void}
end


mutable struct BST
   root::Union{Node, Void}
end

function BST()
   return BST(nothing)
end


function insert(T::BST, thing::Arc)
   if T.root == nothing
      T.root = Node(thing, nothing, nothing)
   else
      node = T.root
      while true
         if key(thing) < key(node.thing)
            child = node.left

            if child == nothing
               node.left = Node(thing, nothing, nothing)

               return
            end
         else
            child = node.right

            if child == nothing
               node.right = Node(thing, nothing, nothing)

               return
            end
         end

         node = child
      end
   end
end


# lazy version. if we wanted speed, should be iterative
function traverse(T::BST)
   function traverse(node::Union{Node, Void})
      if node == nothing
         return []
      end

      return vcat(traverse(node.left), node.thing.coordinates, traverse(node.right))
   end

   return traverse(T.root)
end


export BST
export Arc

end # module
