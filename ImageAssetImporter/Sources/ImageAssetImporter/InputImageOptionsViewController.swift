import Cocoa
import CompositeImageAsset

internal class InputImageOptionsViewController: NSViewController {

  // MARK: - Exposed Operation

  /// Runs the options inout prompt asynchronously.
  ///
  /// On success, and returns the user-specified asset options. Returns `nil` if the user cancels.
  static func beginSheet<T: CompositeImageAssetOptions>(in hostViewController: NSViewController, urls: [URL]) async -> T? {
    return await withCheckedContinuation({ continuation in
      self.beginSheet(in: hostViewController, urls: urls) { options in
        continuation.resume(returning: options)
      }
    })
  }

  // MARK: NSViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.

    let lines = urls.map { $0.lastPathComponent }
    let text = lines.joined(separator: "\n")
    textView.string = text
  }

  // MARK: -

  /// Displays the input URLs.
  @IBOutlet private weak var textView: NSTextView!

  /// Lets the user specify the scale factor.
  @IBOutlet private weak var scaleFactorButton: NSPopUpButton!

  /// Lets the user specify the asset name.
  @IBOutlet private weak var atlasNameTextField: NSTextField!

  /// Lets the user submit the entered data.
  @IBOutlet private weak var submitButton: NSButton!

  /// Block executed when the user chooses submit or cancel.
  ///
  /// The parameter is true if submit, false if cancel.
  private var completionHandler: (_ accepted: Bool) -> Void = { _ in }

  /// The input image URLs passed to the view controller, stored for display.
  private var urls: [URL] = []

  /// The asset name currently entered.
  private var currentName: String {
    return atlasNameTextField.stringValue
  }

  /// The currenlty selected input images' assumed scale factor.
  private var currentScaleFactor: Float {
    switch scaleFactorButton.indexOfSelectedItem {
    case 0:
      return 1
    case 1:
      return 2
    default:
      return 3
    }
  }

  // Made private to discourage non-concurrent use. Use async version instead.
  private static func beginSheet<T: CompositeImageAssetOptions>(in hostViewController: NSViewController, urls: [URL], completion: @escaping (T?) -> Void) {
    let storyboard = NSStoryboard(name: "InputImageOptions", bundle: Bundle.module)
    guard let viewController = storyboard.instantiateInitialController() as? InputImageOptionsViewController else {
      fatalError()
    }
    viewController.urls = urls

    // The view controller is storing a strong reference to the submit handler, so the block can
    // only capture a weak reference to the view controller to avoid a string reference cycle.
    viewController.completionHandler = { [weak viewController](accepted) in
      guard let controller = viewController, accepted == true else {
        return completion(nil)
      }
      let name = controller.currentName
      let scale = controller.currentScaleFactor
      let options = T(name: name, scaleFactor: scale)
      completion(options)
    }

    hostViewController.presentAsSheet(viewController)
  }

  // MARK: - Control Actions

  @IBAction private func submit(_ sender: Any) {
    completionHandler(true)
    presentingViewController?.dismiss(self)
  }

  @IBAction private func cancel(_ sender: Any) {
    completionHandler(false)
    presentingViewController?.dismiss(self)
  }
}
