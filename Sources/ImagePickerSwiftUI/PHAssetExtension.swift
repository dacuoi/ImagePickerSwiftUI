import UIKit
import Photos

public extension PHAsset {
    func fetchPhotoMetadata() -> [String: Any] {
        var metadata: [String: Any] = [:]
        // Ngày tạo
        if let creationDate = self.creationDate {
            metadata[MetadataImageKeys.creationDate.rawValue] = creationDate
        }
        // Ngày sửa đổi
        if let modificationDate = self.modificationDate {
            metadata[MetadataImageKeys.modificationDate.rawValue] = modificationDate
        }
        // Vị trí
        if let location = self.location {
            metadata[MetadataImageKeys.location.rawValue] = ["latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude]
        }
        // Kích thước
        metadata[MetadataImageKeys.pixelWidth.rawValue] = self.pixelWidth
        metadata[MetadataImageKeys.pixelHeight.rawValue] = self.pixelHeight
        // Loại phương tiện
        switch self.mediaType {
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
        if self.mediaSubtypes.contains(.photoLive) {
            mediaSubtypes.append("Live Photo")
        }
        if self.mediaSubtypes.contains(.photoPanorama) {
            mediaSubtypes.append("Panorama")
        }
        if self.mediaSubtypes.contains(.photoHDR) {
            mediaSubtypes.append("HDR")
        }
        if self.mediaSubtypes.contains(.photoScreenshot) {
            mediaSubtypes.append("Screenshot")
        }
        metadata[MetadataImageKeys.mediaSubtypes.rawValue] = mediaSubtypes
        // Thời lượng video (nếu là video)
        if self.mediaType == .video {
            metadata[MetadataImageKeys.duration.rawValue] = self.duration
        }
        // Ảnh burst
        if let burstIdentifier = self.burstIdentifier {
            metadata[MetadataImageKeys.burstIdentifier.rawValue] = burstIdentifier
            metadata[MetadataImageKeys.burstSelectionTypes.rawValue] = self.burstSelectionTypes
        }
        // Đánh dấu yêu thích
        metadata[MetadataImageKeys.isFavorite.rawValue] = self.isFavorite
        // Bị ẩn
        metadata[MetadataImageKeys.isHidden.rawValue] = self.isHidden
        // Loại nguồn
        switch self.sourceType {
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
    
}
