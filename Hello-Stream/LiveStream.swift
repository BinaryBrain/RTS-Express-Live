//
//  LiveStream.swift
//  Hello-Stream
//
//  Created by Sacha Bron on 22/07/16.
//  Copyright © 2016 Sacha Bron. All rights reserved.
//

import Foundation

class LiveStream {
	let maxBitrate = 3 * 1024 * 1024 // 3 Mbps
	let minBitrate = 1 * 1024 // 1 Kbps
	let uploadDurationRatio = 0.7
	
	let recorder = KFRecorder(name: "test")
	var uploader: Uploader

	let filesURL = NSURL(fileURLWithPath: Utilities.applicationSupportDirectory())

	init (uploader: Uploader) {
		self.uploader = uploader
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(newAssetGroupCreated), name: NotifNewAssetGroupCreated, object: nil)
	}
	
	func prepare() {
		recorder.session.startRunning()
	}
	
	func record() {
		recorder.startRecording()
	}
	
	func stop() {
		recorder.stopRecording()
	}
	
	func isRecording() -> Bool {
		return recorder.isRecording
	}
	
	@objc func newAssetGroupCreated(notification: NSNotification) {
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
		
		uploader.send(filePath) { (obj, success, duration) in
			// Compute the new bitrate to optimize upload time and quality
			var newBitrate = Int(Double(self.recorder.h264Encoder.bitrate) * segmentDuration * self.uploadDurationRatio / duration!)
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
			
			print("Upload time: \(duration!)s")
		}
	}
	
	func uploadPlaylist(manifestPath: NSURL) {
		print("-- Manifest \(manifestPath.path!)")
		
		if (!NSFileManager.defaultManager().fileExistsAtPath(manifestPath.path!)) {
			print ("Manifest doesn't exist")
			return
		}
		
		uploader.send(manifestPath) { (obj, success, duration) in
			if (success ?? false) {
				print("Upload manifest successful")
			} else {
				print("Error while sending manifest")
				print(obj)
			}
		}
	}
}
