#if os(iOS)

import UIKit

public protocol ProgrammaticViewInitializable {
    func initializeSubviews()
}

open class ProgrammaticView: UIView, ProgrammaticViewInitializable {
    
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
}

open class ProgrmmaticTableViewCell: UITableViewCell, ProgrammaticViewInitializable {
    
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
}

open class ProgrammaticCollectionReusableView: UICollectionReusableView, ProgrammaticViewInitializable {
    
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
}

open class ProgrammaticCollectionViewCell: UICollectionViewCell, ProgrammaticViewInitializable {
    
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
}

#endif
