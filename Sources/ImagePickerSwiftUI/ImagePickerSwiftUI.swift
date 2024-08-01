import SwiftUI
import Photos

@available(iOS 13.0, *)
public struct ImagePickerSwiftUI: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var selectedImage: ImageMetaData?
    //
    var sourceType: UIImagePickerController.SourceType
    var allowsEditing: Bool
    var key: UIImagePickerController.InfoKey
    var croppingToSquare: Bool = false
    //
    public init(
        selectedImage: Binding<ImageMetaData?>,
        sourceType: UIImagePickerController.SourceType,
        allowsEditing: Bool,
        key: UIImagePickerController.InfoKey = .originalImage,
        croppingToSquare: Bool = false
    ) {
        self._selectedImage = selectedImage
        self.sourceType = sourceType
        self.allowsEditing = allowsEditing
        self.key = key
        self.croppingToSquare = croppingToSquare
    }
    //
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = allowsEditing
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        //
        return imagePicker
    }
    //
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    //
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    //
    final public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePickerSwiftUI
        //
        init(_ parent: ImagePickerSwiftUI) {
            self.parent = parent
        }
        //
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            var imageData: UIImage?
            //
            if parent.allowsEditing {
                if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                    imageData = image
                }
            } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                imageData = parent.croppingToSquare ? image.croppingToSquare() : image
            }
            //
            var metaDataInfo: [String: Any] = [:]
            if let imageURL = info[.imageURL] as? URL {
                metaDataInfo[MetadataImageKeys.url.rawValue] = imageURL
            }
            if let asset = info[.phAsset] as? PHAsset {
                let metaDataPhoto = asset.fetchPhotoMetadata()
                metaDataInfo.merge(metaDataPhoto) { (current, _) in current }
            } else {
                print("No PHAsset found in info.")
            }
            let imageMetaData = (image: imageData, metaData: metaDataInfo)
            parent.selectedImage = imageMetaData
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
