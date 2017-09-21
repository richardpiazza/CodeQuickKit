//===----------------------------------------------------------------------===//
//
// UITableView.swift
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

public extension UITableView {
    public func register<T: UITableViewCell>(nibClass: T.Type) {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.reuseIdentifier(), bundle: bundle)
        self.register(nib, forCellReuseIdentifier: T.reuseIdentifier())
    }
    
    public func dequeueReusableCell<T: UITableViewCell>(withClass: T.Type, for indexPath: IndexPath) -> T {
        let identifier = T.reuseIdentifier()
        guard let cell = self.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
            fatalError("\(#function); Failed to dequeue cell with identifier '\(identifier)'")
        }
        
        return cell
    }
}

#endif
