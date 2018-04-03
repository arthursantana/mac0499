using PyPlot
using PyCall
@pyimport matplotlib.animation as anim

#Construct Figure and Plot Data
fig = figure("MyFigure",figsize=(5,5))
ax = axes(xlim = (0,10),ylim=(0,10))
global line1 = ax[:plot]([],[],"r-")[1]
global line2 = ax[:plot]([],[],"g-")[1]
global line3 = ax[:plot]([],[],"b-")[1]

# Define the init function, which draws the first frame (empty, in this case)
function init()
    global line1
    global line2
    global line3
    line1[:set_data]([],[])
    line2[:set_data]([],[])
    line3[:set_data]([],[])
    return (line1,line2,line3,Union{})  # Union{} is the new word for None
end

# Animate draws the i-th frame, where i starts at i=0 as in Python.
function animate(i)
    global line1
    global line2
    global line3
    x = (0:i)/10.0
    line1[:set_data](x,x)
    line2[:set_data](1+x,x)
    line3[:set_data](2+x,x)
    return (line1,line2,line3,Union{})
end

# Create the animation object by calling the Python function FuncAnimaton
myanim = anim.FuncAnimation(fig, animate, init_func=init, frames=100, interval=20)
show()
