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
   #println("SITE EVENT: ", event.coordinates)
   ly = event.coordinates[2] # sweep line

	arc, arcAbove = BeachLine.insert(T, event.coordinates, ly)

   if arcAbove == nothing
      return
   end

   if arcAbove.disappearsAt != nothing # circle event for arc vertically above 'arc' was a false alarm
      EventQueue.remove(Q, arcAbove.disappearsAt)
      arcAbove.disappearsAt = nothing
   end

   rightBreakpoint = arc.parent;
   leftBreakpoint = rightBreakpoint.parent;

   # create half edge records for each new breakpoint
   f = Geometry.parabola(arcAbove.focus, ly)
   x = event.coordinates[1]
   breakpoint = (x, f(x))
   he1 = Diagram.HalfEdge(breakpoint, nothing, nothing, nothing, nothing)
   he2 = Diagram.HalfEdge(breakpoint, nothing, nothing, nothing, nothing)
   Diagram.makeTwins(he1, he2)
   push!(V.halfEdges, he1)
   push!(V.halfEdges, he2)
   leftBreakpoint.halfEdge = he1;
   rightBreakpoint.halfEdge = he2;

   # check for new circle events where 'arc' is the rightmost arc
   c = arc
   b = arc.prev
   if b != nothing
      a = b.prev

      # there's a triple with 'arc' on the rightmost position
      if a != nothing && Geometry.arcWillConverge(a.focus, b.focus, c.focus)
         O, r = Geometry.circumcircle(a.focus, b.focus, c.focus)

         ev = EventQueue.CircleEvent(O, r, b)
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

         ev = EventQueue.CircleEvent(O, r, b)
         b.disappearsAt = ev
         EventQueue.push(Q, ev)
      end
   end
end

function handleEvent(V::Diagram.DCEL, T::BeachLine.BST, Q::EventQueue.Heap, event::EventQueue.CircleEvent)
   #println("CIRCLE EVENT: ", event.coordinates, event.center)
   ly = event.coordinates[2] # sweep line
   arc = event.disappearingArc

   # find the Voronoi edges that are going to join together
   leftBreakpoint = rightBreakpoint = arc.parent
   while leftBreakpoint.leftFocus != arc.prev.focus ||
         leftBreakpoint.rightFocus != arc.focus
      leftBreakpoint = leftBreakpoint.parent
   end
   while rightBreakpoint.leftFocus != arc.focus ||
         rightBreakpoint.rightFocus != arc.next.focus
      rightBreakpoint = rightBreakpoint.parent
   end

   # fix the extremes of the joining Voronoi edges
   leftBreakpoint.halfEdge.origin = rightBreakpoint.halfEdge.origin = event.center

   arc.prev.next = arc.next
   arc.next.prev = arc.prev
   newBreakpoint = BeachLine.remove(T, event.disappearingArc, (event.coordinates[1], event.coordinates[2]))

   # create new half edge for the newly formed breakpoint
   he1 = Diagram.HalfEdge(event.center, nothing, nothing, nothing, nothing)
   he2 = Diagram.HalfEdge(event.center, nothing, nothing, nothing, nothing)
   Diagram.makeTwins(he1, he2)
   push!(V.halfEdges, he1)
   push!(V.halfEdges, he2)
   newBreakpoint.halfEdge = he1; # he2 is already bound to the vertex

   # remove circle events of triples that don't exist anymore
   if arc.prev.disappearsAt != nothing
      EventQueue.remove(Q, arc.prev.disappearsAt)
      arc.prev.disappearsAt = nothing
   end
   if arc.next.disappearsAt != nothing
      EventQueue.remove(Q, arc.next.disappearsAt)
      arc.next.disappearsAt = nothing
   end

   # check the left new triple of adjacent arcs for circle events
   if arc.prev != nothing && arc.next != nothing && arc.prev.prev != nothing
      a = arc.prev.prev
      b = arc.prev
      c = arc.next

      if Geometry.arcWillConverge(a.focus, b.focus, c.focus)
         O, r = Geometry.circumcircle(a.focus, b.focus, c.focus)

         ev = EventQueue.CircleEvent(O, r, b)
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

         ev = EventQueue.CircleEvent(O, r, b)
         b.disappearsAt = ev
         EventQueue.push(Q, ev)
      end
   end
end

function compute(points::Array{Tuple{Number, Number}, 1})
   V, T, Q = init()
end


end # module
