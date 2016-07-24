
import numpy as np

f = open('points.txt','r')

allPoints = []
currentPoints = []
counter = 0
for line in f:
	if line[0] == '(':
		splitLine = line.split(', ')
		point2d = [float(splitLine[0][1:]), float(splitLine[1][0:-3])]
		currentPoints.append(point2d)
		print point2d
	if line[0] == '}':
		allPoints.append(currentPoints)
		currentPoints = []
		print '------'

x = np.array(allPoints)
means = x.mean(axis=0)

print '\n\n******\nMeans:\n'
print means


maxs = means.max(axis=0)
mins = means.min(axis=0)
height = maxs[1] - mins[1]
width = maxs[0] - mins[0]
print '\n\n******\nInfo:\n'
print 'max',maxs
print 'min',mins
print "height",height,", width",width


longEdge = max(width, height)
print longEdge
for points in means:
	points[0] -= mins[0]
	points[1] -= mins[1]
	points[0] /= longEdge
	points[1] /= longEdge
print '\n\n******\nAdjusted means (normalized over square):\n'
print longEdge
print means


# x = np.array([[1, 100], [2, 110]])