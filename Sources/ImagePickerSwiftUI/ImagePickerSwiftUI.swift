import SwiftUI
import Photos

public typealias ImageMetaData = (image: UIImage?, metaData: [String: Any]?)

public enum MetadataImageKeys: String {
    /// Image URL
    case url
    /// Date when the asset was created
    case creationDate
    /// Date when the asset was last modified
    case modificationDate
    /// Location information (latitude and longitude)
    case location
    /// Width of the asset in pixels
    case pixelWidth
    /// Height of the asset in pixels
    case pixelHeight
    /// Type of the media (image, video, etc.)
    case mediaType
    /// Subtypes of the media (e.g., live photo, panorama)
    case mediaSubtypes
    /// Duration of the media (only applicable for videos)
    case duration
    /// Identifier for burst photo
    case burstIdentifier
    /// Types of burst selection
    case burstSelectionTypes
    /// Whether the asset is marked as favorite
    case isFavorite
    /// Whether the asset is hidden
    case isHidden
    /// Source type of the asset (e.g., user library, iTunes synced)
    case sourceType
}

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
        func fetchPhotoMetadata(asset: PHAsset) -> [String: Any] {
            var metadata: [String: Any] = [:]
            // Ngày tạo
            if let creationDate = asset.creationDate {
                metadata[MetadataImageKeys.creationDate.rawValue] = creationDate
            }
            // Ngày sửa đổi
            if let modificationDate = asset.modificationDate {
                metadata[MetadataImageKeys.modificationDate.rawValue] = modificationDate
            }
            // Vị trí
            if let location = asset.location {
                metadata[MetadataImageKeys.location.rawValue] = ["latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude]
            }
            // Kích thước
            metadata[MetadataImageKeys.pixelWidth.rawValue] = asset.pixelWidth
            metadata[MetadataImageKeys.pixelHeight.rawValue] = asset.pixelHeight
            // Loại phương tiện
            switch asset.mediaType {
            case .image:
                metadata[MetadataImageKeys.mediaType.rawValue] = "Image"
            case .video:
                metadata[MetadataImageKeys.mediaType.rawValue] = "Video"
            case .audio:
                metadata[MetadataImageKeys.mediaType.rawValue] = "Audio"
            default:
                metadata[MetadataImageKeys.mediaType.rawValue] = "Unknown"
            }
            // Kiểu phụ của phương tiện
            var mediaSubtypes: [String] = []
            if asset.mediaSubtypes.contains(.photoLive) {
                mediaSubtypes.append("Live Photo")
            }
            if asset.mediaSubtypes.contains(.photoPanorama) {
                mediaSubtypes.append("Panorama")
            }
            if asset.mediaSubtypes.contains(.photoHDR) {
                mediaSubtypes.append("HDR")
            }
            if asset.mediaSubtypes.contains(.photoScreenshot) {
                mediaSubtypes.append("Screenshot")
            }
            metadata[MetadataImageKeys.mediaSubtypes.rawValue] = mediaSubtypes
            // Thời lượng video (nếu là video)
            if asset.mediaType == .video {
                metadata[MetadataImageKeys.duration.rawValue] = asset.duration
            }
            // Ảnh burst
            if let burstIdentifier = asset.burstIdentifier {
                metadata[MetadataImageKeys.burstIdentifier.rawValue] = burstIdentifier
                metadata[MetadataImageKeys.burstSelectionTypes.rawValue] = asset.burstSelectionTypes
            }
            // Đánh dấu yêu thích
            metadata[MetadataImageKeys.isFavorite.rawValue] = asset.isFavorite
            // Bị ẩn
            metadata[MetadataImageKeys.isHidden.rawValue] = asset.isHidden
            // Loại nguồn
            switch asset.sourceType {
            case .typeUserLibrary:
                metadata[MetadataImageKeys.sourceType.rawValue] = "User Library"
            case .typeCloudShared:
                metadata[MetadataImageKeys.sourceType.rawValue] = "Cloud Shared"
            case .typeiTunesSynced:
                metadata[MetadataImageKeys.sourceType.rawValue] = "iTunes Synced"
            default:
                metadata[MetadataImageKeys.sourceType.rawValue] = "Unknown"
            }
            return metadata
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
                let metaDataPhoto = fetchPhotoMetadata(asset: asset)
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
