import CompositeAsset

/// Refines the CompositeAsset protocol to require an Options associated type that is image
/// asset-specific.
public protocol CompositeImageAsset: CompositeAsset where Options: CompositeImageAssetOptions {
}

/// Extends the CompositeAssetOptions protocol for use in composite assets that are image-based.
public protocol CompositeImageAssetOptions: CompositeAssetOptions {

  /// Specifies the common scale factor used in all images that make up the asset.
  var scaleFactor: Float { get }

  ///
  init(name: String, scaleFactor: Float)
}
