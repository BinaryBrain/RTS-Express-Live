//
//  Uploader.swift
//  Hello-Stream
//
//  Created by Sacha Bron on 25/06/16.
//  Copyright © 2016 Sacha Bron. All rights reserved.
//

import Foundation

protocol Uploader {
	func send(filePath: NSURL, _ handler: ((obj: AnyObject?, success: Bool?, duration: Double?) -> Void)?) -> Void

	init (endpoint: NSURL)
}
