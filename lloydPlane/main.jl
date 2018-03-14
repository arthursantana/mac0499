using Cairo

function circumcircle(Ax, Ay, Bx, By, Cx, Cy)
   Px = (Ax + Bx)/2
   Py = (Ay + By)/2

   # v is a vector orthogonal to B-A; P + λv is the perpendicular bisector of AB, therefore the center of the circumcircle is in it
   vx = Ay - By
   vy = Bx - Ax

   Qx = (Bx + Cx)/2
   Qy = (By + Cy)/2

   # w is a vector orthogonal to C-B; Q + μw is the perpendicular bisector of BC, therefore the center of the circumcircle is in it
   wx = By - Cy
   wy = Cx - Bx

   λ = (wy*(Px - Qx) + wx*(Qy - Py)) / (wx*vy - wy*vx)

   Cx = Px + λ*vx
   Cy = Py + λ*vy

   r = sqrt((Cx - Ax)^2 + (Cy - Ay)^2)

   return Cx, Cy, r, Px, Py, Qx, Qy
end

width = 800
height = 800

c = CairoRGBSurface(width,height)
cr = CairoContext(c)

save(cr)
set_source_rgb(cr, 1, 1, 1)
rectangle(cr, 0.0, 0.0, width, height) # background
fill(cr)
restore(cr)

x = rand(30) * width
y = rand(30) * height

set_source_rgba(cr, 0.2, 0.2, 1, 0.6)
set_line_width(cr, 1.0)

for point in zip(x, y)
   arc(cr, point[1], point[2], 4.0, 0, 2*pi)
   fill(cr)
end
stroke(cr)

#scatter(x, y, title="Delaunay Triangulation", label="")

# considering now the triangle 0, 1, 2

set_line_width(cr, 3.0);
set_source_rgba(cr, 0, 0, 0, 0.6)
move_to(cr, x[1], y[1])
line_to(cr, x[2], y[2])
line_to(cr, x[3], y[3])
line_to(cr, x[1], y[1])
stroke(cr)

Cx, Cy, r, Px, Py, Qx, Qy = circumcircle(x[1], y[1], x[2], y[2], x[3], y[3])

set_source_rgba(cr, 1, 0.2, 0.2, 0.6)
arc(cr, Px, Py, 4.0, 0, 2*pi)
arc(cr, Qx, Qy, 4.0, 0, 2*pi)
fill(cr)

move_to(cr, Px, Py)
line_to(cr, Cx, Cy)
move_to(cr, Qx, Qy)
line_to(cr, Cx, Cy)
stroke(cr)

set_source_rgba(cr, 0.1, 0.6, 0.1, 0.6)
arc(cr, Cx, Cy, 4.0, 0, 2*pi)
fill(cr)

arc(cr, Cx, Cy, r, 0, 2*pi)
move_to(cr, Cx, Cy)
line_to(cr, x[1], y[1])
stroke(cr)







write_to_png(c,"fig.png")
