module EventQueue # max heap used for the event queue



using ..Diagram


abstract type Event end

mutable struct SiteEvent <: Event
   region::Diagram.Region
end

function key(ev::SiteEvent)
   return ev.region.generator[2] # y coordinate
end

function coordinates(ev::SiteEvent)
   return ev.region.generator
end


mutable struct CircleEvent <: Event
   coordinates::Tuple{Real, Real}
   center::Tuple{Real, Real}
   disappearingArc#::Union{BeachLine.Arc, Nothing} --- I'm not type checking because I'm getting a weird Julia-specific error I don't wanna solve now
                                                    # Cannot `convert` an object of type BeachLine.Arc to an object of type BeachLine.Arc
   removed::Bool
end

function CircleEvent(center::Tuple{Real, Real}, r, arc)
   return CircleEvent((center[1], center[2] - r), center, arc, false)
end

function key(ev::CircleEvent)
   return ev.coordinates[2] # y coordinate
end

function coordinates(ev::CircleEvent)
   return ev.coordinates
end


mutable struct Heap
   data::Array{Event}
   pos::Int # first empty position in the array
end

function Heap(n::Int)
   if n == 0
      n = 1
   end

   return Heap(Array{Event}(undef, n), 1)
end

function Heap()
   return Heap(1)
end


function leftChild(i)
   return 2i
end

function rightChild(i)
   return 2i+1
end

function parent(i)
   return Int(floor(i/2))
end

function largestChild(h::Heap, i::Int)
   l = leftChild(i)
   r = rightChild(i)

   if h.pos <= l
      return -1 # no children
   elseif h.pos  == r
      return l # no right child
   elseif key(h.data[l]) >= key(h.data[r])
      return l
   else
      return r
   end
end

function push!(h::Heap, ev::Event)
   n = size(h.data)[1]

   if h.pos >= n # full
      resize!(h.data, 2n + 1) # space for another complete level
   end

   i = h.pos
   h.data[i] = ev

   p = parent(i)
   while i > 1 && key(h.data[i]) > key(h.data[p])
      # bubble up
      swap = h.data[i]
      h.data[i] = h.data[p]
      h.data[p] = swap

      i = p
      p = parent(i)
   end

   h.pos += 1
end

function pop(h::Heap)
   resolved = false

   while !resolved
      if h.pos == 1
         return nothing # empty
      end

      h.pos -= 1

      # swap last element with root
      last = h.pos
      swap = h.data[1]
      h.data[1] = h.data[last]
      h.data[last] = swap

      i = 1
      c = largestChild(h, i)
      while c != -1 && key(h.data[c]) > key(h.data[i])
         # trickle down
         swap = h.data[i]
         h.data[i] = h.data[c]
         h.data[c] = swap

         i = c
         c = largestChild(h, i)
      end

      if isa(h.data[h.pos], SiteEvent) || !(h.data[h.pos].removed)
         resolved = true
      end
   end

   return h.data[h.pos]
end

function remove(h::Heap, event::EventQueue.CircleEvent)
   event.removed = true
end

#function heapPropertyIsOk(h::Heap) # for debugging
#   ok = true
#
#   for i in 2:h.pos-1
#      if key(h.data[i]) > key(h.data[parent(i)])
#         ok = false
#      end
#   end
#
#   return ok
#end


export Event
export SiteEvent
export CircleEvent
export coordinates
export Heap
export push!
export pop
export remove

end # module
