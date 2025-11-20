#if os(iOS) || os(tvOS)
import UIKit

/// Extension providing convenience methods for CGRect.
public extension CGRect {
    /// The center point of the rectangle.
    ///
    /// Returns a `CGPoint` representing the center of this rectangle,
    /// calculated as `(midX, midY)`.
    var centerPoint: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

/// Extension providing convenience methods for CGPoint.
public extension CGPoint {
    /// Returns a new point translated by the specified offsets.
    ///
    /// - Parameters:
    ///   - deltaX: The horizontal offset to add to the x-coordinate.
    ///   - deltaY: The vertical offset to add to the y-coordinate.
    /// - Returns: A new `CGPoint` with the translated coordinates.
    func translatedBy(x deltaX: CGFloat, y deltaY: CGFloat) -> CGPoint {
        return CGPoint(x: x + deltaX,
                       y: y + deltaY)
    }
}

/// Extension providing convenience methods for UIView.
public extension UIView {
    /// Sets the anchor point of the view's layer while maintaining its position.
    ///
    /// This method changes the layer's anchor point (the point around which transformations
    /// occur) without changing the view's visual position on screen. This is useful for
    /// animations where you want rotations or scales to occur around a specific point.
    ///
    /// - Parameter coordinate: The new anchor point in the view's coordinate space.
    ///   For example, `CGPoint(x: 0, y: 0)` sets the anchor to the top-left corner,
    ///   while `bounds.centerPoint` sets it to the center.
    ///
    /// - Note: The coordinate is in points within the view's bounds, not normalized (0-1) coordinates.
    func setAnchorCoordinate(_ coordinate: CGPoint) {
        var newPoint = CGPoint(x: coordinate.x / bounds.size.width, y: coordinate.y / bounds.size.height)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y)

        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)

        var position = layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x * bounds.size.width

        position.y -= oldPoint.y
        position.y += newPoint.y * bounds.size.height

        layer.position = position
        layer.anchorPoint = newPoint
    }
}
#endif
