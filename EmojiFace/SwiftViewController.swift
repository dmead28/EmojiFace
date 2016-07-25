//
//  ViewController.swift
//  EmojiFace
//
//  Created by Douglas Mead on 7/13/16.
//  Copyright © 2016 Doug. All rights reserved.
//

import UIKit
import Affdex

/*
#define YOUR_AFFDEX_LICENSE_STRING_GOES_HERE @"{\"token\":\"81abf57be86a46dcdd97e18ad93ceb2e7392f7dc8a90f9ddafb94ae55bd41fa4\",\"licensor\":\"Affectiva Inc.\",\"expires\":\"2016-08-04\",\"developerId\":\"dmead3@gatech.edu\",\"software\":\"Affdex SDK\"}"
*/
let AFFDEX_LICENSE = "{\"token\":\"81abf57be86a46dcdd97e18ad93ceb2e7392f7dc8a90f9ddafb94ae55bd41fa4\",\"licensor\":\"Affectiva Inc.\",\"expires\":\"2016-08-04\",\"developerId\":\"dmead3@gatech.edu\",\"software\":\"Affdex SDK\"}"

class SwiftViewController: UIViewController, AFDXDetectorDelegate {
    
    // MARK: - Properties
    var detector: AFDXDetector!
    
    var cameraView: UIImageView!
    var overlayView: UIImageView!
    
    let emojiImage = UIImage(asset: .PlainFace)! // for now !
    
    // Used for experimenting with which point to use
    var variablePoint = 5
    
    var transformImageBlock: (()->Void)?
    
    var vizView: UIView!
    
    
    // MARK: - ViewController
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.createDetector()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.cameraView = UIImageView(frame: self.view.frame)
        self.overlayView = UIImageView(frame: self.view.frame)
        
        self.view.addSubview(cameraView)
        self.view.addSubview(overlayView)
        
        // Experimenting with which points to use
        //let recognizer = UITapGestureRecognizer(target: self, action: #selector(incrementVariablePoint))
        //self.view.addGestureRecognizer(recognizer)
        
        // Finding with un-warped points
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(setShouldPrint))
        self.view.addGestureRecognizer(recognizer)
        
        //testOpenCVPP()
        //testVisualizePoints()
        
    }
    
    
    // MARK: - Experimenting with choice of base points
    func testVisualizePoints() {
        let side: CGFloat = 200.0
        var points = [
            CGPoint(x: 0.05713493, y: 0.0217283) * side,
            CGPoint(x: 0.88429784, y: 0.0) * side,
            CGPoint(x: 0.50275656, y: 1.0) * side,
            CGPoint(x: 0.0, y: 0.50694122) * side,
            CGPoint(x: 0.97676785, y: 0.48737508) * side
        ]
        //points[0].x += 50.0
        points[1].x += 50.0
        points[2].x += 50.0
        //points[3].x += 50.0
        points[4].x += 50.0
        visualizePoints(points)
    }
    
    func visualizePoints(points: [CGPoint] = [CGPoint](), basePoints maybeBasePoints: [CGPoint]? = nil, side: CGFloat = 200.0, getAdjustedPoints shouldReturnNewPoints: Bool = false) -> [CGPoint] {
        
        // View must be square
        //let side: CGFloat = 200.0
        
        var basePoints: [CGPoint]
        if maybeBasePoints != nil {
            basePoints = maybeBasePoints!
        } else {
            // BasePoints found using findAve.py
            // TODO: Make points class rather than depending on array order
            basePoints = [
                CGPoint(x: 0.05713493, y: 0.0217283) * side + side/2.0,
                CGPoint(x: 0.88429784, y: 0.0) * side + side/2.0,
                CGPoint(x: 0.50275656, y: 1.0) * side + side/2.0,
                CGPoint(x: 0.0, y: 0.50694122) * side + side/2.0,
                CGPoint(x: 0.97676785, y: 0.48737508) * side + side/2.0
            ]
        }
        
        // Adjust normalized points
        var newPoints = [CGPoint]()
        for point in points {
            newPoints.append(point * side) // overloaded * operator
        }
        
        if self.vizView == nil {
            dispatch_async(dispatch_get_main_queue(), {
                self.vizView = UIView(frame: CGRect(x: 50.0, y: 50.0, width: side, height: side))
                self.vizView.backgroundColor = UIColor.whiteColor()
                self.view.addSubview(self.vizView)
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.vizView.removeFromSuperview()
                self.vizView = UIView(frame: CGRect(x: 50.0, y: 50.0, width: side, height: side))
                self.vizView.backgroundColor = UIColor.whiteColor()
                self.view.addSubview(self.vizView)
            })
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            let smiley = UIImage(asset: .PlainFace)
            self.vizView.layer.addSublayer(UIImageView(image: smiley).layer)
        })
        
        var pointsValue = [NSValue]()
        for point in newPoints {
            pointsValue.append(NSValue(CGPoint: point)) // make sure to adjust to size (side ~= longEdge)
        }
        var basePointsValue = [NSValue]()
        for point in basePoints {
            basePointsValue.append(NSValue(CGPoint: point))
        }
        
        // Warp image
        /*
        let newImage = OpenCVWrapper.warpSmiley(smiley, fromPoints: basePointsValue, toPoints: pointsValue, usingSize: self.view.frame.size)
        let newImageView = UIImageView(image: newImage)
        newImageView.frame.origin.x += 300.0
        newImageView.frame.origin.y += 300.0
        newImageView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(newImageView)
        */
        
        // Boilerplate circle drawing code from: http://stackoverflow.com/questions/29616992/how-do-i-draw-a-circle-in-ios-swift
        for point in basePoints {
            // TODO: Overload * operator (CGPoint and CGFloat)
            let circlePath = UIBezierPath(arcCenter: point, radius: 3.0, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = circlePath.CGPath
            shapeLayer.fillColor = UIColor.blueColor().CGColor
            shapeLayer.strokeColor = UIColor.redColor().CGColor
            shapeLayer.lineWidth = 1.0
            
            dispatch_async(dispatch_get_main_queue(), {
                self.vizView.layer.addSublayer(shapeLayer)
            })
        }
        for point in newPoints {
            // TODO: Overload * operator (CGPoint and CGFloat)
            let circlePath = UIBezierPath(arcCenter: point, radius: 3.0, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = circlePath.CGPath
            shapeLayer.fillColor = UIColor.greenColor().CGColor
            shapeLayer.strokeColor = UIColor.blueColor().CGColor
            shapeLayer.lineWidth = 1.0
            
            //print(point)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.vizView.layer.addSublayer(shapeLayer)
            })
        }
        
        // This is more for function syntactic sugar
        if shouldReturnNewPoints {
            return newPoints
        } else {
            return points
        }
    }
    
    
    // MARK: - Experimenting with OpenCV / Objective-C++ / all other bug prone stuff...
    func transformImage() {
        self.transformImageBlock?()
    }
    func testOpenCVPP() {
        
        // Experimenting with OpenCV / Objective-C++ / all other bug prone stuff...
        // Messy but temp
        print("Ready go!")
        let testView = UIView(frame: self.view.frame)
        self.view.addSubview(testView)
        
        let testImage = UIImage(asset: .PlainFace)!
        let testImageView = UIImageView(image: testImage)
        testView.addSubview(testImageView)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(transformImage))
        self.view.addGestureRecognizer(recognizer)
        self.transformImageBlock = {
            //testImageView.image = OpenCVWrapper.testConvertBackAndForth(testImage)
            //testImageView.image = OpenCVWrapper.warpSmiley(testImage) // needs new argument
        }
        
    }
    
    
    // MARK: - Experimenting with which points to use
    func incrementVariablePoint() {
        self.variablePoint = (self.variablePoint + 1) % 34 // Hard coded for now
    }
    
    func learningPoints(image: UIImage, facePointValues: [NSValue]) {
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), { [weak self] in
            
            guard let _ = self else { return } // Shouldn't happen (only one controller)
            
            UIGraphicsBeginImageContext(image.size)
            let ctx = UIGraphicsGetCurrentContext()
            
            // Experimenting to visualize which points I would like to use. Incremented green to figure out rough regions, then used red to more precisely determine.
            let green: CGFloat = 0.5 //0.1
            var red: CGFloat = 0.5
            
            let redPoints: Set<Int> = [0, 2, 4, 5, 10, self!.variablePoint]
            
            //print("Total: \(facePointValues.count)") // 34
            for (index, facePointValue) in facePointValues.enumerate() {
                
                let point = facePointValue.CGPointValue()
                //green += 0.04 // using red to fine tune
                red = redPoints.contains(index) ? 1.0 : 0.5
                
                CGContextSetLineWidth(ctx, 2.0)
                CGContextSetRGBStrokeColor(ctx, red, green, 0.5, 0.75)
                CGContextAddArc(ctx, point.x, point.y, 5.0, 0.0, 2 * CGFloat(M_PI), 1)
                CGContextStrokePath(ctx)
                
                let attrs = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 36)!]
                let pointString: NSString = "\(self!.variablePoint)"
                pointString.drawWithRect(CGRect(x: 50.0, y: 50.0, width: 100.0, height: 100.0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attrs, context: nil)
                
            }
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            self?.newImg = newImage
            
            UIGraphicsEndImageContext()
            
        })
    }
    
    func setShouldPrint() {
        print("Blah")
        self.shouldPrintPoints = true
    }
    
    
    // MARK: - Detector Delegate
    // From https://github.com/Affectiva/ios-sdk-samples
    func detector(detector: AFDXDetector!, hasResults faces: NSMutableDictionary?, forImage image: UIImage!, atTime time: NSTimeInterval) {
        if faces != nil {
            self.processedImageReady(detector, image: image, faces: faces!, atTime: time)
        } else {
            self.unprocessedImageReady(detector, image: image, atTime: time)
        }
    }
    
    
    // MARK: - Convenience methods
    var newImg: UIImage?
    var isProcessing = false // TODO: move all properties to Properties section
    var shouldPrintPoints = false
    func processedImageReady(detector: AFDXDetector, image: UIImage, faces: NSDictionary, atTime time: NSTimeInterval) {
        
        for valueObj in faces.allValues {
            
            guard let
                face = valueObj as? AFDXFace,
                emoji = EmojiSwift(rawValue: Int(face.emojis.dominantEmoji.rawValue)),
                facePointValues = face.facePoints as? [NSValue]
            else {
                print("ERROR in SwiftViewController.processedImageReady(): guard statement failed")
                return
            }
            
            print(emoji)
            
            // Leave this stuff to make writing the report easier
            //learningPoints(image, facePointValues: facePointValues)
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { [weak self] in
                
                guard let _ = self else { return } // Shouldn't happen (only one controller)
                
                if self!.isProcessing {
                    // Skip it
                    print("**** SKIPPED FRAME ****")
                    return
                }
                self!.isProcessing = true
                
                //let keyPoints: Set<Int> = [1, 2, 3, 5, 10]
                let keyPoints: Set<Int> = [1, 3, 5, 10]
                if self!.shouldPrintPoints {
                    print("****\nCGPoints for \(keyPoints): {")
                    for point in keyPoints {
                        print(facePointValues[point].CGPointValue())
                    }
                    print("}")
                    print(" ")
                    self!.shouldPrintPoints = false
                }
                
                UIGraphicsBeginImageContext(image.size)
                
                // View must be square
                var side: CGFloat = self!.emojiImage.size.height > self!.emojiImage.size.width ? self!.emojiImage.size.height : self!.emojiImage.size.width
                side /= 2.0
                
                // Found using findAve.py
                // TODO: Make points class rather than depending on array order
                let baseCGPoints = [
                    CGPoint(x: 0.0, y: 0.01475979) * side + side/2.0,
                    CGPoint(x: 0.9185254, y: 0.0) * side + side/2.0,
                    //CGPoint(x: 0.47270996, y: 1.0) * side + side/2.0,
                    CGPoint(x: 0.81183313, y: 0.79335999) * side + side/2.0,
                    CGPoint(x: 0.13385961, y: 0.80795644) * side + side/2.0
                ]
                var basePoints = [NSValue]()
                for baseCGPoint in baseCGPoints {
                    basePoints.append(NSValue(CGPoint: baseCGPoint))
                }
                
                /*
                let origin = facePointValues[5].CGPointValue()
                let botRight = facePointValues[4].CGPointValue()
                let bot = facePointValues[2].CGPointValue()
                let rect = CGRect(x: origin.x, y: origin.y, width: botRight.x - origin.x, height: bot.y - origin.y)
                */
                let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self!.view.frame.width, height: self!.view.frame.height))
                //self!.emojiImage.drawInRect(rect)
                
                var faceCGPointsRaw = [CGPoint]()
                for keyPoint in keyPoints {
                    faceCGPointsRaw.append(facePointValues[keyPoint].CGPointValue())
                }
                //let faceCGPoints = self!.visualizePoints(self!.normalizePoints(faceCGPointsRaw), getAdjustedPoints: true)
                let faceCGPoints = self!.visualizePoints(faceCGPointsRaw, basePoints: baseCGPoints, side: side, getAdjustedPoints: false)
 
                var facePoints = [NSValue]()
                for point in faceCGPoints {
                    facePoints.append(NSValue(CGPoint: point))
                }
                /*
                print(basePoints)
                print(facePoints)
                */
                let newSmileyImage = OpenCVWrapper.warpSmiley(self!.emojiImage, fromPoints: basePoints, toPoints: facePoints, usingSize: rect.size)
                newSmileyImage.drawInRect(rect)
                
                let ctx = UIGraphicsGetCurrentContext()
                for point in faceCGPoints {
                    let pointRect = CGRect(x: point.x, y: point.y, width: 5.0, height: 5.0)
                    CGContextSetFillColorWithColor(ctx, UIColor.greenColor().CGColor)
                    CGContextFillEllipseInRect(ctx, pointRect)
                }
                
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                self?.newImg = newImage
                
                UIGraphicsEndImageContext()
                
                self!.isProcessing = false
            })
            
        }
        
    }
    
    func normalizePoints(points: [CGPoint]) -> [CGPoint] {
        
        print(points)
        
        // Find max, min -> longEdge
        var maxPoint = points[0]
        var minPoint = points[0]
        
        for point in points {
            if point.x < minPoint.x {
                minPoint.x = point.x
            }
            if point.y < minPoint.y {
                minPoint.y = point.y
            }
            if point.x > maxPoint.x {
                maxPoint.x = point.x
            }
            if point.y > maxPoint.y {
                maxPoint.y = point.y
            }
        }
        
        print("min: \(minPoint) max: \(maxPoint)")
        
        let width = maxPoint.x - minPoint.x
        let height = maxPoint.y - minPoint.y
        print("width: \(width) height: \(height)")
        
        let longEdge = width > height ? width : height
        
        // Offset and divide
        var outputPoints = points
        for i in 0..<outputPoints.count {
            outputPoints[i].x -= minPoint.x
            outputPoints[i].y -= minPoint.y
            outputPoints[i].x /= longEdge
            outputPoints[i].y /= longEdge
        }
        
        //print(outputPoints)
        
        return outputPoints
    }
    
    func unprocessedImageReady(detector: AFDXDetector, image: UIImage, atTime time: NSTimeInterval) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            if self?.newImg != nil {
                print("^^^^ Placed")
                self?.overlayView.image = self!.newImg!
                self?.newImg = nil
            } else {
                self?.cameraView.image = image
            }
        }
    }
    
    
    // MARK: - Detector
    // From https://github.com/Affectiva/ios-sdk-samples
    func createDetector() {
        // ensure the detector has stopped
        self.destroyDetector()
        
        // create a new detector, set the processing frame rate in frames per second, and set the license string
        self.detector = AFDXDetector(delegate: self, usingCamera: AFDX_CAMERA_FRONT, maximumFaces: 1)
        self.detector.maxProcessRate = 5
        self.detector.licenseString = AFFDEX_LICENSE
        
        // turn on all classifiers (emotions, expressions, and emojis)
        
        self.detector.setDetectAllEmotions(true)
        self.detector.setDetectAllExpressions(true)
        self.detector.setDetectEmojis(true)
        
        // turn on gender and glasses
        self.detector.gender = true
        self.detector.glasses = true
        
        // start the detector and check for failure
        let error = self.detector.start()
        
        if error != nil {
            let alert = UIAlertController(title: "Detector Error", message: "Error starting detector in createDetector()", preferredStyle: .Alert)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    // From https://github.com/Affectiva/ios-sdk-samples
    func destroyDetector() {
        self.detector?.stop()
    }
    
}




