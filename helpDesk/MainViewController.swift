//
//  ViewController.swift
//  helpDesk
//
//  Created by Alexey Chulochnikov on 29.08.14.
//  Copyright (c) 2014 Alexey Chulochnikov. All rights reserved.
//

import UIKit

class ViewController: UIViewController  {
	@IBOutlet var scrollView: UIScrollView!
	var activeField: UITextField?
	
	@IBOutlet weak var userPhoto: UIImageView!
	
	@IBOutlet weak var locationTextField: UITextField!
	@IBOutlet weak var descriptionTextField: UITextField!
	
	
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
	
	@IBAction func doSendData(sender: UIButton) {
		userPhoto.image = UIImage(named: "image") //FIXME: do not set default image, use photo provided by the user
		let alert = UIAlertView()
		alert.title = "something went wrong"
		alert.addButtonWithTitle("Ok")
		
		if (locationTextField.hasText() && descriptionTextField.hasText()) {
			var net = Net()
			
			var photo = UIImagePNGRepresentation(userPhoto.image).base64EncodedStringWithOptions(NSDataBase64EncodingOptions.fromRaw(0)!)
			
			var params = ["location": locationTextField.text, "photo": photo, "description": descriptionTextField.text]
			println("params \(params)")
			
			net.POST(absoluteUrl: "http://ciklum-helpdesk.appspot.com/issue/", params: params, successHandler: successfulRequest, failureHandler: failureRequest)
		} else if (!locationTextField.hasText() && !descriptionTextField.hasText()){
			alert.message = "\nloc and desc is empty"
			alert.show()
		} else if (!locationTextField.hasText()) {
			alert.message = "\nloc is empty"
			alert.show()
		} else if (!descriptionTextField.hasText()) {
			alert.message = "\ndesc is empty"
			alert.show()
		}
	}
	
	func successfulRequest(ResponseData) {
		var response = ResponseData.self
		println("successfulRequest: \(response)")
	}
	
	func failureRequest(NSError!) {
		var error = NSError.self
		println("failureRequest: \(error)")
	}
}

