//
//  Repository.swift
//  zGitLab
//
//  Created by MartinPham on 4/9/16.
//  Copyright © 2016 martinpham. All rights reserved.
//

import Foundation
import AwesomeCache

class Repository {
	static func find(_ params: [String: AnyObject] = [:], callback: @escaping (_ response: AnyObject) -> Void)
	{
		AppDelegate.sharedInstance().cacheAction(Config.ck_repositories, callback: { (response) in
			var results: [Repository] = [];
			for repo in response as! Array<[String: AnyObject]>
			{
				let repository = Repository(data: repo)
				
				results.append(repository)
			}
			
			callback(response: results)
			
			}) { (key, successCallback) in
				API.request("/projects", data: params)  { (response) in
					AppDelegate.sharedInstance().setCache(Config.ck_repositories, value: response)
					
					successCallback(response: response)
					
				}
		}
				
		
	}
	
	var id: String = ""
	var name: String = ""
	var fullname: String = ""
	var avatar: String = ""
	var isPublic: Bool = true
	var url: String = ""
	
	init (data: [String: AnyObject] = [:]) {
		if(!data.isEmpty) {
			self.id = String(describing: data["id"]!)
			self.name = String(describing: data["name"]!)
			self.fullname = String(describing: data["name_with_namespace"]!)
			self.avatar = String(describing: data["avatar_url"]!)
			self.isPublic = Int(data["public"]! as! NSNumber) == 1
			self.url = data["web_url"] as! String
		}
		
	}
	
	func browse(_ path: String, params: [String: AnyObject] = [:], callback: @escaping (_ response: AnyObject) -> Void)
	{
		var params: [String: AnyObject] = params
		params["path"] = (path as NSString).substring(from: 1) as AnyObject?
		
		let key = self.id + "_" + path
		
//		print(key)
		
		AppDelegate.sharedInstance().cacheAction(key, callback: { (response) in
//			print(response)
			var results: [Item] = [];
			
			if let message = response["message"] {
				
			}else{
				for item in response as! Array<[String: AnyObject]>
				{
					if(item["type"] as! String == "tree")
					{
						let directory = DirectoryItem(data: item)
						directory.path = path
						directory.repository = self
						results.append(directory)
					}else{
						let file = FileItem(data: item)
						file.path = path
						file.repository = self
						results.append(file)
					}
				}

			}
			
			
			callback(response: results)

			
		}) { (key, successCallback) in
			API.request("/projects/" + self.id + "/repository/tree", data: params) { (response) in
				AppDelegate.sharedInstance().setCache(key, value: response)
				
				successCallback(response: response)
				
			}
		}
		
		
		
		
		
	}
	
	
	func createFile(_ name: String = "", content: String = "   ",  callback:(_ response: AnyObject) -> Void) {
		if(name.isEmpty || content.isEmpty){ return; }
		API.request(
			"/projects/" + self.id + "/repository/files",
			data: [
				"file_path": name,
				"branch_name": "master",
				"content": content,
				"commit_message": "Created file: " + name,
				"ref": "master"
			],
			method: .POST,
			callback: callback
		)
	}
	
	
}
