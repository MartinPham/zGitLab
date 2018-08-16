//
//  DirectoryItem.swift
//  zGitLab
//
//  Created by MartinPham on 4/9/16.
//  Copyright © 2016 martinpham. All rights reserved.
//

import Foundation

class DirectoryItem: Item {
	
	override init (data: [String: AnyObject] = [:]) {
		super.init(data: data)
		
		self.type = .DIRECTORY
	}
	
	func getPath() -> String
	{
		return self.path + self.name + "/"
	}
	
	
	func getURL() -> String
	{
		return self.repository.url + "/tree/master/" + self.getPath()
	}
	
	
	
	func browse(_ params: [String: AnyObject] = [:], callback:(_ response: AnyObject) -> Void)
	{
		self.repository.browse(self.getPath(), callback: callback)
	}
	
	func createFile(_ name: String = "", content: String = "", callback:(_ response: AnyObject) -> Void) {
		self.repository.createFile(self.getPath() + name, content: content, callback: callback)
	}
	
	
}
