import Asset
import Foundation
import UniqueIdentifierProvider

public class ImageAsset: BinaryResourceAsset {

  /// User-facing name of the asset in the editor.
  public var name: String

  /// Uniquely identifies the asset within the library that contains it.
  public let identifier: String

  /// Uniquely identifies the binary resource (image data) that the asset represents.
  public let binaryResourceIdentifier: String

  /// The initializer is isolated to the main actor because assets are only created anew (as opposed
  /// to e.g. restored from file) in response to user action. This also makes it straightforward to
  /// safely obtain a unique ID (the generating method is also isolated to the main actor).
  @MainActor
  public init(name: String, resourceIdentifier: String, identifierProvider: any UniqueIdentifierProvider) throws {
    self.name = name
    self.identifier = try identifierProvider.newIdentifier()
    self.binaryResourceIdentifier = resourceIdentifier
  }
}
