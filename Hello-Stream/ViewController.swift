//
//  ViewController.swift
//  Hello-Stream
//
//  Created by Sacha Bron on 07/07/16.
//  Copyright © 2016 Sacha Bron. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	let maxBitrate = 3 * 1024 * 1024 // 3 Mbps
	let minBitrate = 1 * 1024 // 1 Kbps
	let uploadDurationRatio = 0.7

	@IBOutlet weak var recordBtn: UIButton!

	let recorder = KFRecorder(name: "test")
	let uploader = Uploader(endpoint: NSURL(string: "http://192.168.1.121:3000")!)

	let filesURL = NSURL(fileURLWithPath: Utilities.applicationSupportDirectory())

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
		print("-- New Asset Group - %@", notification.object);

		let info = notification.object as! AssetGroup
		let segmentDuration = info.duration
		let filePath: NSURL = filesURL.URLByAppendingPathComponent(info.fileName)
		let manifestPath = NSURL(fileURLWithPath: info.manifestName)
		
		uploadSegment(filePath, segmentDuration: segmentDuration)
		uploadPlaylist(manifestPath)
	}

	func uploadSegment(filePath: NSURL, segmentDuration: Double) {
		print("-- File \(filePath.path!) (\(segmentDuration)s)")
		let startTime = NSDate()

		uploader.addFileToQueue(filePath) { (obj, success) in
			let endTime = NSDate()
			let uploadDuration: Double = endTime.timeIntervalSinceDate(startTime)

			// Compute the new bitrate to optimize upload time and
			var newBitrate = Int(Double(self.recorder.h264Encoder.bitrate) * segmentDuration * self.uploadDurationRatio / uploadDuration)
			newBitrate = min(newBitrate, self.maxBitrate)
			newBitrate = max(newBitrate, self.minBitrate)
			print("New Bitrate: " + String(newBitrate))
			self.recorder.h264Encoder.bitrate = Int32(newBitrate)

			if (success ?? false) {
				print("Upload successful")
			} else {
				print("Error while sending file")
				print(obj)
			}

			print("Upload time: \(uploadDuration)s")
		}
	}

	func uploadPlaylist(manifestPath: NSURL) {
		print("-- Manifest \(manifestPath.path!)")

		if (!NSFileManager.defaultManager().fileExistsAtPath(manifestPath.path!)) {
			print ("Manifest doesn't exist")
			return
		}

		uploader.addFileToQueue(manifestPath) { (obj, success) in
			if (success ?? false) {
				print("Upload manifest successful")
			} else {
				print("Error while sending manifest")
				print(obj)
			}
		}
	}

	@IBAction func recordTapped(sender: UIButton) {
		print("recordButtonTapped")
	}
}

