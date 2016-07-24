//
//  FormViewController.swift
//  Hello-Stream
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
	func keyboardDidShow(notification: NSNotification) {
		let userInfo: NSDictionary = notification.userInfo!
		let keyboardSize = userInfo.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue.size
		let contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
		scrollView.contentInset = contentInsets
		scrollView.scrollIndicatorInsets = contentInsets

		var viewRect = view.frame
		viewRect.size.height -= keyboardSize.height
	}

	func keyboardWillHide(notification: NSNotification) {
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
	
	@IBAction func nextTapped(sender: UIButton) {
		print("asd")
	}
}
