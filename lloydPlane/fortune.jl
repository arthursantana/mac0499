module Fortune
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
	#1. If T is empty, insert p i into it (so that T consists of a single leaf storing p i )
	#and return. Otherwise, continue with steps 2– 5.

	#2. Search in T for the arc α vertically above p i . If the leaf representing α has
	#a pointer to a circle event in Q, then this circle event is a false alarm and it
	#must be deleted from Q.

	#3. Replace the leaf of T that represents α with a subtree having three leaves.
	#The middle leaf stores the new site p i and the other two leaves store the site
	#p j that was originally stored with α. Store the tuples p j , p i  and p i , p j 
	#representing the new breakpoints at the two new internal nodes. Perform
	#rebalancing operations on T if necessary.

	BeachLine.insert(T, BeachLine.Arc(event.coordinates))

	#4. Create new half-edge records in the Voronoi diagram structure for the
	#edge separating V(p i ) and V(p j ), which will be traced out by the two new
	#breakpoints.

	#5. Check the triple of consecutive arcs where the new arc for p i is the left arc
	#to see if the breakpoints converge. If so, insert the circle event into Q and
	#add pointers between the node in T and the node in Q. Do the same for the
	#triple where the new arc is the right arc.
end

function handleEvent(V::DCEL.List, T::BeachLine.BST, Q::EventQueue.Heap, ev::EventQueue.CircleEvent)
   #1. Delete the leaf γ that represents the disappearing arc α from T. Update
   #the tuples representing the breakpoints at the internal nodes. Perform
   #rebalancing operations on T if necessary. Delete all circle events involving
   #α from Q; these can be found using the pointers from the predecessor and
   #the successor of γ in T. (The circle event where α is the middle arc is
   #currently being handled, and has already been deleted from Q.)

   #2. Add the center of the circle causing the event as a vertex record to the
   #doubly-connected edge list D storing the Voronoi diagram under construc-
   #tion. Create two half-edge records corresponding to the new breakpoint
   #of the beach line. Set the pointers between them appropriately. Attach the
   #three new records to the half-edge records that end at the vertex.

   #3. Check the new triple of consecutive arcs that has the former left neighbor
   #of α as its middle arc to see if the two breakpoints of the triple converge.
   #If so, insert the corresponding circle event into Q. and set pointers between
   #the new circle event in Q and the corresponding leaf of T. Do the same for
   #the triple where the former right neighbor is the middle arc.
end


end # module
