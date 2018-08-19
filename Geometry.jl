module Geometry

# returns a function that describes a parabola defined by a focus p and a directrix of vertical component ly
function parabola(p::Tuple{Number, Number}, ly::Number)
   if p[2] == ly
      return nothing
   else
      return function (x)
         return (x^2 - 2p[1]*x + p[1]^2 + p[2]^2 -ly^2)/2(p[2] - ly)
      end
   end
end

function parabolaIntersection(p::Tuple{Number, Number}, q::Tuple{Number, Number}, ly::Number)
   f = parabola(p, ly)
   g = parabola(q, ly)

   if p[2] == ly && q[2] == ly # both degenerate parabolas, should never happen (unless we have two points exactly equal, which should never happen by hypothesis)
      return nothing
   elseif p[2] == ly
      point = (p[1], g(p[1]))
      return point
   elseif q[2] == ly
      point = (q[1], f(q[1]))
      return point
   end

   r = p[2] - ly
   s = q[2] - ly

   a = 1/r - 1/s
   b = 2(q[1]/s - p[1]/r)
   c = (p[1]^2 + p[2]^2 - ly^2)/r - (q[1]^2 + q[2]^2 - ly^2)/s

   delta = b^2 - 4a*c # discriminant

   if a == 0 # generating points of both parabolas have the same y
      x = (p[1] + q[1])/2
      return (x, f(x))
   end

   if delta < 0 # no intersection, should only happen when the first couple of points have the same y coordinate
      return nothing
   else
      x1 = (-b - sqrt(delta))/2a
      x2 = (-b + sqrt(delta))/2a

      if p[2] > q[2] # use left intersection
         if x1 < x2
            return (x1, f(x1))
         else
            return (x2, f(x2))
         end
      else # use right intersection
         if x1 > x2
            return (x1, f(x1))
         else
            return (x2, f(x2))
         end
      end
   end
end

function circumcircle(A::Tuple{Number, Number}, B::Tuple{Number, Number}, C::Tuple{Number, Number})
   # P is the midpoint between A and B
   P = ((A[1] + B[1])/2, (A[2] + B[2])/2)

   # v is a vector orthogonal to B-A; P + λv is the perpendicular bisector of AB, therefore the center of the circumcircle is in it
   v = (A[2] - B[2], B[1] - A[1])

   # Q is the midpoint between B and C
   Q = ((B[1] + C[1])/2, (B[2] + C[2])/2)

   # w is a vector orthogonal to C-B; Q + μw is the perpendicular bisector of BC, therefore the center of the circumcircle is in it
   w = (B[2] - C[2], C[1] - B[1])

   λ = (w[2]*(P[1] - Q[1]) + w[1]*(Q[2] - P[2])) / (w[1]*v[2] - w[2]*v[1])

   O = (P[1] + λ*v[1], P[2] + λ*v[2])

   r = sqrt((O[1] - A[1])^2 + (O[2] - A[2])^2)

   return O, r
end

function distance(A::Tuple{Number, Number}, B::Tuple{Number, Number})
   return sqrt((A[1]-B[1])^2 + (A[2]-B[2])^2)
end

# tests if middle arc of focus b will converge between foci a and c when the sweep line reaches ly
function arcWillConverge(a::Tuple{Number, Number}, b::Tuple{Number, Number}, c::Tuple{Number, Number})
   det = (b[1] - a[1])*(c[2] - a[2]) - (c[1] - a[1])*(b[2] - a[2])

   return (det < 0)
end

function addVector(a::Tuple{Number, Number}, b::Tuple{Number, Number})
   return (a[1] + b[1], a[2] + b[2])
end

function subVector(a::Tuple{Number, Number}, b::Tuple{Number, Number})
   return (a[1] - b[1], a[2] - b[2])
end

function rotateVectorCCW(a::Tuple{Number, Number})
   return (-a[2], a[1])
end

function multVector(c::Number, a::Tuple{Number, Number})
   return (c*a[1], c*a[2])
end

#function someParabolaIsWrong() # for debugging
#   NLINES = 1000
#   NPOINTSFOREACHLINE = 1000
#
#   function parabolaIsWrong(p::Tuple{Number, Number}, ly::Number)
#      MAX_ERROR = 10^(-5.0)
#
#      X = linspace(0, 100, 1000)
#      f = parabola(p, ly)
#
#      distanceFromLine = map(x -> f(x) - ly, X)
#      distanceFromPoint = map(x -> distance(p, (x, f(x))), X)
#
#      return any(i -> i > MAX_ERROR, distanceFromLine - distanceFromPoint)
#   end
#
#   lines = rand(0:20.0, NLINES)
#
#   for ly in lines
#      PX = rand(-100.0:100.0, NPOINTSFOREACHLINE)
#      PY = rand(ly:ly+200.0, NPOINTSFOREACHLINE)
#
#      for i in 1:NPOINTSFOREACHLINE
#         if parabolaIsWrong((PX[i], PY[i]), ly)
#            return true
#         end
#      end
#   end
#
#   return false
#end


end # module
