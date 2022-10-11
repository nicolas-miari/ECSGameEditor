import Foundation
import UniqueIdentifierProvider

/**
 The purpose of the factory is to hide the concrete implementation of the BinaryResourceProvider
 protocol.

 Clients of the service should obtain an opaque instance from the fatory and operate on it.
 */
public final class BinaryResourceProviderFactory {

  /// Creates a new resource provider.
  ///
  /// If you want to enforce unique identifier consistency with other entity managers, specify an
  /// existing `UniqueIdentifierProvider` as the argument; otherwise, a new instance will be
  /// created.
  public static func newResourceProvider(identifierProvider: UniqueIdentifierProvider? = nil) -> some BinaryResourceProvider {
    let idProvider = identifierProvider ?? UniqueIdentifierProviderFactory.newIdentifierProvider()
    return BinaryResourceProviderImplementation(identifierProvider: idProvider)
  }

  /// Creates a new resource provider and loads its contets from the specified directory URL.
  ///
  /// Use this method to restore a previously created resource provider from disk.
  public static func loadResourceProvider(from directory: FileWrapper) throws -> some BinaryResourceProvider {
    let provider = try BinaryResourceProviderImplementation(from: directory)
    return provider
  }
}
