import Foundation

public final class UniqueIdentifierProviderFactory {

  public static func newIdentifierProvider() -> some UniqueIdentifierProvider {
    return UniqueIdentifierProviderImplementation()
  }

  public static func loadIdentifierProvider(from file: FileWrapper) throws -> some UniqueIdentifierProvider {
    let provider = try UniqueIdentifierProviderImplementation(from: file)
    return provider
  }
}
