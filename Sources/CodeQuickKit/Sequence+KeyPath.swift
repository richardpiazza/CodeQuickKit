import Foundation

public extension Sequence {
    func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        return map { $0[keyPath: keyPath] }
    }
    
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { lhs, rhs in
            return lhs[keyPath: keyPath] < rhs[keyPath: keyPath]
        }
    }
    
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, Optional<T>>) -> [Element] {
        return sorted { lhs, rhs in
            let lhsComparable = lhs[keyPath: keyPath]
            let rhsComparable = rhs[keyPath: keyPath]
            
            switch (lhsComparable, rhsComparable) {
            case (.some(let lhsValue), .some(let rhsValue)):
                return lhsValue < rhsValue
            case (.some, .none):
                return true
            case (.none, .some):
                return false
            default:
                return true
            }
        }
    }
}
