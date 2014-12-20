//
//  MetaListsViewController.swift
//  cartsy
//
//  Created by Matheson Mawhinney and Alex Popov on 2014-12-13.
//  Copyright (c) 2014 numbits. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class MetaListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: IBOutlets/Actions
    
    /// TableView of Grocery Lists
    @IBOutlet weak var metaListTable: UITableView!
    
    /// Action to Add a new List object to Core Data
    ///
    /// :returns: nothing. Presents a New List dialogue
    @IBAction func addNewList(sender: AnyObject) { // TODO: don't allow empty lists to be added
        // UIAlertController will be displaying the alert.
        var alert = UIAlertController(title: "Add", message: "Add new list", preferredStyle: .Alert)
        // actions are the active components of the alert presented by the UIAlertController
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action: UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField // make UITextField in alert
            self.saveList(textField.text)                       // TODO: Don't allow someone to save empty List
            self.metaListTable.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action: UIAlertAction!) -> Void in } // do nothing
        // present alert
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) -> Void in })
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // MARK: Our Objects
    /// Array of Lists to populate tableView
    var tableData = [List]()
    
    /// Our interface to the Core Data; who you Fetch from and Save to.
    /// This class's entrypoint to The Context.
    lazy var managedObjectContext: NSManagedObjectContext? =  {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate     // select our app delegate
        if let managedObjectContext = appDelegate.managedObjectContext {                // this was created in AppDelegate as part of CoreData boilerplate
            return managedObjectContext
        } else {
            return nil
        }
    }()
    
    
    // MARK: Boiletplate Overrides
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchLists()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupListTable()
    }
    
    // MARK: Table View Delegate Functions
    
    func tableView(tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        return tableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .Default, reuseIdentifier: "ListCell")
        cell.accessoryType = .DisclosureIndicator
        var rowData = tableData[indexPath.row]
        cell.textLabel!.text = rowData.valueForKey("name") as String?
        return cell
    }
    
    /// Navigates to subList selected
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("Did select row at index path \(indexPath)")            
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let groceryList = self.storyboard!.instantiateViewControllerWithIdentifier("MainList")! as GroceryListViewController // TODO: don't hardcode what list to go to.
        self.navigationController?.pushViewController(groceryList, animated: true)
    }
    
    // MARK: Homerolled Functions
    
    /// grabs Lists to populate Table from Context
    ///
    /// :returns: Void. fills tableData, used to populate tableView
    func fetchLists() -> Void {
        let fetchRequest = NSFetchRequest(entityName: "List") // want all lists
        var error: NSError?
        let fetchedResults = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [List] // fetch Lists from Context
        
        if let results = fetchedResults {
            tableData = results
        } else {
            println("Could not fetch: \(error)")
        }
    }
    
    /// saves a List in Context
    ///
    /// :returns: Void. CoreData will save List in PersistentStore
    func saveList(name: String) -> Void {
        let managedContext = self.managedObjectContext!
        var error: NSError?
        let list = NSEntityDescription.insertNewObjectForEntityForName("List", inManagedObjectContext: managedContext) as List
        list.name = name
        
        if !managedContext.save(&error) {
            println("Could not save! \(error)")
        } else {
            tableData.append(list)
        }
    }
    
    /// sets delegate and dataSource for tableView
    func setupListTable() {
        // setup our tableView
        metaListTable.delegate = self
        metaListTable.dataSource = self
        metaListTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "ListCell") // TODO: Do we need this? What does it do? ¯\_(ツ)_/¯
    }
    
}