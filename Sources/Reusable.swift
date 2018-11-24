#if os(iOS) || os(tvOS)
import UIKit

/// Reusable is meant to make working with UIStoryboard/UINibs
/// easier by requiring certain naming conventions.
///
/// The default implementation of Reusable will return a string
/// representation of the adopting class.
///
/// * **UIViewController**: When creating a UIViewController, set
///   the 'Storyboard ID' in Interface Builder, to the same subclass
///   name.
///
/// * **UITableViewCell**: When creating UITableViewCell subclasses
///   with XIBs, be sure to keep the nib and class names in sync.
///
public protocol Reusable: class {
    static var reuseIdentifier: String { get }
}

public extension Reusable {
    public static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UIView: Reusable {}

extension UIViewController: Reusable {}

public extension UIStoryboard {
    /// Instantiates a UIViewController for the provided `Reusable` type.
    /// - throws: NSInvalidArgumentException (when unable to locate view with identifier)
    public func instantiateViewController<T: Reusable>(withType type: T.Type) -> T {
        return self.instantiateViewController(withIdentifier: type.reuseIdentifier) as! T
    }
}

public extension UITableView {
    /// Registers a UITableViewCell.Type with the tableView.
    /// This implementation relys on the `Reusable` protocol for
    /// supplyings a 'reuseIdentifier'.
    ///
    /// When creating UITableViewCell subclasses, if you are using
    /// a XIB, be sure to name the file exactly after the class name.
    /// (This is the default behavior).
    ///
    /// - example:
    /// class MyCustomTableViewCell: UITableViewCell {}
    /// * MyCustomTableViewCell.swift
    /// * MyCustomTableViewCell.xib
    ///
    public func register<T: UITableViewCell>(reusableType: T.Type) {
        let bundle = Bundle(for: T.self)
        if let _ = bundle.url(forResource: T.reuseIdentifier, withExtension: "nib") {
            let nib = UINib(nibName: T.reuseIdentifier, bundle: bundle)
            self.register(nib, forCellReuseIdentifier: T.reuseIdentifier)
        } else {
            self.register(reusableType, forCellReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    /// Dequeue a UITableViewCell for the specific type.
    /// This implementation relys on the `Reusable` protocol for
    /// suppling the needed 'reuseIdentifier'.
    public func dequeueReusableCell<T: UITableViewCell>(withType: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("\(#function); Failed to dequeue cell with identifier '\(T.reuseIdentifier)'")
        }
        
        return cell
    }
}

public extension UICollectionView {
    /// Registers a UICollectionViewCell.Type with the `collectionView`.
    public func register<T: UICollectionViewCell>(reusableType: T.Type) {
        let bundle = Bundle(for: T.self)
        if let _ = bundle.url(forResource: T.reuseIdentifier, withExtension: "nib") {
            let nib = UINib(nibName: T.reuseIdentifier, bundle: bundle)
            self.register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
        } else {
            self.register(reusableType, forCellWithReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    /// Dequeue a typed UICollectionViewCell from the `collectionView`.
    public func dequeueReusableCell<T: UICollectionViewCell>(withType: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("\(#function); Failed to dequeue cell with identifier '\(T.reuseIdentifier)'")
        }
        
        return cell
    }
    
    /// Registers a UICollectionReusableView.Type with the `collectionView`.
    ///
    /// Default/Defined kinds:
    /// * UICollectionView.elementKindSectionHeader
    /// * UICollectionView.elementKindSectionFooter
    public func register<T: UICollectionReusableView>(reusableType: T.Type, supplementaryViewOfKind ofKind: String) {
        let bundle = Bundle(for: T.self)
        if let _ = bundle.url(forResource: T.reuseIdentifier, withExtension: "nib") {
            let nib = UINib(nibName: T.reuseIdentifier, bundle: bundle)
            self.register(nib, forSupplementaryViewOfKind: ofKind, withReuseIdentifier: T.reuseIdentifier)
        } else {
            self.register(reusableType, forSupplementaryViewOfKind: ofKind, withReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    /// Dequeue a typed UICollectionReusableView from the `collectionView`.
    ///
    /// Default/Defined kinds:
    /// * UICollectionView.elementKindSectionHeader
    /// * UICollectionView.elementKindSectionFooter
    public func dequeueReusableSupplementaryView<T: UICollectionReusableView>(withType: T.Type, ofKind: String, for indexPath: IndexPath) -> T {
        guard let view = self.dequeueReusableSupplementaryView(ofKind: ofKind, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("\(#function); Failed to dequeue supplementary view with identifier '\(T.reuseIdentifier)'")
        }
        
        return view
    }
}

#endif
