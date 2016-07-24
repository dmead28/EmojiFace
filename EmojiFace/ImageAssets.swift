//
//  ImageAssets.swift
//  CameraTest
//
//  Created by Douglas Mead on 7/20/16.
//  Copyright © 2016 Affectiva. All rights reserved.
//

import UIKit

enum ImageAssets: String {
    case PlainFace
}


extension UIImage {
    convenience init?(asset: ImageAssets) {
        self.init(named: asset.rawValue)
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



func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
}


