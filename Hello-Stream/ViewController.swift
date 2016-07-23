//
//  ViewController.swift
//  Hello-Stream
//
//  Created by Sacha Bron on 07/07/16.
//  Copyright © 2016 Sacha Bron. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	@IBOutlet weak var viewCamera: UIView!
	@IBOutlet weak var recordBtn: UIButton!
	
	let streamer = LiveStream(uploader: HttpUploader(endpoint: NSURL(string: "http://192.168.1.121:3000")!))
	
	var previewLayer = AVCaptureVideoPreviewLayer()
	
	override func viewDidLoad() {
		super.viewDidLoad()

		previewLayer = streamer.recorder.previewLayer

		previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
		previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
		streamer.recorder.videoConnection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft

		let layerRect: CGRect = viewCamera.bounds
		previewLayer.bounds = layerRect
		previewLayer.position = CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))
		// previewLayer.frame = layerRect
		viewCamera.layer.sublayers = nil
		viewCamera.layer.addSublayer(previewLayer)

		streamer.prepare()
	}
	
	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
		if (previewLayer.connection.supportsVideoOrientation) {
			switch (UIApplication.sharedApplication().statusBarOrientation) {
			case .LandscapeRight:
				previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
				streamer.recorder.videoConnection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
			case .LandscapeLeft:
				previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
				streamer.recorder.videoConnection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
			default:
				previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
			}
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func recordTapped(sender: UIButton) {
		print("recordButtonTapped")
		
		if (!streamer.isRecording()) {
			recordBtn.setTitle("Stop", forState: .Normal)
			streamer.record()
		} else {
			recordBtn.setTitle("Record", forState: .Normal)
			streamer.stop()
		}
	}
	
	// This view is only avaiable in lanscape mode
	override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
		return UIInterfaceOrientation.LandscapeRight
	}
	
	override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.Landscape
	}
}

