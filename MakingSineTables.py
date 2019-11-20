import math
import numpy as np 
from matplotlib import pyplot as plt

step = (2* math.pi)/64

def guitar_attempt(num):
	pi = math.pi
	s = math.sin
	return (s(num) + s(2*num) + s(3*num) )

# def shift for 

values = []
sum_ = -2 * math.pi
for i in range(64):
	# values.append(math.sin(sum_))
	values.append(guitar_attempt(sum_*.9))
	sum_ += (2*math.pi)/64

original_values = values.copy()
values.reverse()
graph = values + original_values
plt.title("Matplotlib demo") 
plt.xlabel("x axis caption") 
plt.ylabel("y axis caption") 
plt.plot(graph) 
plt.show()

graph2 = []
for i in graph:
	graph2.append(round(i *128/2.5) + 128)


plt.title("Graph2") 
plt.xlabel("x axis caption") 
plt.ylabel("y axis caption") 
plt.plot(graph2, "ro") 
plt.show()

print(graph2)


