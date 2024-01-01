import Foundation

public struct CasePath<Root, Value> {
    public let extract: (Root) -> Value?
    public let embed: (Value) -> Root
    public init(embed: @escaping (Value) -> Root, extract: @escaping (Root) -> Value?) {
        self.extract = extract
        self.embed = embed
    }
}

public protocol CasePathable {
    associatedtype Cases
    static var cases: Cases { get }
}

public typealias CaseKeyPath<Root: CasePathable, Value> =
KeyPath<Root.Cases, CasePath<Root, Value>>
