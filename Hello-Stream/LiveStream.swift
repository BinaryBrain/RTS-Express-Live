//
//  LiveStream.swift
//  RTS-Express-Live
//
//  Created by Sacha Bron on 22/07/16.
//  Copyright © 2016 Sacha Bron. All rights reserved.
//

import Foundation

class LiveStream {
	// metadata
	var title: String = ""
	var description: String = ""
	var keywords: [String] = []
	var metadataSent = false
	
	// quality parameters
	let maxBitrate = 3 * 1024 * 1024 // 3 Mbps
	let minBitrate = 1 * 1024 // 1 Kbps
	let uploadDurationRatio = 0.7
	
	let recorder = KFRecorder(name: "test")
	var uploader: Uploader? = nil
	
	let filesURL = NSURL(fileURLWithPath: Utilities.applicationSupportDirectory())
	
	static let sharedInstance = LiveStream()
	
	private init () {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(newAssetGroupCreated), name: NotifNewAssetGroupCreated, object: nil)
	}
	
	/// This function make the AVCatpureSession run. It should be called before the `record` function
	func prepare() {
		recorder.session.startRunning()
	}
	
	/// This function starts the live stream
	func record() {
		recorder.startRecording()
	}
	
	/// This function stops the live stream
	func stop() {
		metadataSent = false
		recorder.stopRecording()
	}
	
	/// This function return the status of the recording
	/// 
	/// :returns: `true` if it's streaming, `false` if it's not.
	func isRecording() -> Bool {
		return recorder.isRecording
	}
	
	/// This function is called when new video fragments are avaiable.
	/// It also manage to upload the manifest and, if needed, its metadata.
	@objc func newAssetGroupCreated(notification: NSNotification) {
		print("-- New Asset Group - %@", notification.object)
		
		let info = notification.object as! AssetGroup
		let fragmentDuration = info.duration
		let filePath: NSURL = filesURL.URLByAppendingPathComponent(info.fileName)
		let manifestPath = NSURL(fileURLWithPath: info.manifestName)
		let metadataPath = manifestPath.URLByDeletingPathExtension!.URLByAppendingPathExtension("txt")
		
		// We only want to send metadata once at the beggining of the stream.
		if (!metadataSent) {
			sendMetadata(metadataPath)
			metadataSent = true
		}

		uploadFragment(filePath, fragmentDuration: fragmentDuration)
		uploadManifest(manifestPath)
	}
	
	/// This function upload a new fragment to the server and recompute the bitrate for the next fragment.
	func uploadFragment(filePath: NSURL, fragmentDuration: Double) {
		NSLog("-- File \(filePath.path!) (\(fragmentDuration)s)")
		
		if (uploader == nil) {
			NSLog("Error: no uploader defined")
			return
		}
		
		uploader!.send(filePath) { (obj, success, duration) in
			// Compute the new bitrate to optimize upload time and quality
			var newBitrate = Int(Double(self.recorder.h264Encoder.bitrate) * fragmentDuration * self.uploadDurationRatio / duration!)
			newBitrate = min(newBitrate, self.maxBitrate)
			newBitrate = max(newBitrate, self.minBitrate)
			NSLog("New Bitrate: " + String(newBitrate))
			self.recorder.h264Encoder.bitrate = Int32(newBitrate)
			
			if (success ?? false) {
				NSLog("Upload successful (\(duration!)s)")
			} else {
				NSLog("Error while sending file")
				print(obj)
			}
		}
	}
	
	/// This function upload the manifest
	func uploadManifest(manifestPath: NSURL) {
		NSLog("-- Manifest \(manifestPath.path!)")
		
		if (uploader == nil) {
			NSLog("Error: no uploader defined")
			return
		}
		
		if (!NSFileManager.defaultManager().fileExistsAtPath(manifestPath.path!)) {
			NSLog("Error: manifest doesn't exist")
			return
		}
		
		uploader!.send(manifestPath) { (obj, success, duration) in
			if (success ?? false) {
				NSLog("Upload manifest successful")
			} else {
				NSLog("Error: cannot send manifest")
				print(obj)
			}
		}
	}
	
	/// This function creates a new file, write metadata in it, and uplod it.
	func sendMetadata(filepath: NSURL) {
		let text = title + "\n" + keywords.joinWithSeparator(", ") + "\n" + description
		
		// writing
		do {
			try text.writeToURL(filepath, atomically: false, encoding: NSUTF8StringEncoding)
			uploader!.send(filepath, { (obj, success, duration) in
				if (success ?? false) {
					NSLog("Upload metadata successful")
				} else {
					NSLog("Error: cannot send metadata")
					print(obj)
				}
			})
		}
		catch {
			NSLog("Error: cannot write metadate in file")
		}
	}
}
