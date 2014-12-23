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


class MetaListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: IBOutlets/Actions
    
    /// TableView of Grocery Lists
    @IBOutlet weak var metaListTable: UITableView!
    
    /// Action to Add a new List object to Core Data
    ///
    /// :returns: nothing. Presents a New List dialogue
    @IBAction func addNewList(sender: AnyObject) {
        addNewPressed(object: "list", inTable: metaListTable, savedAs: saveList)
    }
    
    /// Resets all lists and items
    @IBAction func resetData(sender: AnyObject) { // TODO: at the end call a regenerator to return app to default state: Grocery List and Fridge List
        var alert = UIAlertController(title: "Reset All Data", message: "This will remove all lists and items.\n Are you sure?", preferredStyle: .Alert)
        let acceptAction = UIAlertAction(title: "Delete!", style: .Default) {(action: UIAlertAction!) -> Void in
            self.resetAllData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) {(action: UIAlertAction!) -> Void in } // do nothing
        
        alert.addAction(cancelAction)
        alert.addAction(acceptAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let persistentStoreCoordinator = appDelegate.persistentStoreCoordinator {
            return persistentStoreCoordinator
        } else {
            return nil
        }
    }()
    
    
    
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
        println("Made it!")
        self.fetchLists()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Cartsy"
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
        let groceryList = self.storyboard!.instantiateViewControllerWithIdentifier("MainList")! as GroceryListViewController
        groceryList.superList = tableData[indexPath.row]
        self.navigationController?.pushViewController(groceryList, animated: true)
    }
    
    // MARK: Picker View Delegate Function
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tableData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return tableData[row].name
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
    
    /// erase all data in stores
    func resetAllData() -> Void {
//         continue with removal
        let stores = persistentStoreCoordinator!.persistentStores as [NSPersistentStore]
        var removeStoreError : NSError?
        var removeItemError  : NSError?
        for store in stores { // this will remove all the sqlite stores
            persistentStoreCoordinator?.removePersistentStore(store, error: &removeStoreError)
            NSFileManager.defaultManager().removeItemAtPath(store.URL!.path!, error: &removeItemError)
            if removeItemError?.isEqual(nil) == true {
                println("Remove Item Error: \(removeItemError)")
            }
            if removeStoreError?.isEqual(nil) == true {
                println("Remove Store Error: \(removeStoreError)")
            }
        }
        // now we have to reinstantiate at least one so we don't crash
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.newPersistentStore()
        
        
        self.tableData.removeAll(keepCapacity: false)
        self.metaListTable.reloadData()
    }
    
    /// present a UIView Overlay to pick which list to be Conjugal
    func pickConjugal(list: List) -> Void {
        /// TODO: when we decide how we want to handle conjugates, fill this in
        }
    
    /// saves a List in Context
    ///
    /// :returns: Void. CoreData will save List in PersistentStore
    func saveList(name: String) -> Void {
        var error: NSError?
        let list = NSEntityDescription.insertNewObjectForEntityForName("List", inManagedObjectContext: self.managedObjectContext!) as List
        list.name = name
        println("List name: \(list.name)")
        self.pickConjugal(list)
        list.toConjugalList = list              /// TODO: ask, in a dialog, what list to join with
                                                /// TODO: Decide if we want to be able to join to only one list, or to many
        println("Twin list: \(list.toConjugalList.name)")
        if !managedObjectContext!.save(&error) {
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