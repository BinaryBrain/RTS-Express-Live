//
//  HttpUploader.swift
//  Hello-Stream
//
//  Created by Sacha Bron on 22/07/16.
//  Copyright © 2016 Sacha Bron. All rights reserved.
//

import Foundation

class HttpUploader: Uploader {
	let url: NSURL
	let timeout = 15.0 // in seconds
	
	var queue: [(NSURL, completionHandler?)] = []
	
	required init (endpoint: NSURL) {
		self.url = endpoint
		print("")
	}
	
	typealias completionHandler = (obj: AnyObject?, success: Bool?, duration: Double?) -> Void
	
	func send(filePath: NSURL, _ aHandler: completionHandler?) {
		print("Upload queue size: " + String(queue.count))
		
		queue.append((filePath, aHandler))
		
		if (queue.count == 1) {
			sendFile(queue.first!.0, queue.first!.1)
		}
	}
	
	private func sendFile(filePath: NSURL, _ handler: completionHandler?) {
		let startTime = NSDate()
		
		let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
		let request = NSMutableURLRequest(URL: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
		request.HTTPMethod = "POST"
		
		// Set Content-Type in HTTP header.
		let boundaryConstant = "Boundary-7MA4YWxkTLLu0UIW"; // This should be auto-generated.
		let contentType = "multipart/form-data; boundary=" + boundaryConstant
		
		let fileName = filePath.lastPathComponent!
		let mimeType = "video/MP2T"
		let folder = "test"
		
		request.setValue(contentType, forHTTPHeaderField: "Content-Type")
		
		// Set data
		do {
			let dataString = "--\(boundaryConstant)\r\n" +
				"Content-Disposition: form-data; name=\"folder\"\r\n" +
				"\r\n" +
				"\(folder)" +
				"\r\n" +
				"--\(boundaryConstant)\r\n" +
				"Content-Disposition: form-data; name=\"filename\"\r\n" +
				"\r\n" +
				"\(fileName)" +
				"\r\n" +
				"--\(boundaryConstant)\r\n" +
				"Content-Disposition: form-data; name=\"fragment\"; filename=\"\(fileName)\"\r\n" +
				"Content-Type: \(mimeType)\r\n\r\n"
			
			let body = NSMutableData()
			body.appendData(dataString.dataUsingEncoding(NSUTF8StringEncoding)!)
			body.appendData(NSData(contentsOfFile: filePath.path!)!)
			body.appendData("\r\n\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
			
			request.HTTPBody = body
			
			// Async call
			let session = NSURLSession.sharedSession()
			let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
				let endTime = NSDate()
				let uploadDuration: Double = endTime.timeIntervalSinceDate(startTime)
				
				if (error != nil) {
					handler?(obj: error, success: false, duration: uploadDuration)
					
					// If there's a timeout, we retry uploading
					if error?.code != NSURLErrorTimedOut {
						self.queue.removeFirst()
					}
				} else {
					handler?(obj: data, success: true, duration: uploadDuration)
					self.queue.removeFirst()
				}
				
				if (!self.queue.isEmpty) {
					self.sendFile(self.queue.first!.0, self.queue.first!.1)
				}
			})
			
			// Run the async call
			task.resume()
		}
	}
}