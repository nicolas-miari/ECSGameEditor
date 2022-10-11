import Foundation
import AppKit     // for CGImage and NSBitmapImageRep
import ImageUtils
import UniqueIdentifierProvider

internal class BinaryResourceProviderImplementation: BinaryResourceProvider {

  private let identifierProvider: UniqueIdentifierProvider

  private let identifierProviderFileName = "IdentifierProvider"

  internal init(identifierProvider: UniqueIdentifierProvider) {
    self.identifierProvider = identifierProvider
  }

  // MARK: - BinaryResourceProvider Interface

  func directoryWrapper() throws -> FileWrapper {
    // Wrap each resource into a file
    var fileWrappers: [String: FileWrapper] = try cache.compactMapValues { image in
      let data = try image.pngData()
      return FileWrapper(regularFileWithContents: data)
    }
    // Wrap the identifier provder too:
    let idProviderFileWrapper = try identifierProvider.fileWrapper()
    fileWrappers[identifierProviderFileName] = idProviderFileWrapper

    return FileWrapper(directoryWithFileWrappers: fileWrappers)
  }

  func add(_ image: CGImage) -> String {
    let identifier = UUID().uuidString
    cache[identifier] = image
    return identifier
  }

  func image(identifier: String) throws -> CGImage {
    guard let image = cache[identifier] else {
      throw BinaryResourceError.resourceNotFound
    }
    return image
  }

  // MARK: - Internal Interface

  /// Restores an instance from disk.
  internal init(from directory: FileWrapper) throws {
    guard var children = directory.fileWrappers else {
      throw BinaryResourceError.dataCorrupted
    }

    // Recover the ID provider
    guard let providerFile = children.removeValue(forKey: identifierProviderFileName) else {
      throw BinaryResourceError.dataCorrupted
    }
    self.identifierProvider = try UniqueIdentifierProviderFactory.loadIdentifierProvider(from: providerFile)

    // Recover the binary resource cache
    self.cache = try children.mapValues { file in
      guard let data = file.regularFileContents else {
        throw BinaryResourceError.dataCorrupted
      }
      guard let bitmapRep = NSBitmapImageRep(data: data) else {
        throw BinaryResourceError.dataCorrupted
      }
      guard let image = bitmapRep.cgImage else {
        throw BinaryResourceError.dataCorrupted
      }
      return image
    }
  }

  // MARK: - Private

  private var cache: [String: CGImage] = [:]
}
