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


class MetaListViewController: CartsyViewController {
    
    // +++++++++++++++++++++++++++++++++
    // |    MARK: IBOutlets/Actions    |
    // +++++++++++++++++++++++++++++++++
    
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
    
    
    // +++++++++++++++++++++++++++
    // |    MARK: Our Objects    |
    // +++++++++++++++++++++++++++
    
    /// Array of Lists to populate tableView
    var groceryLists = [List]()

    
    // +++++++++++++++++++++++++++++++++++++
    // |    MARK: Boiletplate Overrides    |
    // +++++++++++++++++++++++++++++++++++++
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        self.fetchLists()
        groceryLists = fetchLists(self.managedObjectContext!)!
        if (groceryLists.isEmpty) {
            self.generateDefaults()
        }
        self.mainList = self.fetchLists(self.managedObjectContext!, mainList: true)![0]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Cartsy"
        self.setupListTable()
    }
    
    // +++++++++++++++++++++++++++++++++++++++++++++
    // |    MARK: Table View Delegate Functions    |
    // +++++++++++++++++++++++++++++++++++++++++++++
    
    override func tableView(tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        if numberOfRowsInSection == 0 { // numberOfRowsInSection specifies WHICH section we're in
            return 1
        } else {
            return groceryLists.count
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2 // hardcoded for now
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .Default, reuseIdentifier: "ListCell")
        cell.accessoryType = .DisclosureIndicator
        
        if (indexPath.section == 0) {   // if we're in the first section show mainList
            var rowData = mainList!
            cell.textLabel!.text = rowData.name
            cell.textLabel!.font = UIFont.boldSystemFontOfSize(16) // TODO: make this follow system sizes instead (for blind people using auto-sized text)
        } else {                        // otherwise show the other sublists
            var rowData = groceryLists[indexPath.row]
            cell.textLabel!.text = rowData.name
        }
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // this enabled swiping, because why the fuck not.
        self.deleteObject(groceryLists, atIndexPath: indexPath)
        self.fetchLists(self.managedObjectContext!, mainList: false)
    }
    
    /// Navigates to subList selected
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("Did select row \(indexPath.row) in section \(indexPath.section)")
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let groceryList = self.storyboard!.instantiateViewControllerWithIdentifier("MainList")! as GroceryListViewController
        if indexPath.section == 0 {
            groceryList.superList = mainList 
        } else {
            groceryList.superList = groceryLists[indexPath.row] // TODO: Make a generalized ItemViewController and subclass it for MainList and Sublists
        }
        groceryList.mainList = mainList
        self.navigationController?.pushViewController(groceryList, animated: true)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if (indexPath.section == 0 || groceryLists.count == 1) {
            return false
        }
        return true
    }
    
    // this is the editing actions, adds a More button. I don't know how to write code for them though.
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler:{action, indexpath in
            self.deleteObject(self.groceryLists, atIndexPath: indexPath)
            self.groceryLists = self.fetchLists(self.managedObjectContext!, mainList: false)!
            self.metaListTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        });
        
        return [deleteRowAction];
    }
    
    
    // +++++++++++++++++++++++++++++++++++++++++++++
    // |    MARK: Picker View Delegate Function    |
    // +++++++++++++++++++++++++++++++++++++++++++++
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return groceryLists.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return groceryLists[row].name
    }
    
    
    // +++++++++++++++++++++++++++++++++++++
    // |    MARK: Homerolled Functions     |
    // +++++++++++++++++++++++++++++++++++++
    
    /// Generate our two base lists and link them
    func generateDefaults() -> Void {
        let groceryList = NSEntityDescription.insertNewObjectForEntityForName("List", inManagedObjectContext: self.managedObjectContext!) as List
        groceryList.name = "Groceries"
        let fridgeList = NSEntityDescription.insertNewObjectForEntityForName("List", inManagedObjectContext: self.managedObjectContext!) as List
        var error : NSError?
        fridgeList.name = "Fridge"
        fridgeList.toConjugalList = groceryList
        fridgeList.isParent = true
        mainList = fridgeList
        println("Grocery list conjugal is: \(groceryList.toConjugalList.name) and")
        println("Fridge list conjugal is \(fridgeList.toConjugalList.name)")
        if !managedObjectContext!.save(&error) {
            println("Could not Save!")
        } else {
            groceryLists.append(groceryList)
        }
    }
    
    /// erase all data in stores
    func resetAllData() -> Void {
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
        
        self.groceryLists.removeAll(keepCapacity: false)
        self.generateDefaults()
        self.metaListTable.reloadData()
    }
    
    /// saves a List in Context
    ///
    /// :returns: Void. CoreData will save List in PersistentStore
    func saveList(name: String) -> Void {
        var error: NSError?
        let list = NSEntityDescription.insertNewObjectForEntityForName("List", inManagedObjectContext: self.managedObjectContext!) as List
        list.name = name
        println("List name: \(list.name)")
        list.toConjugalList = mainList!        // list.toConjugalList = list              /// TODO: ask, in a dialog, what list to join with
                                                /// TODO: Decide if we want to be able to join to only one list, or to many
        println("Twin list: \(list.toConjugalList.name)")
        
        if !managedObjectContext!.save(&error) {
            println("Could not save! \(error)")
        } else {
            groceryLists.append(list)
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