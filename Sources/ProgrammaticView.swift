//===----------------------------------------------------------------------===//
//
// ProgrammaticView.swift
//
// Copyright (c) 2016 Richard Piazza
// https://github.com/richardpiazza/CodeQuickKit
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//===----------------------------------------------------------------------===//

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
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
