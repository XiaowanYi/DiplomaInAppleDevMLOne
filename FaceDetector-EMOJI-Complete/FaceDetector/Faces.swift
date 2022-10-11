//
//  Faces.swift
//  FaceDetector
//
//  Created by XYI on 09/10/2022.
//

import UIKit
import Vision

extension UIImage {
    func detectFaces(completion: @escaping ([VNFaceObservation]?) -> ()) {
        guard let image = self.cgImage else { return completion(nil) }
        let request = VNDetectFaceLandmarksRequest()
        
        DispatchQueue.global().async {
            let handler = VNImageRequestHandler(
                cgImage: image,
                orientation: self.cgImageOrientation
            )
            
            try? handler.perform([request])
            
            guard let observations =
                    request.results as? [VNFaceObservation] else {
                return completion(nil)
            }
            
            completion(observations)
        }
    }
    
    /*Step emoji-1: “This function returns a UIImage that’s been rotated by the degrees specified as a CGFloat, in either a clockwise or counterclockwise direction.”*/
    func rotatedBy(degrees: CGFloat, clockwise: Bool = false) -> UIImage? {
        var radians = (degrees) * (.pi / 180)
        
        if !clockwise {
            radians = -radians
        }
        let transform = CGAffineTransform(rotationAngle: CGFloat(radians))
        
        let newSize = CGRect(
            origin: CGPoint.zero,
            size: self.size
        ).applying(transform).size
        
        let roundedSize = CGSize(
            width: floor(newSize.width),
            height: floor(newSize.height))
        
        let centredRect = CGRect(
            x: -self.size.width / 2,
            y: -self.size.height / 2,
            width: self.size.width,
            height: self.size.height)
        
        UIGraphicsBeginImageContextWithOptions(
            roundedSize,
            false,
            self.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.translateBy(
            x: roundedSize.width / 2,
            y: roundedSize.height / 2
        )
        
        context.rotate(by: radians)
        self.draw(in: centredRect)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
    
    
}

/*Step emoji-7: “To cut a long story short, this extension (and its new drawnOn() function) draws a random emoji on top of the face.”*/
extension Collection where Element == VNFaceObservation {
    func drawnOn(_ image: UIImage) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, 1.0)
        guard let _ = UIGraphicsGetCurrentContext() else { return nil }
        
        image.draw(in: CGRect(
            x: 0,
            y: 0,
            width: image.size.width,
            height: image.size.height)
        )
        
        let imageSize: (width: Int, height: Int) =
        (Int(image.size.width), Int(image.size.height))
        
        let transform = CGAffineTransform(scaleX: 1, y: -1)
            .translatedBy(x: 0, y: -image.size.height)
        
        let padding: CGFloat = 0.3
        
        for observation in self {
            guard let anchor =
                    observation.landmarks?.anchorPointInImage(image) else {
                continue
            }
            
            guard let center = anchor.center?.applying(transform) else {
                continue
            }
            
            let overlayRect = VNImageRectForNormalizedRect(
                observation.boundingBox,
                imageSize.width,
                imageSize.height
            ).applying(transform).centeredOn(center)
            
            let insets = (
                x: overlayRect.size.width * padding,
                y: overlayRect.size.height * padding)
            
            let paddedOverlayRect = overlayRect.insetBy(
                dx: -insets.x,
                dy: -insets.y)
            
            let randomEmoji = [
                "🙂",
                "😁",
                "😊",
                "🤨",
                "😕",
                "🙄",
                "😬",
                "😮",
                "😴"
            ].randomElement()!
            if var overlayImage = randomEmoji
                .image(of: paddedOverlayRect.size) {
                
                if let angle = anchor.angle,
                   let rotatedImage = overlayImage
                    .rotatedBy(degrees: angle) {
                    
                    overlayImage = rotatedImage
                }
                
                overlayImage.draw(in: paddedOverlayRect)
            }
        }
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
}

/* Step emoji-2: “VNFaceLandmarks2D represents all of the landmarks that Apple’s Vision framework can detect in a face, exposed as properties” */
extension VNFaceLandmarks2D {
    func anchorPointInImage(_ image: UIImage) ->
    (center: CGPoint?, angle: CGFloat?) {
        
        // centre each set of points that may have been detected, if
        // present
        let allPoints =
        self.allPoints?.pointsInImage(imageSize: image.size)
            .centerPoint
        
        let leftPupil =
        self.leftPupil?.pointsInImage(imageSize: image.size)
            .centerPoint
        
        let leftEye =
        self.leftEye?.pointsInImage(imageSize: image.size)
            .centerPoint
        
        let leftEyebrow =
        self.leftEyebrow?.pointsInImage(imageSize: image.size)
            .centerPoint
        let rightPupil =
        self.rightPupil?.pointsInImage(imageSize: image.size)
            .centerPoint
        
        let rightEye =
        self.rightEye?.pointsInImage(imageSize: image.size)
            .centerPoint
        
        let rightEyebrow =
        self.rightEyebrow?.pointsInImage(imageSize: image.size)
            .centerPoint
        
        let outerLips =
        self.outerLips?.pointsInImage(imageSize: image.size)
            .centerPoint
        
        let innerLips =
        self.innerLips?.pointsInImage(imageSize: image.size)
            .centerPoint
        
        let leftEyeCenter = leftPupil ?? leftEye ?? leftEyebrow
        let rightEyeCenter = rightPupil ?? rightEye ?? rightEyebrow
        let mouthCenter = innerLips ?? outerLips
        
        if let leftEyePoint = leftEyeCenter,
           let rightEyePoint = rightEyeCenter,
           let mouthPoint = mouthCenter {
            
            let triadCenter =
            [leftEyePoint, rightEyePoint, mouthPoint]
                .centerPoint
            
            let eyesCenter =
            [leftEyePoint, rightEyePoint]
                .centerPoint
            
            return (eyesCenter, triadCenter.rotationDegreesTo(eyesCenter))
        }
        // else fallback
        return (allPoints, 0.0)
    }
}

/*Step emoji-3: “an extension on CGRect that returns a CGRect centered on a CGPoint provided:”*/
extension CGRect {
    func centeredOn(_ point: CGPoint) -> CGRect {
        let size = self.size
        let originX = point.x - (self.width / 2.0)
        let originY = point.y - (self.height / 2.0)
        return CGRect(
            x: originX,
            y: originY,
            width: size.width,
            height: size.height
        )
    }
}

/*Step emoji-4: “an extension on CGPoint” “This extension adds a function called rotationDegreesTo() that returns some degrees to rotate by, given another point. This helps orient facial features with the emoji we’ll be drawing on the face.”*/
extension CGPoint {
    func rotationDegreesTo(_ otherPoint: CGPoint) -> CGFloat {
        let originX = otherPoint.x - self.x
        let originY = otherPoint.y - self.y
        
        let degreesFromX = atan2f(
            Float(originY),
            Float(originX)) * (180 / .pi)
        
        let degreesFromY = degreesFromX - 90.0
        
        let normalizedDegrees = (degreesFromY + 360.0)
            .truncatingRemainder(dividingBy: 360.0)
        
        return
        CGFloat(normalizedDegrees)
    }
}

/*Step emoji-5: “an extension on Array, for arrays of CGPoints” “This adds a function, centerPoint(), which returns a CGPoint for an array of points.”*/
extension Array where Element == CGPoint {
    var centerPoint: CGPoint {
        let elements = CGFloat(self.count)
        let totalX = self.reduce(0, { $0 + $1.x })
        let totalY = self.reduce(0, { $0 + $1.y })
        return CGPoint(x: totalX / elements, y: totalY / elements)
    }
}

/*Step emoji-6: “Because we’re working with emojis, which are actually text, we also need an extension on String” “This allows us to get a UIImage from a String, which is useful because we want to be able to display emojis on top of an image, and we want those emojis to be images.”*/
extension String {
    func image(of size: CGSize, scale: CGFloat = 0.94) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(
            in: rect,
            withAttributes: [
                .font: UIFont.systemFont(ofSize: size.height * scale)
            ]
        )
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image
    }
}


