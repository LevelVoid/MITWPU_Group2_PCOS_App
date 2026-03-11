//
//  GIF Manager.swift
//  PCOS_App
//
//  Created by SDC-USER on 15/12/25.
//
import UIKit
import ImageIO

final class GIFManager {

    static let shared = GIFManager()
    private init() {}

    private let cache = NSCache<NSString, UIImage>()

    func gif(named name: String) -> UIImage? {

        //  Return cached GIF if available
        if let cached = cache.object(forKey: name as NSString) {
            return cached
        }

        // Load from Assets
        guard let asset = NSDataAsset(name: name.replacingOccurrences(of: ".gif", with: "")) else {
            return nil
        }

        guard let gifImage = UIImage.gifImageWithData(asset.data) else {
            return nil
        }

        //  Cache it
        cache.setObject(gifImage, forKey: name as NSString)

        return gifImage
    }
}
/*
 Why this is important
 GIF decoded once
 Reused everywhere
 Smooth scrolling
 Centralized logic
 */
