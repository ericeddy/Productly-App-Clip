//
//  ImageCache.swift
//  Productly
//
//  Created by Eric Eddy on 2026-02-21.
//

import SwiftUI
import UIKit

class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
    
    init() {
        ImageCache.shared.countLimit = 100
        ImageCache.shared.totalCostLimit = 25 * 1024 * 1024 // 25MB
    }
}
