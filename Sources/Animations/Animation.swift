#if os(iOS) || os(tvOS)
import UIKit

/// A structure that provides a chainable interface for UIView animations.
///
/// `Animation` wraps `UIView.animate(withDuration:delay:options:animations:completion:)`
/// to allow sequential chaining of animations using a fluent API.
///
/// Example:
/// ```swift
/// Animation.make(duration: 0.3, animations: {
///     view.alpha = 0.5
/// }).then(duration: 0.3, animations: {
///     view.alpha = 1.0
/// }).start()
/// ```
public struct Animation {
    /// Represents the operation type for chaining animations.
    indirect enum Operation {
        /// No previous animation exists.
        case none
        /// An animation exists that should be executed first.
        case animation(Animation)
    }
    /// The duration of the animation in seconds.
    fileprivate let duration: TimeInterval
    /// The delay before the animation starts in seconds.
    fileprivate let delay: TimeInterval
    /// The animation options to apply.
    fileprivate let options: UIView.AnimationOptions
    /// The block containing the animations to perform.
    fileprivate let animations: () -> Void
    /// The previous animation in the chain, if any.
    fileprivate var previousAnimation: Operation

    /// Creates a new animation with the specified parameters.
    ///
    /// - Parameters:
    ///   - duration: The duration of the animation in seconds.
    ///   - delay: The delay before the animation starts in seconds. Default is 0.0.
    ///   - options: Animation options to apply. Default is an empty set.
    ///   - animations: The block containing the animations to perform.
    /// - Returns: A new `Animation` instance.
    public static func make(duration: TimeInterval,
                            delay: TimeInterval = 0.0,
                            options: UIView.AnimationOptions = [],
                            animations: @escaping () -> Void) -> Self {

        return Animation(duration: duration,
                         delay: delay,
                         options: options,
                         animations: animations,
                         previousAnimation: .none)
    }

    /// Chains another animation to be executed after this one completes.
    ///
    /// - Parameters:
    ///   - duration: The duration of the next animation in seconds.
    ///   - delay: The delay before the next animation starts in seconds. Default is 0.0.
    ///   - options: Animation options to apply. Default is an empty set.
    ///   - animations: The block containing the animations to perform.
    /// - Returns: A new `Animation` instance that will execute after this one.
    public func then(duration: TimeInterval,
                     delay: TimeInterval = 0.0,
                     options: UIView.AnimationOptions = [],
                     animations: @escaping () -> Void) -> Self {
        return Animation(duration: duration,
                         delay: delay,
                         options: options,
                         animations: animations,
                         previousAnimation: .animation(self))
    }

    /// Starts the animation chain, executing all animations in sequence.
    ///
    /// If this animation has a previous animation in the chain, that animation will be
    /// executed first, and this animation will begin only after the previous one completes.
    ///
    /// - Parameter completion: An optional completion block called when the final animation
    ///   in the chain completes. The block takes a Boolean parameter indicating whether
    ///   the animation finished (true) or was interrupted (false).
    public func start(completion: ((Bool) -> Void)? = nil) {
        let executeAnimation = {
            UIView.animate(withDuration: self.duration,
                           delay: self.delay,
                           options: self.options,
                           animations: self.animations,
                           completion: completion)
        }

        if case let .animation(animation) = self.previousAnimation {
            animation.start(completion: { _ in executeAnimation() })
        } else {
            executeAnimation()
        }
    }
}
#endif
