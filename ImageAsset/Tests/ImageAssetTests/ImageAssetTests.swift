import XCTest
import UniqueIdentifierProvider
@testable import ImageAsset

@MainActor
final class ImageAssetTests: XCTestCase {

  func testNewAsset() throws {
    let identifierProvider = UniqueIdentifierProviderFactory.newIdentifierProvider()
    let asset1 = try ImageAsset(name: "Test 1", resourceIdentifier: "0001", identifierProvider: identifierProvider)
    let asset2 = try ImageAsset(name: "Test 2", resourceIdentifier: "0002", identifierProvider: identifierProvider)

    XCTAssertNotEqual(asset1.identifier, asset2.identifier)
  }

  func testSerialization() throws {
    let identifierProvider = UniqueIdentifierProviderFactory.newIdentifierProvider()
    let asset = try ImageAsset(name: "Test", resourceIdentifier: "0000", identifierProvider: identifierProvider)


    let data = try JSONEncoder().encode(asset)

    let recovered = try JSONDecoder().decode(ImageAsset.self, from: data)

    XCTAssertEqual(asset.identifier, recovered.identifier)
    XCTAssertEqual(asset.name, recovered.name)
    XCTAssertEqual(asset.binaryResourceIdentifier, recovered.binaryResourceIdentifier)
  }
}
