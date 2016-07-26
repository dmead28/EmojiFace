# Final Project
# Douglas Mead
# dmead3@gatech.edu


import os
import cv2
import numpy as np
import scipy as sp

def warpSmiley():

	# http://www.learnopencv.com/homography-examples-using-opencv-python-c/

    image = cv2.imread('normalFace.png')

    maxPixelY = image.shape[0] - 1
    maxPixelX = image.shape[1] - 1

    leftEye = [163, 213]
    rightEye = [163 + 185, 213]
    leftMouth = [163 - 15, 213 + 100 + 10]
    rightMouth = [163 + 185 + 15, 213 + 100 + 10]

    originalPoints = np.array([
		leftEye,
		rightEye,
		leftMouth,
		rightMouth,
    ]).astype(np.float)

    frownOffset = 100
    newPoints = np.array([
		[leftEye[0], leftEye[1]],
		[rightEye[0], rightEye[1]],
		[leftMouth[0], leftMouth[1] + frownOffset],
		[rightMouth[0], rightMouth[1] + frownOffset],
    ]).astype(np.float)

    """
    originalPoints = np.array([
    	[0,0], 
    	[0, maxPixelY], 
    	[maxPixelX, 0], 
    	[maxPixelX, maxPixelY]
    ]).astype(np.float)

    scaleOffset = 0
    rightSidePerspect = 200
    newPoints = np.array([
    	[0 + scaleOffset, 0 + scaleOffset], # Top - Left
    	[0 + scaleOffset, maxPixelY - scaleOffset], # Bottom - Left
    	[maxPixelX - scaleOffset, 0 + scaleOffset + rightSidePerspect], # Top - Right
    	[maxPixelX - scaleOffset, maxPixelY - scaleOffset - rightSidePerspect] # Bottom - Right
    ]).astype(np.float)
    """

    """
    newPoints = np.array([
    	[0,0], # Top - Left
    	[0, maxPixelY], # Bottom - Left
    	[maxPixelX, 0], # Top - Right
    	[maxPixelX, maxPixelY] # Bottom - Right
    ]).astype(np.float)
 	"""

    # Calculate Homography
    h, status = cv2.findHomography(originalPoints, newPoints)

    print "h", h
    print "status", status
     
    # Warp source image to destination based on homography
    newImage = cv2.warpPerspective(image, h, (image.shape[1],image.shape[0]))
    #newImageTransform = cv2.perspectiveTransform(image, h)

    # Show points (5x5 square)
    squareSize = 10
    for point in originalPoints:
	    for i in range(squareSize):
	    	for j in range(squareSize):
	    		x = point[0] + i - squareSize/2
	    		y = point[1] + j - squareSize/2
	    		if not (x > len(image) - 1 or x < 0 or y > len(image[0]) - 1 or y < 0):
	    			image[y][x] = [100., 200., 0.]

    for point in newPoints:
	    for i in range(squareSize):
	    	for j in range(squareSize):
	    		x = point[0] + i - squareSize/2
	    		y = point[1] + j - squareSize/2
	    		if not (x > len(image) - 1 or x < 0 or y > len(image[0]) - 1 or y < 0):
	    			image[y][x] = [255., 0., 0.]


    # Save images (if necessary)
    saveReason = ""
    if len(saveReason) > 0:
    	originalStr = "ReportImages/" + saveReason + "_orig.png"
    	newStr = "ReportImages/" + saveReason + "_new.png"

    	cv2.imwrite(originalStr, image)
    	cv2.imwrite(newStr, newImage)
     
    # Display images
    cv2.imshow("WarpPerspective Image", newImage)
    #cv2.imshow("PerspectiveTransform Image", newImageTransform)
    cv2.imshow("Source Image with Points", image)
 
    cv2.waitKey(0)

if __name__ == '__main__' :
	warpSmiley()









