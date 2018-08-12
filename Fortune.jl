module Fortune


using Geometry
using EventQueue
using BeachLine
using Diagram


function init(points::Array{Tuple{Number, Number}, 1})
	n = size(points)[1]

   V = Diagram.DCEL(points)
	T = BeachLine.BST()
	Q = EventQueue.Heap(3n) # 3n is enough, see page 166 on BCKO (de Berg, Cheong, Kreveld, Overmars)

	for region in V.regions
		EventQueue.push(Q, EventQueue.SiteEvent(region))
	end

	return V, T, Q
end

function handleEvent(V::Diagram.DCEL, T::BeachLine.BST, Q::EventQueue.Heap, event::EventQueue.SiteEvent)
   #println("SITE EVENT: ", event.region.generator)
   ly = event.region.generator[2] # sweep line

	arc, arcAbove = BeachLine.insert(T, event.region.generator, ly)

   if arcAbove == nothing
      return
   end

   if arcAbove.disappearsAt != nothing # circle event for arc vertically above 'arc' was a false alarm
      EventQueue.remove(Q, arcAbove.disappearsAt)
      arcAbove.disappearsAt = nothing
   end

   rightBreakpoint = arc.parent
   leftBreakpoint = rightBreakpoint.parent

   # create half edge records for each new breakpoint
   f = Geometry.parabola(arcAbove.focus, ly)
   x = event.region.generator[1]

   if f != nothing
      breakpoint = (x, f(x))
   else
      breakpoint = nothing
   end

   # direction of the halfedge, rotating clockwise around the arc above (always going right)
   dir = Geometry.rotateVectorCCW(Geometry.subVector(arc.focus, arcAbove.focus))

   he1 = Diagram.HalfEdge(Geometry.subVector(breakpoint, dir), false, nothing, nothing, nothing)
   he2 = Diagram.HalfEdge(Geometry.addVector(breakpoint, dir), false, nothing, nothing, nothing)
   Diagram.makeTwins(he1, he2)
   push!(V.halfEdges, he1)
   push!(V.halfEdges, he2)
   leftBreakpoint.halfEdge = he1
   rightBreakpoint.halfEdge = he2
   event.region.borderHead = he2 # following the convention that inside half-edges go counter-clockwise

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
   leftBreakpoint.halfEdge.isFixed = rightBreakpoint.halfEdge.isFixed = true

   # remembering breakpoint edges, because BeachLine.remove will likely change the breakpoints
   lBhe = leftBreakpoint.halfEdge
   rBhe = rightBreakpoint.halfEdge

   arc.prev.next = arc.next
   arc.next.prev = arc.prev
   newBreakpoint = BeachLine.remove(T, event.disappearingArc, (event.coordinates[1], event.coordinates[2]))

   # direction of the new halfedge, rotating clockwise around the arc to the right of the disappearing arc (always going down)
   dir = Geometry.rotateVectorCCW(Geometry.subVector(arc.prev.focus, arc.next.focus))

   # create new half edge for the newly formed breakpoint
   he1 = Diagram.HalfEdge(Geometry.addVector(event.center, dir), false, nothing, nothing, nothing)
   he2 = Diagram.HalfEdge(event.center, false, nothing, nothing, nothing)
   Diagram.makeTwins(he1, he2)
   push!(V.halfEdges, he1)
   push!(V.halfEdges, he2)
   newBreakpoint.halfEdge = he1 # he2 is left bound to the vertex
   he2.isFixed = true

   # join the adjacent edges in the region lists
   Diagram.concat(newBreakpoint.halfEdge, lBhe)
   Diagram.concat(rBhe.twin, newBreakpoint.halfEdge.twin)
   Diagram.concat(lBhe.twin, rBhe)

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

function finishDiagram(V::Diagram.DCEL, WIDTH::Number, HEIGHT::Number)
   function inbounds(p::Tuple{Number, Number})
      return (0 <= p[1] <= WIDTH) && (0 <= p[2] <= HEIGHT)
   end

   function shorten(he::Diagram.HalfEdge)
   end

   function lengthen(he::Diagram.HalfEdge)
   end

   # force edges inside the box and complete incomplete ones
   for he in V.halfEdges
      if inbounds(he.origin) || inbounds(he.twin.origin)
         # ignore Fis
         # lengthen Lis
         # shorten outbounds
         if !inbounds(he.origin)
            shorten(he)
         elseif !he.isFixed
            lengthen(he)
         end

         if !inbounds(he.twin.origin)
            shorten(he.twin)
         elseif !he.twin.isFixed
            lengthen(he.twin)
         end
      else
         # Fo/Fo = try to shorten both, delete case impossible
         # Fo/Lo = ?
         # Lo/Lo = ?
      end
   end

   #for he in V.halfEdges
   #   if outOfBounds(he) && outOfBounds(he.twin)
   #      println("DELETE: (", he.origin, ", ", he.twin.origin, ")")
   #      # delete it
   #   end
   #end
   #for he in V.halfEdges
   #   if he.isFixed
   #      println("FIXED: (", he.origin, ")")
   #   end
   #end
   #f0 = 0
   #f1 = 0
   #f2 = 0
   #for he in V.halfEdges
   #   fixed = 0
   #   if he.isFixed
   #      fixed += 1
   #   end
   #   if he.twin.isFixed
   #      fixed += 1
   #   end

   #   if fixed == 0
   #      f0 += 1
   #   elseif fixed == 1
   #      f1 += 1
   #   elseif fixed == 2
   #      f2 += 1
   #   end
   #   println(fixed, ": ", he.origin, ", ", he.twin.origin)
   #end
   #println(Int(f0/2), " ", Int(f1/2), " ", Int(f2/2))

   return V
end

function compute(points::Array{Tuple{Number, Number}, 1}, WIDTH, HEIGHT)
   V, T, Q = init(points)

   while (event = EventQueue.pop(Q)) != nothing
      Fortune.handleEvent(V, T, Q, event)
   end

   return Fortune.finishDiagram(V, WIDTH, HEIGHT)
end


end # module
