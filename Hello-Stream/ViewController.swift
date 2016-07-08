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
		
		// [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newAssetGroupCreated:) name:NotifNewAssetGroupCreated object:nil];
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func recordTapped(sender: UIButton) {
		print("recordButtonTapped")
	}
}

