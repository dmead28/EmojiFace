//
//  ImageAssets.swift
//  CameraTest
//
//  Created by Douglas Mead on 7/20/16.
//  Copyright © 2016 Affectiva. All rights reserved.
//

import UIKit

/*
enum ImageAssets: String {
    case Relaxed
    case Smiley
    case Laughing
    case Kissing
    case Disappointed
    case Rage
    case Smirk
    case Wink
    case TongueWink
    case Tongue
    case Flushed
    case Scream
    case None
}

extension UIImage {
    convenience init?(asset: ImageAssets) {
        self.init(named: asset.rawValue)
    }
}
*/



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
    
    private struct Images {
        static let Relaxed = UIImage(named: "Relaxed")
        static let Smiley = UIImage(named: "Smiley")
        static let Laughing = UIImage(named: "Laughing")
        static let Kissing = UIImage(named: "Kissing")
        static let Disappointed = UIImage(named: "Disappointed")
        static let Rage = UIImage(named: "Rage")
        static let Smirk = UIImage(named: "Smirk")
        static let Wink = UIImage(named: "Wink")
        static let TongueWink = UIImage(named: "TongueWink")
        static let Tongue = UIImage(named: "Tongue")
        static let Flushed = UIImage(named: "Flushed")
        static let Scream = UIImage(named: "Scream")
        static let None = UIImage(named: "None")
    }
    
    var image: UIImage? {
        switch self {
        case Relaxed:
            return Images.Relaxed
        case Smiley:
            return Images.Smiley
        case Laughing:
            return Images.Laughing
        case Kissing:
            return Images.Kissing
        case Disappointed:
            return Images.Disappointed
        case Rage:
            return Images.Rage
        case Smirk:
            return Images.Smirk
        case Wink:
            return Images.Wink
        case TongueWink:
            return Images.TongueWink
        case Tongue:
            return Images.Tongue
        case Flushed:
            return Images.Flushed
        case Scream:
            return Images.Scream
        case None:
            return Images.None
        }
    }
    
}



func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
}

func +(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x + rhs, y: lhs.y + rhs)
}


