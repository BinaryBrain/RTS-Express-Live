//
//  ViewController.swift
//  Hello-Stream
//
//  Created by Sacha Bron on 07/07/16.
//  Copyright © 2016 Sacha Bron. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	@IBOutlet weak var recordBtn: UIButton!
	
	let streamer = LiveStream(uploader: HttpUploader(endpoint: NSURL(string: "http://192.168.1.121:3000")!))

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view, typically from a nib.

		let parentLayer: CALayer = self.view.layer

		var previewLayer = AVCaptureVideoPreviewLayer()
		previewLayer = streamer.recorder.previewLayer
		parentLayer.addSublayer(previewLayer)
		previewLayer.frame = parentLayer.frame

		// previewLayer.setVideoGravity(AVLayerVideoGravityResizeAspectFill)
		// previewLayer.connection.videoOrientation(AVCaptureVideoOrientationLandscapeRight);

		// let layerRect: CGRect = viewCamera!.bounds;

		// previewLayer.setBounds(layerRect);
		// previewLayer.setPosition(CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect)));

		// viewCamera.layer.addSublayer(previewLayer);

		streamer.record()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func recordTapped(sender: UIButton) {
		print("recordButtonTapped")
	}
}

