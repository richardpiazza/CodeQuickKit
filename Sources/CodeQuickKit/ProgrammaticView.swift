#if canImport(UIKit)
import UIKit

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
