//
//  RepositoryViewController.swift
//  zGitLab
//
//  Created by MartinPham on 4/9/16.
//  Copyright © 2016 martinpham. All rights reserved.
//

import UIKit
import Foundation

class RepositoryViewController : UITableViewController
{
	var repositories = [Repository]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.refreshControl?.addTarget(self, action: #selector(RepositoryViewController.forceRefresh), for: UIControlEvents.valueChanged)

		
		refresh()
	}
	
	func forceRefresh()
	{
		AppDelegate.sharedInstance().removeCache(Config.ck_repositories)
		
		Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(RepositoryViewController.refresh), userInfo: nil, repeats: false)

	}
	
	func refresh()
	{
		
		Repository.find(["per_page": 100]) { (response) in
			self.repositories = response as! [Repository]
			self.tableView.reloadData()
			
			self.refreshControl?.endRefreshing()
		}
	}
	
	// MARK: - Segues
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let repo = repositories[((self.tableView.indexPathForSelectedRow as NSIndexPath?)?.row)!]
		
		if(segue.identifier == "browse")
		{
			let controller = segue.destination as! TreeViewController;
			controller.repository = repo;
		}
	}
	
	// MARK: - Table View
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.repositories.count
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		
		let repo = repositories[(indexPath as NSIndexPath).row]
		cell.textLabel!.text = repo.fullname
		cell.textLabel!.font = UIFont.boldSystemFont(ofSize: 16.0)
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
	}
	

}
