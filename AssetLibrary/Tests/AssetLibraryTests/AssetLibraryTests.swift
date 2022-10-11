import XCTest
import Asset

@testable import AssetLibrary

@MainActor
final class AssetLibraryTests: XCTestCase {

  func testPersistence() throws {

    let library = AssetLibraryFactory.newLibrary()

    let image = ImageAsset(name: "image 1", identifier: "0000")
    let sound = SoundAsset(name: "sound 1", identifier: "0001")

    library.addAsset(image)
    library.addAsset(sound)

    let directory = try library.directoryWrapper()

    let restored = try AssetLibraryFactory.loadAssetLibrary(from: directory, assetTypes: [ImageAsset.self, SoundAsset.self])

    let images = restored.assets(ofType: ImageAsset.self)
    let sounds = restored.assets(ofType: SoundAsset.self)

    XCTAssertEqual(images[0].identifier, image.identifier)
    XCTAssertEqual(sounds[0].identifier, sound.identifier)
  }
}

// MARK: - Supporting Types

final class ImageAsset: NSObject, Asset {

  private enum CodingKeys: String, CodingKey {
    case name
    case identifier
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decode(String.self, forKey: .name)
    self.identifier = try container.decode(String.self, forKey: .identifier)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(identifier, forKey: .identifier)
  }

  var name: String
  let identifier: String

  init(name: String, identifier: String) {
    self.name = name
    self.identifier = identifier
  }
}

final class SoundAsset: NSObject, Asset {

  private enum CodingKeys: String, CodingKey {
    case name
    case identifier
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decode(String.self, forKey: .name)
    self.identifier = try container.decode(String.self, forKey: .identifier)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(identifier, forKey: .identifier)
  }

  var name: String
  let identifier: String

  init(name: String, identifier: String) {
    self.name = name
    self.identifier = identifier
  }
}
