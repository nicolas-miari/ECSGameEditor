import Foundation

/// Root protocol, defines the interface common to all asset types.
///
public protocol Asset: AnyObject, Codable {

  /// The human-readable name of the asset. Can be changed at will.
  var name: String { get set }

  /// Uniquely identifies the asset. Immutable, generated once on instantiation and persisted across
  /// sessions.
  var identifier: String { get }
}

// MARK: - Asset Subtypes

/// Defines the interface common to all metadata-only assets.
///
/// The protocol defines no constraints, as any properties of conforming types will depend on the
/// specific asset type.
public protocol PrimitiveAsset: Asset {
}

/// Defines the interface common to all asset types that depend on a binary resource.
public protocol BinaryResourceAsset: Asset {

  /// Uniquely identifies the binary resource on which this asset depends.
  ///
  /// The asset only contains the resource identifier. Whenever the actual binary resource data is
  /// needed, a provider object that can locate the data from this identifier is needed.
  var binaryResourceIdentifier: String { get }
}
