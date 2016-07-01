//===----------------------------------------------------------------------===//
//
// UIPickerView.swift
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

extension UIPickerView {
    
    private class Manager: PickerViewControllerDelegate {
        var pickerViewController: PickerViewController = PickerViewController()
        var presentingView: UIView?
        
        func offScreenFrame() -> CGRect {
            if let view = presentingView {
                return CGRect(x: view.bounds.origin.x, y: view.bounds.size.height + PickerViewController.defaultViewHeight, width: view.bounds.size.width, height: PickerViewController.defaultViewHeight)
            } else {
                return CGRect(x: 0.0, y: -PickerViewController.defaultViewHeight, width: PickerViewController.defaultViewWidth, height: PickerViewController.defaultViewHeight)
            }
        }
        
        func onScreenFrame() -> CGRect {
            if let view = presentingView {
                return CGRect(x: view.bounds.origin.x, y: view.bounds.size.height - PickerViewController.defaultViewHeight, width: view.bounds.size.width, height: PickerViewController.defaultViewHeight)
            } else {
                return CGRect(x: 0.0, y: 0.0, width: PickerViewController.defaultViewWidth, height: PickerViewController.defaultViewHeight)
            }
        }
        
        func present(fromView: UIView, withTitle title: String?, configuration: UIPickerViewConfigurationBlock) {
            presentingView = fromView
            pickerViewController.toolbarTitle.title = title ?? ""
            configuration(pickerView: pickerViewController.picker)
            
            pickerViewController.view.frame = offScreenFrame()
            fromView.addSubview(pickerViewController.view)
            UIView.animateWithDuration(0.5) { 
                self.pickerViewController.view.frame = self.onScreenFrame()
            }
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Manager.uiKeyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        }
        
        func resign() {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
            
            UIView.animateWithDuration(0.4, animations: { 
                self.pickerViewController.view.frame = self.offScreenFrame()
            }) { (complete: Bool) in
                self.pickerViewController.view.removeFromSuperview()
                self.presentingView = nil
            }
        }
        
        @objc private func uiKeyboardWillShow(notification: NSNotification) {
            
        }
        
        private func didTapCancelOnPickerViewController(pickerViewController: PickerViewController) {
            resign()
        }
        
        private func didTapDoneOnPickerViewController(pickerViewController: PickerViewController) {
            resign()
        }
    }
    
    private static var manager = Manager()
    
    static func present(fromView: UIView, withTitle title: String?, configuration: UIPickerViewConfigurationBlock) {
        manager.present(fromView, withTitle: title, configuration: configuration)
    }
    
    static func present(fromView: UIView, withTitle title: String?, options: [String], selectedIndex: Int?, selectionHandler: UIPickerViewSelectionHandler) {
        
    }
    
    static func resign() {
        manager.resign()
    }
}

public typealias UIPickerViewConfigurationBlock = (pickerView: UIPickerView) -> Void
public typealias UIPickerViewSelectionHandler = (pickerView: UIPickerView, selectedItem: String, index: Int) -> Void

internal protocol PickerViewControllerDelegate {
    func didTapCancelOnPickerViewController(pickerViewController: PickerViewController)
    func didTapDoneOnPickerViewController(pickerViewController: PickerViewController)
}

internal class PickerViewController: UIViewController {
    static let defaultToolbarHeight: CGFloat = 44.0
    static let defaultPickerHeight: CGFloat = 216.0
    static let defaultViewHeight: CGFloat = 260.0
    static let defaultViewWidth: CGFloat = 320.0
    
    private var flex = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    private var toolbarTitle = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    private lazy var cancel: UIBarButtonItem = {
        [unowned self] in
        return UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(PickerViewController.didTapDone(_:)))
        }()
    private lazy var done: UIBarButtonItem = {
        [unowned self] in
        return UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(PickerViewController.didTapDone(_:)))
        }()
    private lazy var fixed: UIBarButtonItem = {
        let barButton = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        barButton.width = 8.0
        return barButton
    }()
    
    lazy var picker: UIPickerView = {
        let view = UIPickerView(frame: CGRect(x: 0, y: PickerViewController.defaultToolbarHeight, width: PickerViewController.defaultViewWidth, height: PickerViewController.defaultPickerHeight))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var delegate: PickerViewControllerDelegate?
    
    override func loadView() {
        self.view = UIView(frame: CGRect(x: 0, y: 0, width: PickerViewController.defaultViewWidth, height: PickerViewController.defaultViewHeight))
        view.backgroundColor = UIColor.clearColor()
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.frame = view.bounds
        view.addSubview(blurView)
        
        view.addConstraint(NSLayoutConstraint(item: blurView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: blurView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: blurView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: blurView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0.0))
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: PickerViewController.defaultViewWidth, height: PickerViewController.defaultToolbarHeight))
        toolbar.setItems([fixed, cancel, flex, toolbarTitle, flex, done, fixed], animated: false)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
        toolbar.addConstraint(NSLayoutConstraint(item: toolbar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: PickerViewController.defaultToolbarHeight))
        view.addConstraint(NSLayoutConstraint(item: toolbar, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: toolbar, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: toolbar, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0.0))
        
        view.addSubview(picker)
        picker.addConstraint(NSLayoutConstraint(item: picker, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: PickerViewController.defaultPickerHeight))
        view.addConstraint(NSLayoutConstraint(item: picker, attribute: .Top, relatedBy: .Equal, toItem: toolbar, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: picker, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: picker, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0.0))
    }
    
    @objc func didTapCancel(sender: UIBarButtonItem) {
        if let delegate = self.delegate {
            delegate.didTapCancelOnPickerViewController(self)
        }
    }
    
    @objc func didTapDone(sender: UIBarButtonItem) {
        if let delegate = self.delegate {
            delegate.didTapDoneOnPickerViewController(self)
        }
    }
}
