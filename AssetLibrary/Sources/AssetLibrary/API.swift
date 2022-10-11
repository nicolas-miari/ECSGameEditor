import Foundation
import Asset

/**
 Defines the public interface for an asset library object.
 */
public protocol AssetLibrary {

  // MARK: - Operation

  /**
   Returns a directory file wrapper representing the current contents of the library, for
   persistence on disk.

   The library can later be faithfully restored by calling the factory method
   `loadAssetLibrary(from:)` and passing the same directory wrapper returned here.
   */
  func directoryWrapper() throws -> FileWrapper

  /** Adds the specified asset to the library. */
  @MainActor
  func addAsset<T: Asset>(_ asset: T)

  /** Retrieves all assets of the specified type. */
  func assets<T: Asset>(ofType: T.Type) -> [T]
}
