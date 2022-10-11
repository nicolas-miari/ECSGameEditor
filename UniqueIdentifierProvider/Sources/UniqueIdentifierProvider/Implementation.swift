import Foundation

internal final class UniqueIdentifierProviderImplementation: UniqueIdentifierProvider {

  private var database: [String]

  private var failSafeLimit = 10_000

  // MARK: - Initialization

  internal init() {
    self.database = []
  }

  internal init(from file: FileWrapper) throws {
    // FileWrapper.regularFilecontents is optional to support nil when the user modifies the file
    // after calling read(from:options:) or init(url:options:) but before FileWrapper has read the
    // contents of the file. This cannot be easily reproduced in tests, so this else block is not
    // covered.
    guard let data = file.regularFileContents else {
      throw UniqueIdentifierProviderError.missingInputData
    }
    self.database = try JSONDecoder().decode([String].self, from: data)
  }

  // MARK: - UniqueIdentifierProvider

  internal func fileWrapper() throws -> FileWrapper {
    let data = try JSONEncoder().encode(database)
    return FileWrapper(regularFileWithContents: data)
  }

  /// Creates a new identifier.
  internal func newIdentifier() throws -> String {

    // Fail-safe to break out of the (highly unlikely, but) potentially infinite while loop in case
    // an external bug prevents it from exiting.
    var failSafeCounter = 0

    while(true) {
      let new = UUID().uuidString

      if !database.contains(new) {
        // This should happen virtually all the time (the probability of a UUID collision is
        // astronomically small).
        database.append(new)
        return new
      }
      // This should happen once in the life of the universe. Rare enough that it's not worth
      // throwing an actual error.
      failSafeCounter += 1
      if failSafeCounter > failSafeLimit {
        throw UniqueIdentifierProviderError.internalError
      }
    }
  }

  internal func newUncheckedIdentifier() -> String {
    let new = UUID().uuidString
    database.append(new)
    return new
  }

  internal func contains(_ identifier: String) -> Bool {
    return database.contains(identifier)
  }
}
