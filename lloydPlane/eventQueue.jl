module EventQueue # max heap used for the event queue


mutable struct Event
   coordinates::Tuple{Number, Number}
end

function key(en::Event)
   return en.coordinates[2] # y coordinate
end

mutable struct Heap
   data::Array{Event}
   pos::Int # first empty position in the array
end

function Heap(n::Int)
   if n == 0
      n = 1
   end

   return Heap(Array{Event}(n), 1)
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

function push(h::Heap, en::Event)
   n = size(h.data)[1]

   if h.pos >= n # full
      resize!(h.data, 2n + 1) # space for another complete level
   end

   i = h.pos
   h.data[i] = en

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

   return h.data[h.pos]
end

function heapPropertyOk(h::Heap)
   ok = true

   for i in 2:h.pos-1
      if key(h.data[i]) > key(h.data[parent(i)])
         ok = false
      end
   end

   return ok
end

#h = Heap()
#
#println(pop(h))
#
#println("\n\nDados gerados aleatoriamente:\n")
#for i in rand(1:50, 15)
#   println(Event(i, string(i)))
#   push(h, Event(i, string(i)))
#end
#
#println("\n\nRetirando em ordem do max-heap:\n")
#while (x = pop(h)) != nothing
#   println(x)
#end

export Event
export Heap
export push
export pop

end # module
