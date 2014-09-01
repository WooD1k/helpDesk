//
//  ViewController.swift
//  helpDesk
//
//  Created by Alexey Chulochnikov on 29.08.14.
//  Copyright (c) 2014 Alexey Chulochnikov. All rights reserved.
//

//import Foundation
import UIKit

class ViewController: UIViewController {
	@IBOutlet var scrollView: UIScrollView!
	var activeField: UITextField?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		registerForKeyboardNotification()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func textFieldDidBeginEditing(sender: UITextField) {
		activeField = sender;
	}
	
	@IBAction func textFieldDidEndEditing(sender: UITextField) {
		activeField = nil;
	}

	func registerForKeyboardNotification() {
		var notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardWasShown:", name: "UIKeyboardDidShowNotification", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: "UIKeyboardWillHideNotification", object: nil)
	}
	
	func keyBoardWasShown(notification: NSNotification) {
		var info = notification.userInfo!

		var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
		let keyboardSize = keyboardFrame.size
		
		var bkgndRect = scrollView.frame;
		var contentOffset = -(activeField!.frame.origin.y - keyboardSize.height)
		
		bkgndRect.size.height += keyboardSize.height;
		scrollView.frame = bkgndRect
		scrollView.setContentOffset(CGPoint(x: 0.0, y: contentOffset), animated: true)

	}
	
	func keyboardWillBeHidden(notification: NSNotification) {
		var contentInsets = UIEdgeInsetsZero;
		
		scrollView.contentInset = contentInsets;
		scrollView.scrollIndicatorInsets = contentInsets;
	}
	
	@IBAction func blurTextField(sender: UITapGestureRecognizer) {
		if var activeField = activeField? {
			scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
			activeField.resignFirstResponder()
		}
	}
}

