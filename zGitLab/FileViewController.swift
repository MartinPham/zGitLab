//
//  DetailViewController.swift
//  zGitLab
//
//  Created by MartinPham on 4/9/16.
//  Copyright © 2016 martinpham. All rights reserved.
//

import UIKit
import WebKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class FileViewController: UIViewController, /*UITextViewDelegate,*/ UIWebViewDelegate, UIActionSheetDelegate {
	var repository: Repository = Repository()
	var file: FileItem = FileItem()
	var fileContent: String = ""
	var cache: String = ""
	var dirty: Bool = false
	
	var refreshControl:UIRefreshControl = UIRefreshControl()
	
	//	@IBOutlet weak var editorTextView: UITextView!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		//		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardShow), name: UIKeyboardWillShowNotification, object: nil)
		//		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardHide), name: UIKeyboardWillHideNotification, object: nil)
		
		
		if(!cache.isEmpty)
		{
			self.fileContent = cache
			let codemirror = Bundle.main.url(forResource: "codemirror/code", withExtension: "html");
			let myRequest = URLRequest(url: codemirror!);
			self.editorWebView.loadRequest(myRequest);
			
			self.editorWebView.isHidden = false
		}else{
			
			if(!file.id.isEmpty)
			{
				
				refresh()
				
				//			AppDelegate.sharedInstance().mainViewController?.performSelector("toggleMasterVisible:", withObject: nil)
			}else{
				self.title = ""
				self.navigationItem.rightBarButtonItems = []
				
				
			}
		}
		
		
		
		
		//		self.navigationItem.leftBarButtonItem = AppDelegate.sharedInstance().mainViewController!.displayModeButtonItem()
		//		self.navigationItem.leftBarButtonItem?.title = "Menu"
		
		
		//		AppDelegate.sharedInstance().mainViewController?.showViewController(AppDelegate.sharedInstance().masterViewController!, sender: self)
	}
	
	
	override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		
		
		//		self.editorTextView.contentInset = UIEdgeInsetsZero
		//		self.editorTextView.scrollIndicatorInsets = UIEdgeInsetsZero
		
		
		
		if(cache.isEmpty)
		{
			
			//		refreshControl.bounds = CGRectMake(0, 50, refreshControl.bounds.size.width, refreshControl.bounds.size.height) // Change position of refresh view
			refreshControl.addTarget(self, action: #selector(FileViewController.refresh), for: UIControlEvents.valueChanged)
			//		refreshController.attributedTitle = NSAttributedString(string: "Pull down to refresh...")
			self.editorWebView.scrollView.addSubview(refreshControl)
		}
	}
	override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		
		refreshTab()
	}
	@IBAction func closeButton_selector(_ sender: AnyObject) {
		if (self.cache.isEmpty)
		{
			self.checkDirty {
				
				AppDelegate.sharedInstance().mainViewController?.files.remove(at: self.tabSegmentedControl.selectedSegmentIndex)
				
				if(AppDelegate.sharedInstance().mainViewController?.files.count > 0)
				{
					self.file = (AppDelegate.sharedInstance().mainViewController?.files.first)!
					
					self.refresh()
					
				}else{
					self.file = FileItem()
					
					self.title = ""
					self.navigationItem.rightBarButtonItems = []
					
					//				self.editorTextView.text = ""
					self.editorWebView.isHidden = true
					
				}
				
				
				self.refreshTab()
			}
		}else{
			self.dismiss(animated: true, completion: {
				
			})
		}
		
		
	}
	@IBOutlet weak var editorWebView: UIWebView!
	@IBOutlet weak var openButton: UIBarButtonItem!
	//	@IBOutlet weak var editorWebView: WKWebView!
	@IBOutlet weak var tabToolbar: UIToolbar!
	@IBOutlet weak var tabSegmentedControl: UISegmentedControl!
	@IBAction func tabSegmentedControl_ValueChanged(_ sender: AnyObject) {
		//		print(tabSegmentedControl.selectedSegmentIndex)
		if (self.cache.isEmpty)
		{
			self.checkDirty {
				self.file = (AppDelegate.sharedInstance().mainViewController?.files[self.tabSegmentedControl.selectedSegmentIndex])!
				self.refresh()
			}
		}
	}
	func refreshTab()
	{
		if (self.cache.isEmpty)
		{
			self.tabSegmentedControl.frame.size.width = self.view.frame.size.width - 90
			
			
			self.tabToolbar.isHidden = (AppDelegate.sharedInstance().mainViewController?.files.count == 0)
			tabSegmentedControl.removeAllSegments()
			
			for f: FileItem in (AppDelegate.sharedInstance().mainViewController?.files)! {
				tabSegmentedControl.insertSegment(withTitle: f.name, at: tabSegmentedControl.numberOfSegments, animated: true)
				
				if f.getURL() == self.file.getURL() {
					tabSegmentedControl.selectedSegmentIndex = tabSegmentedControl.numberOfSegments - 1
				}
			}
			
		}else{
			self.tabToolbar.isHidden = false
			tabSegmentedControl.removeAllSegments()
			
			tabSegmentedControl.insertSegment(withTitle: self.title, at: tabSegmentedControl.numberOfSegments, animated: true)
			tabSegmentedControl.selectedSegmentIndex = tabSegmentedControl.numberOfSegments - 1
		}
		
		
	}
	
	func refresh()
	{
		
		self.refreshControl.endRefreshing()
		//		self.editorTextView.text = ""
		self.editorWebView.isHidden = true
		self.title = file.name
		
		file.read { (response) in
			//						print(response)
			do {
				//				let decodedData = NSData(base64EncodedString: response["content"] as! NSString as String, options:NSDataBase64DecodingOptions(rawValue: 0))
				//				let content = try NSString(data: decodedData!, encoding: NSUTF8StringEncoding) as! String
				
				
				//				self.editorTextView.attributedText = RPSyntaxHighlighter.highlightCode(content, withLanguage: "html")
				//
				//				self.editorTextView.selectedRange = NSRange()
				//
				//				self.editorTextView.editable = true
				
				self.fileContent = response["content"] as! String
				let codemirror = Bundle.main.url(forResource: "codemirror/code", withExtension: "html");
				let myRequest = URLRequest(url: codemirror!);
				self.editorWebView.loadRequest(myRequest);
				
				self.editorWebView.isHidden = false
				
				self.dirty = false
			} catch {
				//				self.editorTextView.text = "<BINARY>"
				//				self.editorTextView.editable = false
			}
			
		}
	}
	
	//	func textViewDidChange(textView: UITextView) {
	//		let selectedRange:NSRange = self.editorTextView.selectedRange;
	//		self.editorTextView.scrollEnabled = false;
	//
	//		self.editorTextView.attributedText = RPSyntaxHighlighter.highlightCode(textView.text, withLanguage: "html")
	//
	//		self.editorTextView.selectedRange = selectedRange;
	//		self.editorTextView.scrollEnabled = true;
	//
	//		self.dirty = true
	//	}
	
	func getFileContent() -> String {
		let decodedData = Data(base64Encoded: fileContent as NSString as String, options:NSData.Base64DecodingOptions(rawValue: 0))
		return NSString(data: decodedData!, encoding: String.Encoding.utf8.rawValue) as! String
		
		
	}
	
	func checkDirty(_ callback: @escaping () -> Void) {
		if !self.dirty {
			callback()
			return;
		}
		let alertController = UIAlertController(title: "Save file", message: "File has been modified. Do you want to save?", preferredStyle: .alert)
		
		
		let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
			self.file.update(self.getFileContent()) { (response) in
				self.dirty = false
				callback()
			}
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
			callback()
		}
		
		
		
		alertController.addAction(okAction)
		alertController.addAction(cancelAction)
		
		self.present(alertController, animated: true) {
			
		}
	}
	
	
	@IBAction func saveButton_selector(_ sender: AnyObject) {
		if(cache.isEmpty) {
			file.update(self.getFileContent()) { (response) in
				self.dirty = false
			}
		}else{
			self.dismiss(animated: true, completion: {
				
			})
		}
	}
	
	@IBAction func openButton_selector(_ sender: AnyObject) {
		//		print(file.getURL())
		//		UIApplication.sharedApplication().openURL(NSURL(string: file.getURL())!)
		
		let alertController = UIAlertController(title: "Editor", message: "", preferredStyle: .actionSheet)
		
		
		let searchAction = UIAlertAction(title: "Search", style: .default) { (_) in
			let jsCode = "editor.execCommand('findPersistent');";
			self.editorWebView.stringByEvaluatingJavaScript(from: jsCode)
		}
		
		let jumpLineAction = UIAlertAction(title: "Go to line", style: .default) { (_) in
			let jsCode = "editor.execCommand('jumpToLine');";
			self.editorWebView.stringByEvaluatingJavaScript(from: jsCode)
		}
		
		let openAction = UIAlertAction(title: "Open online file", style: .destructive) { (_) in
			if(self.cache.isEmpty)
			{
				UIApplication.shared.openURL(URL(string: self.file.getURL())!)
			}else{
				self.dismiss(animated: true, completion: {
					
				})
			}
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
		}
		
		
		
		alertController.addAction(searchAction)
		alertController.addAction(jumpLineAction)
		alertController.addAction(openAction)
		alertController.addAction(cancelAction)
		
		//		self.presentViewController(alertController, animated: true) {
		//
		//		}
		if let presenter = alertController.popoverPresentationController {
			presenter.barButtonItem = self.openButton
		}
		present(alertController, animated: true, completion: nil)
		
	}
	
	
	//	func keyboardShow(n:NSNotification) {
	//		let d = n.userInfo!
	//		var r = (d[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
	//		r = self.editorTextView.convertRect(r, fromView:nil)
	//		self.editorTextView.contentInset.bottom = r.size.height
	//		self.editorTextView.scrollIndicatorInsets.bottom = r.size.height
	//
	////		self.keyboardShowing = true
	//
	//
	//	}
	//
	//	func keyboardHide(n:NSNotification) {
	//		self.editorTextView.contentInset = UIEdgeInsetsZero
	//		self.editorTextView.scrollIndicatorInsets = UIEdgeInsetsZero
	//
	////		self.keyboardShowing = false
	//
	//	}
	
	
	func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
		//		print(request)
		
		if(request.url?.absoluteString == "code:loaded")
		{
			//			let jsCode = "initCode('" + self.fileContent.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())! + "')";
			let jsCode = "initCode('" + self.file.name + "', '" + self.fileContent + "')";
			
			//			print(jsCode)
			
			self.editorWebView.stringByEvaluatingJavaScript(from: jsCode)
			
			if(!cache.isEmpty)
			{
				self.editorWebView.stringByEvaluatingJavaScript(from: "editor.setOption('readOnly', true);")
				
				
				self.view.backgroundColor = UIColor.white
			}
			
			return false
		}else if(request.url?.absoluteString.range(of: "code:changed?") != nil)
		{
			if(cache.isEmpty)
			{
				fileContent = (request.url?.absoluteString as! NSString).substring(from: 13)
				//			print(self.getFileContent())
				self.dirty = true
			}
			
			
		}
		return true
	}
	
	func webViewDidStartLoad(_ webView: UIWebView) {
		//		print("webViewDidStartLoad")
	}
	
	func webViewDidFinishLoad(_ webView: UIWebView) {
		//		print("webViewDidFinishLoad")
		
		
	}
	
	func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
		//		print("webView didFailLoadWithError")
	}
}

