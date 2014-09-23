//
//  ViewController.swift
//  helpDesk
//
//  Created by Alexey Chulochnikov on 29.08.14.
//  Copyright (c) 2014 Alexey Chulochnikov. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController, UINavigationControllerDelegate {
	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet weak var userPhoto: UIImageView!
	@IBOutlet weak var locationTextField: UITextField!
	@IBOutlet weak var descriptionTextField: UITextField!
	@IBOutlet weak var photoPlaceHolderLabel: UILabel!
	
	let alert = UIAlertView()
	
	var activeField: UITextField?
	var imagePickerController: UIImagePickerController!
	
	var scanPicker = ScanditSDKBarcodePicker(appKey: "mHbeTgp5EeSKsmLJfKEh7Cg56poI/nKQw2Hb8HRrI/U", cameraFacingPreference: CAMERA_FACING_BACK)
	var scanditOverlayController = ScanditSDKOverlayController()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		scanditOverlayController.setBeepEnabled(false)
		registerForKeyboardNotification()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	@IBAction func textFieldDidBeginEditing(sender: UITextField) {
		activeField = sender;
	}
	
	@IBAction func textFieldDidEndEditing(sender: UITextField) {
		activeField = nil;
	}
	
	@IBAction func blurTextField(sender: UITapGestureRecognizer) {
		if var activeField = activeField? {
			scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
			activeField.resignFirstResponder()
		}
	}
	
	@IBAction func doSendData(sender: UIButton) {
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
			imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
			imagePickerController.allowsEditing = true
			imagePickerController.delegate = self
			
			self.presentViewController(imagePickerController, animated: true, completion: nil)
		}
	}
	
	@IBAction func showScanViewModally(sender: UIButton) {
		self.scanPicker.force2dRecognition(false)
		self.scanPicker.overlayController.showToolBar(true)
		self.scanPicker.overlayController.delegate = self
		
		presentViewController(scanPicker, animated: true, completion: {})
		scanPicker.startScanning()
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

extension ViewController: UIImagePickerControllerDelegate {
	func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
		userPhoto.image = image
		photoPlaceHolderLabel.text = ""
		imagePickerController.dismissViewControllerAnimated(true, completion: nil)
	}
}

extension ViewController: ScanditSDKOverlayControllerDelegate {
	func scanditSDKOverlayController(overlayController: ScanditSDKOverlayController!, didCancelWithStatus status: [NSObject : AnyObject]!) {
		dismissViewControllerAnimated(true, completion: {
			self.scanPicker.stopScanning()
		})
	}
	
	func scanditSDKOverlayController(overlayController: ScanditSDKOverlayController!, didManualSearch text: String!) {
		
	}
	
	func scanditSDKOverlayController(overlayController: ScanditSDKOverlayController!, didScanBarcode barcode: [NSObject : AnyObject]!) {
		if let scanResult = barcode as? Dictionary<String, AnyObject> {
			dismissViewControllerAnimated(true, completion: {
				self.scanPicker.stopScanning()
				self.locationTextField.text = barcode.description
			})
		}
	}
}