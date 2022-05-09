//
//  Extensions.swift
//  pdfFiller
//
//  Created by Kostyukevich Ilya on 04.05.2022.
//

import Foundation
import UIKit

extension NSObject {
    class var className: String {
        return String(describing: self)
    }
}

extension UIImage {
    var flattened: UIImage? {
        guard let ciImage = CIImage(image: self),
              let openGLContext = EAGLContext(api: .openGLES2) else { return nil }
        
        let ciContext = CIContext(eaglContext: openGLContext)
        
        guard let detector = CIDetector(ofType: CIDetectorTypeRectangle,
                                        context: ciContext,
                                        options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]),
              let rect = detector.features(in: ciImage).first as? CIRectangleFeature,
              let perspectiveCorrection = CIFilter(name: "CIPerspectiveCorrection") else { return nil }

        perspectiveCorrection.setValue(CIVector(cgPoint: rect.topLeft), forKey: "inputTopLeft")
        perspectiveCorrection.setValue(CIVector(cgPoint: rect.topRight), forKey: "inputTopRight")
        perspectiveCorrection.setValue(CIVector(cgPoint: rect.bottomRight), forKey: "inputBottomRight")
        perspectiveCorrection.setValue(CIVector(cgPoint: rect.bottomLeft), forKey: "inputBottomLeft")
        perspectiveCorrection.setValue(ciImage, forKey: kCIInputImageKey)

        if let output = perspectiveCorrection.outputImage,
            let cgImage = ciContext.createCGImage(output, from: output.extent) {
            
            return UIImage(cgImage: cgImage,
                           scale: scale,
                           orientation: imageOrientation)
        }

        return nil
    }
    
    func imageByApplyingMask(_ path: UIBezierPath) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        context.saveGState()
        path.addClip()
        
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        guard let maskedImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }

        context.restoreGState()
        UIGraphicsEndImageContext()

        return maskedImage
    }
}
