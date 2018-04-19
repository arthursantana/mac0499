module Fortune


using Geometry
using EventQueue
using BeachLine
using DCEL


function init(points::Array{Tuple{Number, Number}, 1})
	n = size(points)[1]

	V = DCEL.List([DCEL.Face(nothing)], [DCEL.HalfEdge((0,0), nothing, nothing, nothing, nothing)])
	T = BeachLine.BST()
	Q = EventQueue.Heap(3n) # enough, see page 166 on BCKO (de Berg, Cheong, Kreveld, Overmars)

	for p in points
		EventQueue.push(Q, EventQueue.SiteEvent(p))
	end

	return V, T, Q
end

function handleEvent(V::DCEL.List, T::BeachLine.BST, Q::EventQueue.Heap, event::EventQueue.SiteEvent)
   ly = event.coordinates[2] # sweep line

	arc = BeachLine.insert(T, event.coordinates, ly)

	#4. Create new half-edge records in the Voronoi diagram structure for the
	#edge separating V(p i ) and V(p j ), which will be traced out by the two new
	#breakpoints.

   c = arc
   b = arc.prev
   if b != nothing
      a = b.prev

      if a != nothing # there's a triple with 'arc' on the rightmost position
         # TODO: CHECK IF BREAKPOINTS CONVERGE
         O, r = Geometry.circumcircle(a.focus, b.focus, c.focus)

         ev = EventQueue.CircleEvent((O[1], O[2] - r), b)
         b.disappearsAt = ev
         EventQueue.push(Q, ev)
      end
   end

   a = arc
   b = arc.next
   if b != nothing
      c = b.next

      if c != nothing # there's a triple with 'arc' on the leftmost position
         # TODO: CHECK IF BREAKPOINTS CONVERGE
         O, r = Geometry.circumcircle(a.focus, b.focus, c.focus)

         ev = EventQueue.CircleEvent((O[1], O[2] - r), b)
         b.disappearsAt = ev
         EventQueue.push(Q, ev)
      end
   end
end

function handleEvent(V::DCEL.List, T::BeachLine.BST, Q::EventQueue.Heap, event::EventQueue.CircleEvent)
   arc = event.disappearingArc

   if arc.prev != nothing
      arc.prev.next = arc.next
   end
   if arc.next != nothing
      arc.next.prev = arc.prev
   end

   #1. Delete the leaf γ that represents the disappearing arc α from T. Update
   #the tuples representing the breakpoints at the internal nodes. Perform
   #rebalancing operations on T if necessary.

	arc = BeachLine.remove(T, event.coordinates)
   
   #2. Delete all circle events involving
   #α from Q; these can be found using the pointers from the predecessor and
   #the successor of γ in T. (The circle event where α is the middle arc is
   #currently being handled, and has already been deleted from Q.)

   #3. Add the center of the circle causing the event as a vertex record to the
   #doubly-connected edge list D storing the Voronoi diagram under construc-
   #tion. Create two half-edge records corresponding to the new breakpoint
   #of the beach line. Set the pointers between them appropriately. Attach the
   #three new records to the half-edge records that end at the vertex.

   #4. Check the new triple of consecutive arcs that has the former left neighbor
   #of α as its middle arc to see if the two breakpoints of the triple converge.
   #If so, insert the corresponding circle event into Q. and set pointers between
   #the new circle event in Q and the corresponding leaf of T. Do the same for
   #the triple where the former right neighbor is the middle arc.
end

function compute(points::Array{Tuple{Number, Number}, 1})
   V, T, Q = init()
end


end # module
