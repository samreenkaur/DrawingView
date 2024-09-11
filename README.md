# DrawingView

`DrawingView` is a Swift package designed for iOS to facilitate drawing and image editing. This package provides a versatile set of tools for creating and modifying drawings and images, making it ideal for applications that require interactive drawing features.

## Features

- **Drawing Tools:** Supports multiple drawing tools including pencil, pen, marker, and eraser.
- **Undo/Redo:** Easy-to-use undo and redo functionality to manage drawing changes.
- **Image Handling:** Pick images from the camera or gallery to create or edit drawings.
- **Image Editing:** Edit pre-drawn drawings, create new drawings, or edit images loaded from URLs.

## Getting Started

To integrate `DrawingView` into your Swift project, follow these steps:

### Installation

Add `DrawingView` to your `Package.swift` dependencies:

```
import PackageDescription

let package = Package(
    name: "DrawingView",
    products: [
        .library(
            name: "DrawingView",
            targets: ["DrawingView"]),
    ],
    dependencies: [
        // Add any external dependencies here
    ],
    targets: [
        .target(
            name: "DrawingView",
            dependencies: [],
            path: "Sources",
            resources: [
                // Include resources if needed
            ]
        ),
        .testTarget(
            name: "DrawingViewTests",
            dependencies: ["DrawingView"]
        ),
    ]
)
```

Usage
To start using DrawingView in your project, import the package and create an instance of DrawingView:

```
import DrawingView

// Example setup code
            let vc = DrawingViewController()

            vc.delegate = self
            
            vc.lastURL = URL(string: "https://fastly.picsum.photos/id/866/200/300.jpg?hmac=rcadCENKh4rD6MAp6V_ma-AyWv641M4iiOpe1RyFHeI")
            vc.navTitle = "Drawing"
            vc.buttonsHeight = 40
            vc.buttonsPadding = 8.0
            vc.buttonsTint = .black
            vc.navButtonsTint = .black
            vc.showBorders = true
            vc.showShadows = true
            vc.showExtraBlackWhite = true
            self.navigationController?.pushViewController(vc, animated: true)
        

// Handle delagate
extension YourViewController: DrawingViewControllerDelegate 
{
    func drawnImage(_ image: UIImage?)
    {
        imageview.image = image
    }
}



```

Note: To include camera and gallery permissions in your iOS app, you need to add the appropriate keys to your Info.plist file. These permissions are necessary to request access from the user for using the camera and accessing the photo library.

```
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take photos.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select photos.</string>
```
By adding these keys to your Info.plist, you ensure that your app prompts the user for the necessary permissions to access the camera and photo library.



Features in Detail


Drawing Tools: Choose between pencil, pen, marker, and eraser to create and modify drawings.

Undo/Redo: Easily manage your drawing history with undo and redo options.

Image Selection: Pick images from the camera or gallery to integrate into your drawings.

Image Editing: Edit existing drawings, create new ones, or manipulate images from URLs.

(Attached screenshots are here)



<img src="https://github.com/user-attachments/assets/9b1c0baa-e491-4b20-ab09-77dfb9c6672f" alt="Screenshot1" width="auto" height="500"/>
<img src="https://github.com/user-attachments/assets/87d53777-4628-469b-8d97-09fcf29fc036" alt="Screenshot1" width="auto" height="500"/>
<img src="https://github.com/user-attachments/assets/ec22462f-5afb-40fa-80fc-9506fd651a9d" alt="Screenshot1" width="auto" height="500"/>
<img src="https://github.com/user-attachments/assets/e8578803-cc6a-4e51-b39f-289a70364359" alt="Screenshot1" width="auto" height="500"/>


Contributing

If you would like to contribute to DrawingView, please fork the repository and submit a pull request with your changes. We welcome contributions to improve the package.

License

DrawingView is licensed under the MIT License. See the LICENSE file for more information.
