import Foundation
import Asset

/**
 The purpose of the factory is to hide the concrete implementation of the AssetLibrary protocol.

 Clients of the service should obtain an opaque instance from the fatory and operate on it.
 */
public class AssetLibraryFactory {

  /**
   Instantiates an empty asset library.
   */
  public static func newLibrary() -> some AssetLibrary {
    return AssetLibraryImplementation()
  }

  /**
   Instantiates a new asset library with the contents of the specified directory.

   The array of metatypes is necessary in order to instantiate each concrete asset type from the
   persisted data.
   */
  public static func loadAssetLibrary(from directory: FileWrapper, assetTypes: [Asset.Type]) throws -> some AssetLibrary {
    let library = AssetLibraryImplementation()
    try assetTypes.forEach { type in
      try library.loadAssets(ofType: type, fromRoot: directory)
    }
    return library
  }
}
