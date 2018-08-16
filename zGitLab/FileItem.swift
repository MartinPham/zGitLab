//
//  FileItem.swift
//  zGitLab
//
//  Created by MartinPham on 4/9/16.
//  Copyright © 2016 martinpham. All rights reserved.
//

import Foundation

class FileItem : Item {
	
	
	override init (data: [String: AnyObject] = [:]) {
		super.init(data: data)
		
		self.type = .FILE
	}
	
	func getPath() -> String
	{
		return self.path + self.name
	}
	
	
	func getURL() -> String
	{
		return self.repository.url as String + "/blob/master" + self.getPath()
	}
	
	
	func read(_ callback:@escaping (_ response: AnyObject) -> Void) {
		API.request(
			"/projects/" + self.repository.id + "/repository/files",
			data: [
				"file_path": self.getPath(),
				"ref": "master"
			]
		){ (response) in
			AppDelegate.sharedInstance().setCache(self.repository.id + "_" + self.getPath(), value: response)
			
			callback(response: response)
		}
		
		
	}
	
	func update(_ content: String = "", callback:(_ response: AnyObject) -> Void) {
		API.request(
			"/projects/" + self.repository.id + "/repository/files",
			data: [
				"file_path": self.getPath(),
				"branch_name": "master",
				"content": content,
				"commit_message": "Updated file: " + self.getPath(),
				"ref": "master"
			],
			method: .PUT,
			callback: callback
		)
	}
	func delete(_ callback:(_ response: AnyObject) -> Void) {
		API.request(
			"/projects/" + self.repository.id + "/repository/files",
			data: [
				"file_path": self.getPath(),
				"branch_name": "master",
				"commit_message": "Deleted file: " + self.getPath(),
				"ref": "master"
			],
			method: .DELETE,
			callback: callback
		)
	}
}
