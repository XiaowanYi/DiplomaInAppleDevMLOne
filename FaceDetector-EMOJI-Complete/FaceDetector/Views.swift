//
//  Views.swift
//  FaceDetector
//
//  Created by XYI on 10/10/2022.
//

import Foundation
import SwiftUI

/*“The TwoStateButton struct defines a Button that can be enabled or disabled, change color, and otherwise do button-y things. Very useful.” */

struct TwoStateButton: View {
    private let text: String
    private let disabled: Bool
    private let background: Color
    private let action: () -> Void

    
    /*“The body handles the drawing of the TwoStateButton (which actually just draws a Button and some Text, based on the values of the variables).*/
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(text).font(.title).bold().foregroundColor(.white)
                Spacer()
                }.padding().background(background).cornerRadius(10)
            }.disabled(disabled)
    }
    
    /*The init() function initializes a new ThreeStateButton to certain parameters (text, whether it’s disabled, a background color, and an action when the button is pressed).*/
    init(text: String,
        disabled: Bool,
        background: Color = .blue,
        action: @escaping () -> Void) {

        self.text = text
        self.disabled = disabled
        self.background = disabled ? .gray : background
        self.action = action
    }
}

/*This View has some variables to store a UIImage, a String, and a  TwoStateButton (which we created a moment ago!) */
struct MainView: View {
    private let image: UIImage
    private let text: String
    private let button: TwoStateButton
    
    
    /*The body draws an Image, some Spacers, some Text, and a TwoStateButton (defined by the variable). */
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            Spacer()
            Text(text).font(.title).bold()
            Spacer()
            self.button
        }
    }
    
    /*The init() function creates the MainView, setting the value of the image, the text, and the button.*/
    init(image: UIImage, text: String, button: () -> TwoStateButton) {
        self.image = image
        self.text = text
        self.button = button()
    }

}

/*“summon a UIImagePicker, which is part of the older UIKit framework, from within SwiftUI
 
 About UIViewControllerRepresentable:
 “you use it to fake the abilities of a UIKit view when you’re using SwiftUI. Essentially, it’s a way to bridge features of the older UI framework with the new one.”
 */

struct ImagePicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    private(set) var selectedImage: UIImage?
    private(set) var cameraSource: Bool
    private let completion: (UIImage?) -> ()

    init(camera: Bool = false, completion: @escaping (UIImage?) -> ()) {
        self.cameraSource = camera
        self.completion = completion
    }

    func makeCoordinator() -> ImagePicker.Coordinator {
        let coordinator = Coordinator(self)
        coordinator.completion = self.completion
        return coordinator
    }

    func makeUIViewController(context: Context)
        -> UIImagePickerController {

        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = context.coordinator
        imagePickerController.sourceType =
            cameraSource ? .camera : .photoLibrary

        return imagePickerController
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate,
        UINavigationControllerDelegate {

        var parent: ImagePicker
        var completion: ((UIImage?) -> ())?

        init(_ imagePickerControllerWrapper: ImagePicker) {
            self.parent = imagePickerControllerWrapper
        }

        func imagePickerController(_ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info:
                [UIImagePickerController.InfoKey: Any]) {

            print("Image picker complete...")

            let selectedImage =
                info[UIImagePickerController.InfoKey.originalImage]
                    as? UIImage

            picker.dismiss(animated: true)
            completion?(selectedImage)
        }

        func imagePickerControllerDidCancel(
                _ picker: UIImagePickerController) {

            print("Image picker cancelled...")
            picker.dismiss(animated: true)
            completion?(nil)
        }
    }
}

extension UIImage {
    func fixOrientation() -> UIImage? {
        UIGraphicsBeginImageContext(self.size)
        self.draw(at: .zero)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    var cgImageOrientation: CGImagePropertyOrientation {
        switch self.imageOrientation {
            case .up: return .up
            case .down: return .down
            case .left: return .left
            case .right: return .right
            case .upMirrored: return .upMirrored
            case .downMirrored: return .downMirrored
            case .leftMirrored: return .leftMirrored
            case .rightMirrored: return .rightMirrored
        }
    }
}
