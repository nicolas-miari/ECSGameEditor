import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

extension CGImage {

  /**
   Creates a solid image of the specified size and color.
   See `ImageUtilError` for the errors that can be potentially thrown.
   */
  public static func createSolid(size: CGSize, color: CGColor) throws -> CGImage {
    let width = Int(size.width)
    let height = Int(size.height)
    guard let context = CGContext(
      data: nil,
      width: width,
      height: height,
      bitsPerComponent: 8,
      bytesPerRow: width * 4,
      space: CGColorSpaceCreateDeviceRGB(),
      bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
    ) else {
      throw ImageUtilError.failedToCreateGraphicsContext
    }

    context.setFillColor(color)
    context.fill([CGRect(origin: .zero, size: size)])

    guard let image = context.makeImage() else {
      throw ImageUtilError.failedToCreateImage
    }
    return image
  }

  public func pngData() throws -> Data {
    guard let imageData = CFDataCreateMutable(nil, 0) else {
      throw ImageUtilError.failedToCreatePNGData
    }
    let identifier = UTType.png.identifier as CFString
    guard let destination = CGImageDestinationCreateWithData(imageData, identifier, 1, nil) else {
      throw ImageUtilError.failedToCreatePNGData
    }
    CGImageDestinationAddImage(destination, self, nil)
    guard CGImageDestinationFinalize(destination) else {
      throw ImageUtilError.failedToCreatePNGData
    }
    return (imageData as Data)
  }

  var aspectRatio: CGFloat {
    return CGFloat(width) / CGFloat(height)
  }
}

// MARK: - Supporting Types
public enum ImageUtilError: LocalizedError {
  case failedToCreateGraphicsContext
  case failedToCreateImage
  case failedToCreatePNGData
}
