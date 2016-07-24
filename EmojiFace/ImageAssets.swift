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