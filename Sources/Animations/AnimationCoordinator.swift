#if os(iOS) || os(tvOS)
import UIKit

/// A block that contains property animations to be executed.
public typealias PropertyAnimationBlock = () -> Void

/// A block that is executed after an animation completes.
public typealias PostAnimationBlock = () -> Void

/// Represents the timing specification for an animation.
///
/// `TimeSpec` defines when an animation should start and how long it should run.
public struct TimeSpec {
    /// The time in seconds when the animation should start, relative to when the coordinator starts.
    public let start: TimeInterval
    /// The duration of the animation in seconds.
    public let duration: TimeInterval

    /// Creates a new time specification.
    ///
    /// - Parameters:
    ///   - start: The start time in seconds.
    ///   - duration: The duration in seconds.
    public init(start: TimeInterval, duration: TimeInterval) {
        self.start = start
        self.duration = duration
    }
}

/// A coordinator that manages multiple property animations that can run concurrently.
///
/// `AnimationCoordinator` allows you to schedule multiple `UIViewPropertyAnimator` instances
/// to run at different times with different durations, providing precise control over
/// complex animation sequences.
///
/// Example:
/// ```swift
/// AnimationCoordinator.new
///     .addPropertyAnimation(at: 0.0, for: 0.5, animations: {
///         view1.alpha = 0
///     })
///     .addPropertyAnimation(at: 0.3, for: 0.5, animations: {
///         view2.alpha = 1
///     })
///     .start()
/// ```
public class AnimationCoordinator {
    /// Defines the timing curve for an animation.
    public enum Pace {
        /// A linear timing curve where the animation progresses at a constant rate.
        case linear
        /// A cubic Bézier timing curve defined by two control points.
        ///
        /// - Parameters:
        ///   - x1: The x-coordinate of the first control point.
        ///   - y1: The y-coordinate of the first control point.
        ///   - x2: The x-coordinate of the second control point.
        ///   - y2: The y-coordinate of the second control point.
        case cubic(CGFloat, CGFloat, CGFloat, CGFloat)
        
        /// Converts the pace to a UIKit timing curve provider.
        var timingCurveProvider: UITimingCurveProvider {
            switch self {
            case .linear: return UICubicTimingParameters(animationCurve: .linear)
            case let .cubic(x1, y1, x2, y2): return UICubicTimingParameters(controlPoint1: CGPoint(x: x1, y: y1), controlPoint2: CGPoint(x: x2, y: y2))
            }
        }
    }
    /// Internal representation of a scheduled animation.
    private struct Animation {
        let time: TimeInterval
        let duration: TimeInterval
        let pace: UITimingCurveProvider
        let animationBlock: PropertyAnimationBlock
        let completionBlock: PostAnimationBlock?
        var complete: Bool = false
    }
    
    /// The list of scheduled animations.
    private var animations = [Animation]()
    
    /// The total duration of all animations in the coordinator.
    ///
    /// This is calculated as the maximum of all animation end times (start time + duration).
    public private(set) var duration: TimeInterval = 0.0
    
    /// Indicates whether all animations have completed.
    public var complete: Bool { animations.map { $0.complete }.allSatisfy { $0 } }
    
    /// The completion handler to call when all animations are complete.
    private var completion: (() -> Void )?

    /// Checks if all animations are complete and calls the completion handler if so.
    private func tryToComplete() { if complete { completion?() } }

    /// Required initializer for creating an animation coordinator.
    required init() { }

    /// Creates a new animation coordinator instance.
    ///
    /// - Returns: A new `AnimationCoordinator` ready to schedule animations.
    public static var new: Self { Self() }

    /// Adds a property animation to the coordinator.
    ///
    /// The animation will start at the specified time relative to when `start()` is called,
    /// and will run for the specified duration.
    ///
    /// - Parameters:
    ///   - time: The time in seconds when the animation should start. Default is 0.0.
    ///   - duration: The duration of the animation in seconds.
    ///   - pace: The timing curve for the animation. Default is `.linear`.
    ///   - animations: The block containing the property animations to perform.
    ///   - completion: An optional block to execute when this animation completes.
    /// - Returns: The coordinator instance for method chaining.
    public func addPropertyAnimation(at time: TimeInterval = 0.0,
                                     for duration: TimeInterval,
                                     pace: Pace = .linear,
                                     animations: @escaping PropertyAnimationBlock,
                                     completion: PostAnimationBlock? = nil) -> Self {
        self.animations.append(Animation(time: time, duration: duration, pace: pace.timingCurveProvider, animationBlock: animations, completionBlock: completion))
        self.duration = max(self.duration, time + duration)
        return self
    }

    /// Adds a property animation to the coordinator using a time specification.
    ///
    /// This is a convenience method that accepts a `TimeSpec` instead of separate
    /// start time and duration parameters.
    ///
    /// - Parameters:
    ///   - timeSpec: The timing specification defining when to start and how long to run.
    ///   - pace: The timing curve for the animation. Default is `.linear`.
    ///   - animations: The block containing the property animations to perform.
    ///   - completion: An optional block to execute when this animation completes.
    /// - Returns: The coordinator instance for method chaining.
    public func addPropertyAnimation(timeSpec: TimeSpec,
                                     pace: Pace = .linear,
                                     animations: @escaping PropertyAnimationBlock,
                                     completion: PostAnimationBlock? = nil) -> Self {
        return addPropertyAnimation(at: timeSpec.start, for: timeSpec.duration, pace: pace, animations: animations, completion: completion)
    }

    /// Starts all scheduled animations in the coordinator.
    ///
    /// Each animation will begin at its scheduled time and run for its specified duration.
    /// All animations run concurrently according to their schedules.
    ///
    /// - Parameter completion: An optional block to execute when all animations complete.
    ///   This block is called only after every animation in the coordinator has finished.
    public func start(completion: (() -> Void)? = nil) {
        self.completion = completion
        guard duration > 0 else { return }

        for index in animations.indices {
            let propAnimator = UIViewPropertyAnimator(duration: animations[index].duration, timingParameters: animations[index].pace)
            propAnimator.addAnimations(animations[index].animationBlock)
            propAnimator.addCompletion { _ in
                self.animations[index].completionBlock?()
                self.animations[index].complete = true
                self.tryToComplete()
            }
            propAnimator.startAnimation(afterDelay: animations[index].time)
        }
    }
}
#endif
