import PyPlot

plt = PyPlot
plt.pygui(:qt)
ax = plt.gca() # get current axes
ax[:set_xlim]([1, 10])
ax[:set_ylim]([1, 3000])
#plt[:axis]("off")
plt.title("Testando animações interativas")
ax[:grid]("off")
ax[:get_xaxis]()[:set_visible](false)
ax[:get_yaxis]()[:set_visible](false)
plt.ion()

x = linspace(1, 10, 10000)
y = map(a -> a^2, x)
z = map(a -> a^3, x)

F = ax[:fill](x, y)
plt.show()

println("aperte enter para continuar...")
readline(STDIN)
F[1][:remove]()
F = ax[:fill](x, z)
println("aperte enter para continuar...")
readline(STDIN)
F[1][:remove]()
F = ax[:fill](x, 2*z)
println("aperte enter para continuar...")
readline(STDIN)
F[1][:remove]()
F = ax[:fill](x, 3*z)
println("aperte enter para continuar...")
readline(STDIN)
F[1][:remove]()
F = ax[:fill](x, 4*z)
println("aperte enter para continuar...")
readline(STDIN)

#plt.draw()
