//
//  ExtensionClass.swift
//  SkibidiCrush
//
//  Created by Cipher Lunis on 7/19/24.
//

import Foundation
import UIKit
import SpriteKit

extension UIImage {
    func resizeImageTo(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
       
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
       
        return resizedImage
    }
   
    func applyBlackAndWhiteFilter() -> UIImage? {
        let context = CIContext(options: nil)
        guard let ciImage = CIImage(image: self),
              let filter = CIFilter(name: "CIColorControls") else {
            return nil
        }
       
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(0.0, forKey: kCIInputSaturationKey)
       
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
       
        return UIImage(cgImage: cgImage)
    }
}

extension SKSpriteNode {
    func drawBorder(color: UIColor, width: CGFloat) {
        let shapeNode = SKShapeNode(rect: frame)
        shapeNode.fillColor = .clear
        shapeNode.strokeColor = color
        shapeNode.lineWidth = width
        addChild(shapeNode)
    }
}
