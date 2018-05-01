module Fortune


using Geometry
using EventQueue
using BeachLine
using Diagram


function init(points::Array{Tuple{Number, Number}, 1})
	n = size(points)[1]

   V = Diagram.DCEL(points)
	T = BeachLine.BST()
	Q = EventQueue.Heap(3n) # enough, see page 166 on BCKO (de Berg, Cheong, Kreveld, Overmars)

	for p in points
		EventQueue.push(Q, EventQueue.SiteEvent(p))
	end

	return V, T, Q
end

function handleEvent(V::Diagram.DCEL, T::BeachLine.BST, Q::EventQueue.Heap, event::EventQueue.SiteEvent)
   println("SITE EVENT: ", event.coordinates)
   ly = event.coordinates[2] # sweep line

	arc, arcAbove = BeachLine.insert(T, event.coordinates, ly)

   if arcAbove == nothing
      return
   end

   if arcAbove.disappearsAt != nothing # circle event for arc vertically above 'arc' was a false alarm
      EventQueue.remove(Q, arcAbove.disappearsAt)
      arcAbove.disappearsAt = nothing
   end

	#4. Create new half-edge records in the Voronoi diagram structure for the
	#edge separating V(p i ) and V(p j ), which will be traced out by the two new
	#breakpoints.
   f = Geometry.parabola(arcAbove.focus, ly)
   x = event.coordinates[1]
   breakpoint = (x, f(x))
   he1 = Diagram.HalfEdge(breakpoint, nothing, nothing, nothing, nothing)
   he2 = Diagram.HalfEdge(breakpoint, nothing, nothing, nothing, nothing)
   Diagram.twins(he1, he2)
   push!(V.halfEdges, he1)
   push!(V.halfEdges, he2)

   # check for new circle events where 'arc' is the rightmost arc
   c = arc
   b = arc.prev
   if b != nothing
      a = b.prev

      # there's a triple with 'arc' on the rightmost position
      if a != nothing && Geometry.arcWillConverge(a.focus, b.focus, c.focus)
         O, r = Geometry.circumcircle(a.focus, b.focus, c.focus)

         ev = EventQueue.CircleEvent((O[1], O[2] - r), b)
         b.disappearsAt = ev
         EventQueue.push(Q, ev)
      end
   end

   # check for new circle events where 'arc' is the leftmost arc
   a = arc
   b = arc.next
   if b != nothing
      c = b.next

      # there's a triple with 'arc' on the leftmost position
      if c != nothing && Geometry.arcWillConverge(a.focus, b.focus, c.focus)
         O, r = Geometry.circumcircle(a.focus, b.focus, c.focus)

         ev = EventQueue.CircleEvent((O[1], O[2] - r), b)
         b.disappearsAt = ev
         EventQueue.push(Q, ev)
      end
   end
end

function handleEvent(V::Diagram.DCEL, T::BeachLine.BST, Q::EventQueue.Heap, event::EventQueue.CircleEvent)
   println("CIRCLE EVENT: ", event.coordinates)
   ly = event.coordinates[2] # sweep line

   arc = event.disappearingArc

   if arc.prev != nothing
      arc.prev.next = arc.next
   end
   if arc.next != nothing
      arc.next.prev = arc.prev
   end

   BeachLine.remove(T, event.disappearingArc, (event.coordinates[1], event.coordinates[2]))

   if arc.prev != nothing && arc.prev.disappearsAt != nothing
      EventQueue.remove(Q, arc.prev.disappearsAt)
      arc.prev.disappearsAt = nothing
   end
   if arc.next != nothing && arc.next.disappearsAt != nothing
      EventQueue.remove(Q, arc.next.disappearsAt)
      arc.next.disappearsAt = nothing
   end

   #3. Add the center of the circle causing the event as a vertex record to the
   #doubly-connected edge list D storing the Voronoi diagram under construc-
   #tion. Create two half-edge records corresponding to the new breakpoint
   #of the beach line. Set the pointers between them appropriately. Attach the
   #three new records to the half-edge records that end at the vertex.

   # check the left new triple of adjacent arcs for circle events
   if arc.prev != nothing && arc.next != nothing && arc.prev.prev != nothing
      a = arc.prev.prev
      b = arc.prev
      c = arc.next

      if Geometry.arcWillConverge(a.focus, b.focus, c.focus)
         O, r = Geometry.circumcircle(a.focus, b.focus, c.focus)

         ev = EventQueue.CircleEvent((O[1], O[2] - r), b)
         b.disappearsAt = ev
         EventQueue.push(Q, ev)
      end
   end

   # check the right new triple of adjacent arcs for circle events
   if arc.prev != nothing && arc.next != nothing && arc.next.next != nothing
      a = arc.prev
      b = arc.next
      c = arc.next.next

      if Geometry.arcWillConverge(a.focus, b.focus, c.focus)
         O, r = Geometry.circumcircle(a.focus, b.focus, c.focus)

         ev = EventQueue.CircleEvent((O[1], O[2] - r), b)
         b.disappearsAt = ev
         EventQueue.push(Q, ev)
      end
   end
end

function compute(points::Array{Tuple{Number, Number}, 1})
   V, T, Q = init()
end


end # module
