#if canImport(UIKit)
import UIKit

@available(*, deprecated, message: "UIKit focused api that will be removed in the next major version.")
open class ProgrammaticView: UIView {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSubviews()
    }
    
    open func initializeSubviews() {
        
    }
    
    open func updateSubviews() {
        
    }
}

@available(*, deprecated, message: "UIKit focused api that will be removed in the next major version.")
open class ProgrmmaticTableViewCell: UITableViewCell {
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initializeSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSubviews()
    }
    
    open func initializeSubviews() {
        
    }
    
    open func updateSubviews() {
        
    }
}

@available(*, deprecated, message: "UIKit focused api that will be removed in the next major version.")
open class ProgrammaticCollectionReusableView: UICollectionReusableView {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSubviews()
    }
    
    open func initializeSubviews() {
        
    }
    
    open func updateSubviews() {
        
    }
}

@available(*, deprecated, message: "UIKit focused api that will be removed in the next major version.")
open class ProgrammaticCollectionViewCell: UICollectionViewCell {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSubviews()
    }
    
    open func initializeSubviews() {
        
    }
    
    open func updateSubviews() {
        
    }
}
#endif
