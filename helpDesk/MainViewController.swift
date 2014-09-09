//
//  ViewController.swift
//  helpDesk
//
//  Created by Alexey Chulochnikov on 29.08.14.
//  Copyright (c) 2014 Alexey Chulochnikov. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
	@IBOutlet var scrollView: UIScrollView!
	var activeField: UITextField?
	var imagePickerController: UIImagePickerController!
	let alert = UIAlertView()
	
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
	
	@IBAction func takeAccidentPhoto(sender: UIButton) {
		if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
			imagePickerController = UIImagePickerController()
			imagePickerController.delegate = self
			imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
			imagePickerController.allowsEditing = true
			
			self.presentViewController(imagePickerController, animated: true, completion: nil)
		}
	}
	
	func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
		userPhoto.image = image
		imagePickerController.dismissViewControllerAnimated(true, completion: nil)
	}
	
	func successfulRequest(ResponseData) {
		var response = ResponseData.self
		alert.message = "successfulRequest: \(response)"
		alert.show()
	}
	
	func failureRequest(NSError!) {
		var error = NSError.self
		alert.message = "failureRequest: \(error)"
		alert.show()
	}
}

