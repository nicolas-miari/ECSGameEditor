import Foundation
import Asset

internal class AssetLibraryImplementation: AssetLibrary {

  // MARK: - Operation

  func directoryWrapper() throws -> FileWrapper {
    let subdirectories = try assetsByClassName.mapValues { assets in
      // Map assets to files
      let filesByIdentifier = try assets.mapValues { asset in
        let data = try JSONEncoder().encode(asset)
        return FileWrapper(regularFileWithContents: data)
      }
      // Group assset files in a directory
      return FileWrapper(directoryWithFileWrappers: filesByIdentifier)
    }
    return FileWrapper(directoryWithFileWrappers: subdirectories)
  }

  func loadAssets<T: Asset>(ofType: T.Type, fromRoot directory: FileWrapper) throws {
    let key = self.key(for: T.self)
    guard let subdirectory = directory.fileWrappers?[key], let files = subdirectory.fileWrappers else {
      return
    }
    let assetsByIdentifier = try files.mapValues { file in
      let data = file.regularFileContents ?? Data()
      return try JSONDecoder().decode(T.self, from: data)
    }

    assetsByClassName[key] = assetsByIdentifier
  }

  @MainActor
  func addAsset<T: Asset>(_ asset: T) {
    let key = self.key(for: T.self)
    var assets = assetsByClassName[key] ?? [:]
    assets[asset.identifier] = asset
    assetsByClassName[key] = assets
  }

  func assets<T: Asset>(ofType: T.Type) -> [T] {
    let key = self.key(for: T.self)
    let assets = assetsByClassName[key]
    guard let values = assets?.values else {
      return []
    }
    return Array(values) as? [T] ?? []
  }

  // MARK: - Private Implementation

  private var assetsByClassName: [String: [String: any Asset]] = [:]

  private func key<T: Asset>(for type: T.Type) -> String {
    let bundle = Bundle(for: T.self)
    let namespace = (bundle.infoDictionary?["CFBundleName"] as? String ?? "").replacingOccurrences(of: " ", with: "_")
    let typeName = String(describing: T.self)
    return "\(namespace).\(typeName)"
  }
}
