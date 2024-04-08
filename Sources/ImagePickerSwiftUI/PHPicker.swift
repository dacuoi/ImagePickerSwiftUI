import SwiftUI
import PhotosUI

@available(iOS 14.0, *)
public struct PHPicker: UIViewControllerRepresentable {
  @Binding var isPresented: Bool
  @Binding var images: [UIImage]

  var filter: PHPickerFilter?
  var selectionLimit: Int

  public init(
    filter: PHPickerFilter? = nil,
    selectionLimit: Int = 0,
    isPresented: Binding<Bool>,
    images: Binding<[UIImage]>
  ) {
    self.filter = filter
    self.selectionLimit = selectionLimit
    self._isPresented = isPresented
    self._images = images
  }

  public func makeUIViewController(context: Context) -> PHPickerViewController {
    var configuration = PHPickerConfiguration()
    configuration.filter = filter
    configuration.selectionLimit = selectionLimit

    let picker = PHPickerViewController(configuration: configuration)
    picker.delegate = context.coordinator

    return picker
  }

  public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  public class Coordinator: PHPickerViewControllerDelegate {
    private let parent: PHPicker

    public init(_ parent: PHPicker) {
      self.parent = parent
    }

    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
      Task {
        for result in results {
          do {
            let image = try await loadImage(result: result)
            parent.images.append(image)
          } catch {
            print(error.localizedDescription)
          }
        }
        parent.isPresented = false
      }
    }

    private func loadImage(result: PHPickerResult) async throws -> UIImage {
      try await withCheckedThrowingContinuation { continuation in
        let provider = result.itemProvider
        provider.loadObject(ofClass: UIImage.self) { image, error in
          if let error {
            continuation.resume(throwing: error)
            return
          }
          guard let image = image as? UIImage else {
            continuation.resume(throwing: ImagePickerError.missingImage)
            return
          }
          continuation.resume(returning: image)
        }
      }
    }
  }
}