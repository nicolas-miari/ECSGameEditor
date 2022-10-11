import Foundation

// MARK: - Factory

@MainActor
public final class ImageFileImporterFakeFactory {

  public static func newFileImporterFake() -> some ImageFileImporterFake {
    return ImageFileImporterFakeImplementation()
  }
}

// MARK: - Default implementation

private final class ImageFileImporterFakeImplementation: ImageFileImporterFake {

  private var selectedImages: [URL] = []

  fileprivate func openUserSelectedImages() async -> [URL] {
    // The fake implementation of the public API simply returns the stubbed response.
    return selectedImages
  }

  fileprivate func stubUserSelectedImages(_ urls: [URL]) {
    self.selectedImages = urls
  }
}
