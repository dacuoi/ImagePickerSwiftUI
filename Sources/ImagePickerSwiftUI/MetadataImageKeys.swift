import Foundation

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
