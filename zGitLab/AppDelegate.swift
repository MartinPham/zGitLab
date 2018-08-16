//
//  AppDelegate.swift
//  zGitLab
//
//  Created by MartinPham on 4/9/16.
//  Copyright © 2016 martinpham. All rights reserved.
//

import UIKit
import AwesomeCache

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

	var window: UIWindow?
	
	var mainViewController: MainViewController?
	var masterViewController: UINavigationController?
	var detailViewController: UINavigationController?
	
	var appCache: Cache<NSData>?
	

	static func sharedInstance() -> AppDelegate {
		return UIApplication.shared.delegate as! AppDelegate
	}
	
	
	func removeCache(_ key: String) {
		self.appCache![key] = nil
	}
	func setCache(_ key: String, value: AnyObject) {
		do {
			let jsonData = try JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions.prettyPrinted)
			
			self.appCache?.setObject(jsonData, forKey: key, expires: CacheExpiry.Never)
			
		} catch let error as NSError {
			print(error)
		}
		
		
	}
	
	func getCache(_ key: String) -> AnyObject {
		if let cache = self.appCache![key] {
			do {
				let jsonObject = try JSONSerialization.JSONObjectWithData(cache, options: [])
				
				return jsonObject
			} catch let error as NSError {
				print(error)
			}
		}
		
		return NSNull()
	}

	func cacheAction(
		_ key: String,
		callback: (_ response: AnyObject) -> Void,
		failCallback: (_ key: String, _ successCallback: (_ response: AnyObject) -> Void) -> Void
	)
	{
		let response = AppDelegate.sharedInstance().getCache(key)
		if response as! NSObject != NSNull() {
			callback(response)
		}else{
			failCallback(key, callback)
		}
	}
	
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		
		do {
			self.appCache = try Cache<Data>(name: "app")
		} catch _ {
			
		}
		
		
		// Override point for customization after application launch.
		self.mainViewController = self.window!.rootViewController as? MainViewController
		self.masterViewController = self.mainViewController!.viewControllers[0] as? UINavigationController
		self.detailViewController = self.mainViewController!.viewControllers[self.mainViewController!.viewControllers.count-1] as? UINavigationController
		
		self.detailViewController!.topViewController!.navigationItem.leftBarButtonItem = self.mainViewController!.displayModeButtonItem
		self.mainViewController!.preferredDisplayMode = UISplitViewControllerDisplayMode.primaryOverlay

		self.mainViewController!.delegate = self
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	// MARK: - Split view

	func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
//	    guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
//	    guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
//	    if topAsDetailController.detailItem == nil {
//	        // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
//	        return true
//	    }
//	    return false
		return true
	}

}

