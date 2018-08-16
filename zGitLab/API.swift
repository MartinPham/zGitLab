//
//  API.swift
//  zGitLab
//
//  Created by MartinPham on 4/9/16.
//  Copyright © 2016 martinpham. All rights reserved.
//

import Foundation
import Alamofire
import PKHUD

class API {
	
	
	static func request(
			_ url: String,
			data: [String: AnyObject] = [:],
			method: Alamofire.Method = Alamofire.Method.GET,
			callback: @escaping (_ response: AnyObject) -> Void
		)
	{
		HUD.show(.Progress)
		UIApplication.sharedApplication().networkActivityIndicatorVis∑ible = true
		
		let url = Config.apiEndPoint + url
		
		var data: [String: AnyObject] = data;
		data["private_token"] = Config.privateToken as AnyObject?
		
//		print(url, data)
		
		Alamofire.request(method, url, parameters: data)
			.responseJSON { response in
				HUD.hide({ (complete) in
					
				})
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
				
//				print(url, data, response.result.value)
				
//				print(response.request)  // original URL request
//				print(response.response) // URL response
//				print(response.data)     // server data
//				print(response.result)   // result of response serialization
//				
//				if let JSON = response.result.value {
//					print("JSON: \(JSON)")
//				}
				
				
				callback(response: response.result.value! as AnyObject)
		}
	}
}
