import Foundation

// MARK: - Public API

@MainActor
public protocol ImageFileImporter {

  /// Asynchronously presents an UI for the user to select one or more iagfe files.
  func openUserSelectedImages() async -> [URL]
}

// MARK: - Fake (Test) API

public protocol ImageFileImporterFake: ImageFileImporter {

  /// Configures the fake with a preset response when injecting it as a dependency.
  func stubUserSelectedImages(_ urls: [URL])
}
