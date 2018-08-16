//
//  Item.swift
//  zGitLab
//
//  Created by MartinPham on 4/9/16.
//  Copyright © 2016 martinpham. All rights reserved.
//

import Foundation

public enum Type: String {
	case FILE, DIRECTORY
}

class Item {
	var id: String = ""
	var name: String = ""
	var path: String = ""
	var type: Type = .FILE
	var repository: Repository = Repository()
	
	
	init (data: [String: AnyObject] = [:]) {
		if(!data.isEmpty){
			self.id = data["id"] as! String
			self.name = data["name"] as! String
			//		self.path = String(data["path"]!)
			//		self.repository = data["repository"] as! Repository
		}
		
	}
	
	
}