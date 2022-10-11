import Foundation

// MARK: - Public Interface

/// Defines the interface for an object that provides unique identifiers and optionally manages
/// potential identifier collisions.
public protocol UniqueIdentifierProvider: AnyObject {

  /// Provides a file wrapper for persisting the provider's identifier cache to disk.
  func fileWrapper() throws -> FileWrapper

  /// Creates an new unique identifier and caches it internally to double-check for uniqueness.
  ///
  /// If a collision cannot be averted, `UniqueIdentifierProviderError.internalError` is thrown.
  /// This should in theory not happen, barring a logic bug in the implementation or its
  /// dependencies (Foundation). If you don't care about uniqueness checks and prefer to call from a
  /// non-throwing context, use `newUncheckedIdentifier()` instead.
  func newIdentifier() throws -> String

  /// Creates an new unique identifier without checking for (extremely unlikely) collisions.
  ///
  /// The new identifier is returned unchecked, but it is added to the internal cache for comparison
  /// during future calls to `newIdentifier()`.
  func newUncheckedIdentifier() -> String

  /// Returns `true` if the specified identifier is included in the provider's cache.
  ///
  /// Useful when compairing two instances, even if they're from different concrete types.
  func contains(_ identifier: String) -> Bool
}

// MARK: - Supporting Types

public enum UniqueIdentifierProviderError: LocalizedError {
  /// Tried to deserialize a provider from a directory (no contents).
  case missingInputData

  /// The provider failed to produce a unique ID due to unavoidable collision.
  ///
  /// The default implementation performs at most 255 attempts at creating a new unique identifier,
  /// each time comparing it to the cached, previously generated ones. Therefore, the occurrence of
  /// this error signals a logic bug in the implementation or its dependencies (Foundation).
  case internalError
}
