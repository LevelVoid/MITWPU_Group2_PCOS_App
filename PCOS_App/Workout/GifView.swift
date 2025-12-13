//
//  GifView.swift
//  PCOS_App
//
//  Created by SDC-USER on 13/12/25.
//


import UIKit
import ImageIO

extension UIImage {

    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }

        let count = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        var duration: Double = 0

        for i in 0..<count {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else { continue }
            images.append(UIImage(cgImage: cgImage))
            duration += 0.1
        }

        return UIImage.animatedImage(with: images, duration: duration)
    }
}
