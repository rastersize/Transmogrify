//  Copyright © 2015 Aron Cedercrantz. All rights reserved.

import Foundation

public class ValueTransformer<A, B>: NSValueTransformer {

    // MARK: - Value Transformation Block Types

    /// The type of a block used to perform a forwad transform.
    public typealias ForwardTransformer = (value: A?) -> B?
    /// The type of a block used to perform a reverse transform.
    public typealias ReverseTransformer = (value: B?) -> A?


    // MARK: - Value Transformers

    /// The forward value transformer.
    private let forwardTransformer: ForwardTransformer
    /// The reverse value transformer, optional.
    private let reverseTransformer: ReverseTransformer?


    // MARK: - Creating a New Value Transformer

    /// Create a new value transformer using the given transformation block _forwardBlock_.
    ///
    /// - parameter forwardTransformer: A block used to perform a forward value transformation, that is
    /// from value type `A?` to `B?`.
    public class func forwardTransformer(forwardTransformer: ForwardTransformer) -> ValueTransformer<A, B> {
        return ValueTransformer<A, B>(forwardTransformer: forwardTransformer, reverseTransformer: nil)
    }

    /// Create a new value transformer using the given transformation block _forwardBlock_.
    ///
    /// - parameter forwardTransformer: A block used to perform a forward value transformation, that is
    /// from value type `A?` to `B?`.
    /// - parameter reverseTransformer: A block used to perform a reverse value transformation, that is
    /// from value type `B?` to `A?`.
    public class func reversibleForwardTransformer(forwardTransformer: ForwardTransformer, reverseTransformer: ReverseTransformer) -> ValueTransformer<A, B> {
        return ReversibleValueTransformer<A, B>(forwardTransformer: forwardTransformer, reverseTransformer: reverseTransformer)
    }

    /// Initialize a newly allocated value transformer with the given forward and reverse
    /// transformation blocks.
    ///
    /// Note: You probably want to use on of the class functions instead to get a new instance;
    /// namely `ValueTransformer.forwardTransformer()` or
    /// `ValueTransformer.reversibleForwardTransformer(reverseTransformer:)`.
    ///
    /// - parameter forwardTransformer: A block used to perform a forward value transformation, that is
    /// from value type `A?` to `B?`.
    /// - parameter reverseTransformer: A block used to perform a reverse value transformation, that is
    /// from value type `B?` to `A?`. This is an optional parameter.
    public required init(forwardTransformer: ForwardTransformer, reverseTransformer: ReverseTransformer?) {
        self.forwardTransformer = forwardTransformer
        self.reverseTransformer = reverseTransformer
    }


    // MARK: - NSValueTransformer

    public override class func transformedValueClass() -> AnyClass {
        // We’d want to return `B.self` but I don’t know how to do that yet…
        return NSObject.self
    }

    /// Returns a Boolean value that indicates whether the receiver can reverse a transformation.
    public override class func allowsReverseTransformation() -> Bool {
        return false
    }

    /// Perform the forward value transform.
    public func transformedValue(value: A?) -> B? {
        return self.forwardTransformer(value: value)
    }

}


// MARK: - ReversibleValueTransformer Class

/// Any ValueTransformer supporting reverse transformation. Necessary because
/// `allowsReverseTransformation` is a class function.
public class ReversibleValueTransformer<A, B>: ValueTransformer<A, B> {

    /// Initialize a newly allocated reversible value transformer with the given forward and
    /// reverse value transformers.
    ///
    /// - Parameters:
    ///   - forwardTransformer: A block used to perform a forward value transformation, that is
    ///     from value type `A?` to `B?`.
    ///   - reverseTransformer: A block used to perform a reverse value transformation, that is
    ///     from value type `B?` to `A?`.
    public required init(forwardTransformer: ForwardTransformer, reverseTransformer: ReverseTransformer) {
        super.init(forwardTransformer: forwardTransformer, reverseTransformer: reverseTransformer)
    }

    /// Returns a Boolean value that indicates whether the receiver can reverse a transformation.
    ///
    /// This class always allows reversible transformation.
    final public override class func allowsReverseTransformation() -> Bool {
        return true
    }

    public func reverseTransformedValue(value: B?) -> A? {
        // The explicit unwrap should be fine here as we assert during initialization that the
        // `reverseTransformer` exists and we’re immutable.
        return self.reverseTransformer!(value: value)
    }
    
}
