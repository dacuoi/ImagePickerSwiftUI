import SwiftUI

@available(iOS 13.0, *)
@available(tvOS 13.0, *)
@available(watchOS 6.0, *)
@available(OSX 10.15, *)
public struct ImagePickerSwiftUI: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType
    var allowsEditing: Bool
    var key: UIImagePickerController.InfoKey

    public init(
        selectedImage: Binding<UIImage?>,
        sourceType: UIImagePickerController.SourceType,
        allowsEditing: Bool,
        key: UIImagePickerController.InfoKey = .originalImage
    ) {
        self._selectedImage = selectedImage
        self.sourceType = sourceType
        self.allowsEditing = allowsEditing
        self.key = key
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = allowsEditing
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator

        return imagePicker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePickerSwiftUI
        
        init(_ parent: ImagePickerSwiftUI) {
            self.parent = parent
        }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
