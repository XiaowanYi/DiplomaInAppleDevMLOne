//
//  ViewController.swift
//  FaceDetector
//
//  Created by XYI on 09/10/2022.
//

//import UIKit
import SwiftUI
import Vision

//class ViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//    }
//
//
//}

/*“add some @State variables to the ContentView:”*/

struct ContentView: View {
    
    /*Step 14: “These @State define the things that can change: whether the image picker is open, whether the camera is open, the image itself, and the faces detected.”*/
    @State private var imagePickerOpen: Bool = false
    @State private var cameraOpen: Bool = false
    @State private var image: UIImage? = nil
    @State private var faces: [VNFaceObservation]? = nil
    
    /*Step 15: “These store the face count, the placeholder image (displayed until the user chooses an image), the availability of a camera, and whether detection (which is reflected in the availability of the button) is enabled.”*/
    private var faceCount: Int { return faces?.count ?? 0 }
    private let placeholderImage = UIImage(named: "placeholder")!

    private var cameraEnabled: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    private var detectionEnabled: Bool { image != nil && faces == nil }
    
    /*Step 16: “The body View returns the image picker if the image picker should be open, the camera likewise; otherwise, it returns mainView(), which is the function that we added to the ContentView by way of an extension, earlier.”*/
    var body: some View {
        if imagePickerOpen { return imagePickerView() }
        if cameraOpen { return cameraView() }
        return mainView()
    }
    
    /*Step 17: “This function calls the detectFaces() function, which we added earlier, as an extension on UIImage in the Faces.swift file, calling it on the current image.”*/
    private func getFaces() {
        print("Getting faces...")
        self.faces = []
        self.image?.detectFaces { result in
            self.faces = result
            
            /*Step improve-5: “Update the getFaces() function in ContentView.swift to call the new drawnOn() function”*/
            if let image = self.image,
            let annotatedImage = result?.drawnOn(image) {
                        self.image =  annotatedImage
                    }
            }
        
        
    }
    
    /*Step 18: “a function to display the image picker”*/
    private func summonImagePicker() {
        print("Summoning ImagePicker...")
        imagePickerOpen = true
    }
    
    /*Step 19: the camera*/
    private func summonCamera() {
        print("Summoning camera...")
        cameraOpen = true
    }
    
    /*the extra*/
    private func controlReturned(image: UIImage?) {
            print("Image return \(image == nil ? "failure" : "success")...")
            self.image = image?.fixOrientation()
            self.faces = nil
        }

}


/*ContentView ViewController*/
extension ContentView {
    /*“This function not only returns our main view, but also creates it.”*/
    private func mainView() -> AnyView {
        return AnyView(NavigationView {
            MainView(
                image: image ?? placeholderImage,
                text: "\(faceCount) face\(faceCount == 1 ? "" : "s")") {
                    TwoStateButton(
                        text: "Detect Faces",
                        disabled: !detectionEnabled,
                        action: getFaces
                    )
            }
            .padding()
            .navigationBarTitle(Text("sticky-emoji"), displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: summonImagePicker) {
                    Text("Select")
                    
                    },
                                trailing: Button(action: summonCamera) {
                                    Image(systemName: "camera")
                                }.disabled(!cameraEnabled)
                            )
                        })
                    }
    
    /*“a function to return the image picker”*/
    
    private func imagePickerView() -> AnyView {
        return  AnyView(ImagePicker { result in
            self.controlReturned(image: result)
            self.imagePickerOpen = false
        })
    }
    
    /*“a function to return a camera view”*/
    private func cameraView() -> AnyView {
        return  AnyView(ImagePicker(camera: true) { result in
            self.controlReturned(image: result)
            self.cameraOpen = false
        })
    }

}
