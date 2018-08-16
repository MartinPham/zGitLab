//
//  MasterViewController.swift
//  zGitLab
//
//  Created by MartinPham on 4/9/16.
//  Copyright © 2016 martinpham. All rights reserved.
//

import UIKit

class TreeViewController: UITableViewController {

	var repository: Repository = Repository()
	var directory: DirectoryItem = DirectoryItem()
	var items = [Item]()
	
//	var detailViewController: FileViewController? = nil


	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
//		self.navigationItem.leftBarButtonItem = self.editButtonItem()

//		let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
//		self.navigationItem.rightBarButtonItem = addButton
//		if let split = self.splitViewController {
//		    let controllers = split.viewControllers
//		    self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
//		}
		self.refreshControl?.addTarget(self, action: #selector(RepositoryViewController.forceRefresh), for: UIControlEvents.valueChanged)

		
		refresh()
		
	}

//	override func viewWillAppear(animated: Bool) {
//		self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
//		super.viewWillAppear(animated)
//	}

	
	func forceRefresh()
	{
		if(self.directory.id.isEmpty)
		{
			AppDelegate.sharedInstance().removeCache(self.repository.id + "_/")
		}else{
			AppDelegate.sharedInstance().removeCache(self.directory.repository.id + "_" + self.directory.getPath())
		}
		
		
		Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(RepositoryViewController.refresh), userInfo: nil, repeats: false)
		
	}
	
	func refresh() -> Void {
		if(self.directory.id.isEmpty)
		{
			self.title = repository.fullname
			self.repository.browse("/", callback: { (response) in
				self.items = response as! [Item]
				
				self.tableView.reloadData()
				
				
				self.refreshControl?.endRefreshing()
			})
		}else{
			self.title = directory.name
			self.directory.browse { (response) in
				self.items = response as! [Item]
				
				self.tableView.reloadData()
				
				
				self.refreshControl?.endRefreshing()
			}
		}
	}
	
	// MARK: - Segues

	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//		print(identifier)
		return false
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if(segue.identifier == "open")
		{
			let controller = segue.destination as! TreeViewController
			controller.repository = self.repository
			controller.directory = sender as! DirectoryItem
		}else if(segue.identifier == "detail")
		{
			var exists = false
			for f:FileItem in (AppDelegate.sharedInstance().mainViewController?.files)! {
				if f.getURL() == (sender as! FileItem).getURL() {
					exists = true
				}
			}
			
			if(!exists)
			{
				AppDelegate.sharedInstance().mainViewController?.files.append(sender as! FileItem)
			}
			
			let navController = segue.destination as! UINavigationController
			let controller = navController.topViewController as! FileViewController
			controller.repository = self.repository
			controller.file = sender as! FileItem
			
			//			controller.refreshTab()
			
		}else if(segue.identifier == "cache")
		{
			let controller = segue.destination as! FileViewController
			controller.cache = sender!["content"] as! String
			controller.title = sender!["file_name"] as! String

			
			//			controller.refreshTab()
			
		}
		
	}
	// MARK: - Table View

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

		let item = self.items[(indexPath as NSIndexPath).row]
		
		cell.textLabel!.text = item.name
		
		if(item.type == .DIRECTORY)
		{
			cell.textLabel!.font = UIFont.boldSystemFont(ofSize: 16.0)
		}else{
			cell.textLabel!.font = UIFont.systemFont(ofSize: 16.0)
		}
		
		return cell
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		let item = items[(indexPath as NSIndexPath).row]
		if item.type == .FILE {
			return true
		}
		return false
	}
	
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		
		let delete = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
			let item = self.items[indexPath.row] as! FileItem
			item.delete({ (response) in
				self.items.remove(at: indexPath.row)
				tableView.deleteRows(at: [indexPath], with: .fade)
				
				if(self.directory.id.isEmpty)
				{
					AppDelegate.sharedInstance().removeCache(self.repository.id + "_/")
				}else{
					AppDelegate.sharedInstance().removeCache(self.directory.repository.id + "_" + self.directory.getPath())
				}
			})
			
		})
		delete.backgroundColor = UIColor.red
		
		let duplicate = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Duplicate" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
			
			let item = self.items[indexPath.row] as! FileItem
			
			item.read { (response) in
				//			print(response)
				let decodedData = Data(base64Encoded: response["content"] as! NSString as String, options:NSData.Base64DecodingOptions(rawValue: 0))
				let content = NSString(data: decodedData!, encoding: String.Encoding.utf8.rawValue) as! String
				
				
				let alertController = UIAlertController(title: "Duplicate file", message: "", preferredStyle: .alert)
				
				
				let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
					let nameTextField = alertController.textFields![0] as UITextField
					
					if(self.directory.id.isEmpty)
					{
						self.repository.createFile(nameTextField.text!, content: content, callback: { (response) in
							self.forceRefresh()
							
						})
					}else{
						self.directory.createFile(nameTextField.text!, content: content, callback: { (response) in
							self.forceRefresh()
						})
					}
					
				}
				
				let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
				
				alertController.addTextField { (textField) in
					textField.placeholder = "File name"
					textField.text = item.name
				}
				
				
				alertController.addAction(okAction)
				alertController.addAction(cancelAction)
				
				self.present(alertController, animated: true) {
					
				}
			}
			
			
			
		})
		duplicate.backgroundColor = UIColor.blue
		
		let cache = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Cache" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
			
			let item = self.items[indexPath.row] as! FileItem
			
			
			let content = AppDelegate.sharedInstance().getCache(item.repository.id + "_" + item.getPath())
			
			if content as! NSObject != NSNull()
			{
				self.performSegue(withIdentifier: "cache", sender: content)
			}
			
		})
		cache.backgroundColor = UIColor.black

		
		return [delete, duplicate, cache]
	}

//	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//		if editingStyle == .Delete {
//			let item = items[indexPath.row] as! FileItem
//			item.delete({ (response) in
//				self.items.removeAtIndex(indexPath.row)
//				tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//			})
//			
//		} else if editingStyle == .Insert {
//		    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//		}
//	}
//
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		let cell  = tableView.cellForRowAtIndexPath(indexPath)
		let item = items[(indexPath as NSIndexPath).row]
		
		if(item.type == .DIRECTORY) {
			self.performSegue(withIdentifier: "open", sender: item)
		}else{
			self.performSegue(withIdentifier: "detail", sender: item)
		}
		
	}

	@IBAction func addButton_selector(_ sender: AnyObject) {
		let alertController = UIAlertController(title: "New file", message: "", preferredStyle: .alert)

		
		let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
			let nameTextField = alertController.textFields![0] as UITextField
			
			if(self.directory.id.isEmpty)
			{
				self.repository.createFile(nameTextField.text!, content: ".", callback: { (response) in
					self.forceRefresh()
					
				})
			}else{
				self.directory.createFile(nameTextField.text!, content: ".", callback: { (response) in
					self.forceRefresh()
				})
			}
			
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
		
		alertController.addTextField { (textField) in
			textField.placeholder = "File name"
			
		}
		
		
		alertController.addAction(okAction)
		alertController.addAction(cancelAction)
		
		self.present(alertController, animated: true) {
			
		}
	}
	
	@IBAction func openButton_selector(_ sender: AnyObject) {
		if(self.directory.id.isEmpty)
		{
			UIApplication.shared.openURL(URL(string: self.repository.url)!)
		}else{
			UIApplication.shared.openURL(URL(string: directory.getURL())!)
		}
		
		
	}

	@IBAction func refreshButton_selector(_ sender: AnyObject) {
		refresh()
	}
}

