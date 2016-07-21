//===----------------------------------------------------------------------===//
//
// UIImage.swift
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

import UIKit

extension UIImage {
    static func filledImage(withPath path: CGMutablePathRef, color: UIColor, context: CGContextRef?) -> UIImage? {
        guard let ctx = context else {
            return nil
        }
        
        var image: UIImage?
        
        CGContextSetLineWidth(ctx, 0)
        CGContextSetFillColorWithColor(ctx, color.CGColor)
        CGContextAddPath(ctx, path)
        CGContextFillPath(ctx)
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        
        return image
    }
    
    static func strokedImage(withPath path: CGMutablePathRef, color: UIColor, strokeWidth: CGFloat, context: CGContextRef?) -> UIImage? {
        guard let ctx = context else {
            return nil
        }
        
        var image: UIImage? = nil
        
        CGContextSetLineWidth(ctx, strokeWidth)
        CGContextSetStrokeColorWithColor(ctx, color.CGColor)
        CGContextAddPath(ctx, path)
        CGContextStrokePath(ctx)
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        
        return image
    }
}
