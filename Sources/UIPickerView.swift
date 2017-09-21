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

#if os(iOS)

import UIKit

extension UIPickerView {
    
    fileprivate class Manager: PickerViewControllerDelegate {
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
        
        func present(_ fromView: UIView, withTitle title: String?, configuration: UIPickerViewConfigurationBlock) {
            presentingView = fromView
            pickerViewController.toolbarTitle.title = title ?? ""
            configuration(pickerViewController.picker)
            
            pickerViewController.view.frame = offScreenFrame()
            fromView.addSubview(pickerViewController.view)
            UIView.animate(withDuration: 0.5, animations: { 
                self.pickerViewController.view.frame = self.onScreenFrame()
            }) 
            
            NotificationCenter.default.addObserver(self, selector: #selector(Manager.uiKeyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        }
        
        func resign() {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            
            UIView.animate(withDuration: 0.4, animations: { 
                self.pickerViewController.view.frame = self.offScreenFrame()
            }, completion: { (complete: Bool) in
                self.pickerViewController.view.removeFromSuperview()
                self.presentingView = nil
            }) 
        }
        
        @objc fileprivate func uiKeyboardWillShow(_ notification: Notification) {
            
        }
        
        fileprivate func didTapCancelOnPickerViewController(_ pickerViewController: PickerViewController) {
            resign()
        }
        
        fileprivate func didTapDoneOnPickerViewController(_ pickerViewController: PickerViewController) {
            resign()
        }
    }
    
    fileprivate static var manager = Manager()
    
    static func present(_ fromView: UIView, withTitle title: String?, configuration: UIPickerViewConfigurationBlock) {
        manager.present(fromView, withTitle: title, configuration: configuration)
    }
    
    static func present(_ fromView: UIView, withTitle title: String?, options: [String], selectedIndex: Int?, selectionHandler: UIPickerViewSelectionHandler) {
        
    }
    
    static func resign() {
        manager.resign()
    }
}

public typealias UIPickerViewConfigurationBlock = (_ pickerView: UIPickerView) -> Void
public typealias UIPickerViewSelectionHandler = (_ pickerView: UIPickerView, _ selectedItem: String, _ index: Int) -> Void

internal protocol PickerViewControllerDelegate {
    func didTapCancelOnPickerViewController(_ pickerViewController: PickerViewController)
    func didTapDoneOnPickerViewController(_ pickerViewController: PickerViewController)
}

internal class PickerViewController: UIViewController {
    static let defaultToolbarHeight: CGFloat = 44.0
    static let defaultPickerHeight: CGFloat = 216.0
    static let defaultViewHeight: CGFloat = 260.0
    static let defaultViewWidth: CGFloat = 320.0
    
    fileprivate var flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    fileprivate var toolbarTitle = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    fileprivate lazy var cancel: UIBarButtonItem = {
        [unowned self] in
        return UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(PickerViewController.didTapDone(_:)))
        }()
    fileprivate lazy var done: UIBarButtonItem = {
        [unowned self] in
        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PickerViewController.didTapDone(_:)))
        }()
    fileprivate lazy var fixed: UIBarButtonItem = {
        let barButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
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
        view.backgroundColor = UIColor.clear
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.frame = view.bounds
        view.addSubview(blurView)
        
        view.addConstraint(NSLayoutConstraint(item: blurView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: blurView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: blurView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: blurView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0.0))
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: PickerViewController.defaultViewWidth, height: PickerViewController.defaultToolbarHeight))
        toolbar.setItems([fixed, cancel, flex, toolbarTitle, flex, done, fixed], animated: false)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
        toolbar.addConstraint(NSLayoutConstraint(item: toolbar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: PickerViewController.defaultToolbarHeight))
        view.addConstraint(NSLayoutConstraint(item: toolbar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: toolbar, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: toolbar, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0.0))
        
        view.addSubview(picker)
        picker.addConstraint(NSLayoutConstraint(item: picker, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: PickerViewController.defaultPickerHeight))
        view.addConstraint(NSLayoutConstraint(item: picker, attribute: .top, relatedBy: .equal, toItem: toolbar, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: picker, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: picker, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0.0))
    }
    
    @objc func didTapCancel(_ sender: UIBarButtonItem) {
        if let delegate = self.delegate {
            delegate.didTapCancelOnPickerViewController(self)
        }
    }
    
    @objc func didTapDone(_ sender: UIBarButtonItem) {
        if let delegate = self.delegate {
            delegate.didTapDoneOnPickerViewController(self)
        }
    }
}

#endif
