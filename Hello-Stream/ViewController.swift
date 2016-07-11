//
//  ViewController.swift
//  Hello-Stream
//
//  Created by Sacha Bron on 07/07/16.
//  Copyright © 2016 Sacha Bron. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	// @IBOutlet weak var viewCamera: UIView!
	@IBOutlet weak var recordBtn: UIButton!

	let recorder = KFRecorder(name: "test")
	let uploader = Uploader(endpoint: NSURL(string: "http://192.168.1.121:3000")!)
	
	let filesURL = NSURL(fileURLWithPath: Utilities.applicationSupportDirectory())
	// let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		let parentLayer: CALayer = self.view.layer

		var previewLayer = AVCaptureVideoPreviewLayer()
		previewLayer = recorder.previewLayer
		parentLayer.addSublayer(previewLayer)
		previewLayer.frame = parentLayer.frame

		// previewLayer.setVideoGravity(AVLayerVideoGravityResizeAspectFill)
		// previewLayer.connection.videoOrientation(AVCaptureVideoOrientationLandscapeRight);

		// let layerRect: CGRect = viewCamera!.bounds;

		// previewLayer.setBounds(layerRect);
		// previewLayer.setPosition(CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect)));

		// viewCamera.layer.addSublayer(previewLayer);

		recorder.session.startRunning()
		recorder.startRecording()

		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(newAssetGroupCreated), name: NotifNewAssetGroupCreated, object: nil)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func newAssetGroupCreated(notification: NSNotification) {
		print("New Asset Group - %@", notification.object);
		
		let info = notification.object as! AssetGroup
		
		let filePath: NSURL = filesURL.URLByAppendingPathComponent(info.fileName)
		
		let start = NSDate();
		uploader.sendFile(filePath) { (obj, success) in
			let end = NSDate();
			let timeInterval: Double = end.timeIntervalSinceDate(start);
			print("Time elapsed for file \(filePath.lastPathComponent!): \(timeInterval)s");
			
			if (success ?? false) {
				print("File successfuly sent!")
			} else {
				print("Error while sending file")
				print(obj)
			}
		}
	}

	@IBAction func recordTapped(sender: UIButton) {
		print("recordButtonTapped")
	}
}

