//
//  MainViewController.swift
//  zGitLab
//
//  Created by MartinPham on 4/9/16.
//  Copyright © 2016 martinpham. All rights reserved.
//

import UIKit

class MainViewController : UISplitViewController {
	var files:[FileItem] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
//		Repository.find { (response) in
//			for r in response as! [Repository] {
//				print("[*] " + r.id + " " +  r.name)
//				
//				r.browse("/", callback: { (response2) in
//					for r2 in response2 as! [Item] {
//						print((r2.type == .DIRECTORY ? "[+]" : " - ") + r2.name)
//						if(r2.type == .DIRECTORY)
//						{
//							(r2 as! DirectoryItem).browse(callback: { (response3) in
//								for r3 in response3 as! [Item] {
//									print((r3.type == .DIRECTORY ? "[+]" : " - ") + r3.name)
//								}
//							})
//						}
//					}
//				})
//				
//				break
//			}
//		}
	}
}
