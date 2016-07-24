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
    
    
    // MARK: - ViewController
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.createDetector()
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
            testImageView.image = OpenCVWrapper.warpSmiley(testImage)
            //testImageView.image = OpenCVWrapper.testConvertBackAndForth(testImage)
        }
        
    }
    
    
    // MARK: - Experimenting with OpenCV / Objective-C++ / all other bug prone stuff...
    func transformImage() {
        self.transformImageBlock?()
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
    // From https://github.com/Affectiva/ios-sdk-samples
    var newImg: UIImage?
    var isProcessing = false // TODO: move all properties to Properties section
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
                    print("**** SKIPPED ****")
                    return
                }
                self!.isProcessing = true
                
                UIGraphicsBeginImageContext(image.size)
                
                let origin = facePointValues[5].CGPointValue()
                let botRight = facePointValues[4].CGPointValue()
                let bot = facePointValues[2].CGPointValue()
                let rect = CGRect(x: origin.x, y: origin.y, width: botRight.x - origin.x, height: bot.y - origin.y)
                self!.emojiImage.drawInRect(rect)
                
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                self?.newImg = newImage
                
                UIGraphicsEndImageContext()
                
                self!.isProcessing = false
            })
        }
        
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
    
    func destroyDetector() {
        // From https://github.com/Affectiva/ios-sdk-samples
        self.detector?.stop()
    }
    
}



enum EmojiSwift: Int {
    case Relaxed = 9786
    case Smiley = 128515
    case Laughing = 128518
    case Kissing = 128535
    case Disappointed = 128542
    case Rage = 128545
    case Smirk = 128527
    case Wink = 128521
    case TongueWink = 128540
    case Tongue = 128539
    case Flushed = 128563
    case Scream = 128561
    case None = 128528
}

