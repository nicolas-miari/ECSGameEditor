import Asset
import UniqueIdentifierProvider

/// Defines the interface common to all asset types that depend on other assets.
public protocol CompositeAsset: Asset {

  /// A type used to pass configuration options to the asset initializer
  associatedtype Options: CompositeAssetOptions

  /// An array of strings each representing theunique identifier of an asset that is required for
  /// the functioning of this one.
  var dependencies: [String] { get set }

  /// Creates a new instance with the specified asset IDs as dependencies (children) and a
  /// configuration.
  init(dependencies: [String], identifierProvider: UniqueIdentifierProvider, options: Options) throws
}

// MARK: - Supporting Types

public protocol CompositeAssetOptions {

  /// At the bare minimum, an asset options should include the user-specified asset name. concrete
  /// Option types for more specific assets might include additional properties.
  var name: String { get }
}
