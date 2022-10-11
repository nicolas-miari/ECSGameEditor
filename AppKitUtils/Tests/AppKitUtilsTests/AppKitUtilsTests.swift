import XCTest
@testable import AppKitUtils

final class AppKitUtilsTests: XCTestCase {

  func testViewControllerFromStoryboard() throws {
    let vc = DummyViewController.fromStoryboard(name: "Dummy")
  }

  func test1() {

  }
}
