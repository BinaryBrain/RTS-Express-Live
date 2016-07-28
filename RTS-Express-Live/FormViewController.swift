//
//  FormViewController.swift
//  RTS-Express-Live
//
//  Created by Sacha Bron on 23/07/16.
//  Copyright © 2016 Sacha Bron. All rights reserved.
//

import UIKit

class FormViewController: UIViewController, UITextFieldDelegate {
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var titleField: UITextField!
	@IBOutlet weak var descriptionField: UITextView!
	@IBOutlet weak var keywordsField: UITextField!
	@IBOutlet weak var nextButton: UIButton!

	override func viewDidLoad() {
		super.viewDidLoad()
		titleField.delegate = self
		keywordsField.delegate = self
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FormViewController.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FormViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self)	}

	// Listeners to adapt the scroll view to the right size
	@objc private func keyboardDidShow(notification: NSNotification) {
		let userInfo: NSDictionary = notification.userInfo!
		let keyboardSize = userInfo.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue.size
		let contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
		scrollView.contentInset = contentInsets
		scrollView.scrollIndicatorInsets = contentInsets

		var viewRect = view.frame
		viewRect.size.height -= keyboardSize.height
	}

	@objc private func keyboardWillHide(notification: NSNotification) {
		scrollView.contentInset = UIEdgeInsetsZero
		scrollView.scrollIndicatorInsets = UIEdgeInsetsZero
	}

	// Manage the "Next" and "Done" buttons on the keyboard
	func textFieldShouldReturn(field: UITextField) -> Bool {
		if (field == titleField) {
			descriptionField.becomeFirstResponder()
			return true
		} else if (field == keywordsField) {
			self.view.endEditing(true)
			return false
		}

		return true
	}

	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
		// Filling the form is mandatory. This display an alert otherwise.
		if (titleField.text!.isEmpty || descriptionField.text!.isEmpty || keywordsField.text!.isEmpty) {
			let alert = UIAlertController(title: "Formulaire incomplet", message: "Veuillez compléter tous les champs du formulaire.", preferredStyle: UIAlertControllerStyle.Alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
			self.presentViewController(alert, animated: true, completion: nil)
			
			return false
		}
		return true
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
		if (segue.identifier == "SendFormSegue") {
			// Define live stream metadata
			let destViewController = segue.destinationViewController as! ViewController
			destViewController.streamer.title = titleField.text!
			destViewController.streamer.description = descriptionField.text!
			destViewController.streamer.keywords = extractKeywords(keywordsField.text!)
		}
	}
	
	/// This function extract an array of keywords from a string and trim spaces
	///
	/// :param: keywords The string of keywords, separated by commas
	///
	/// :returns: An array of keywords
	private func extractKeywords(keywords: String) -> [String] {
		let keywordsArray = keywords.componentsSeparatedByString(",").map({
			keyword in keyword.stringByTrimmingCharactersInSet(
				NSCharacterSet.whitespaceAndNewlineCharacterSet()
			)
		})
		
		return keywordsArray
	}
}
