//
//  GroceryListViewController.swift
//  cartsy
//
//  Created by Matheson Mawhinny and Alex Popov on 2014-12-15.
//  Copyright (c) 2014 numbits. All rights reserved.
//

import UIKit
import CoreData

class GroceryListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // +++++++++++++++++++++++++++++++++
    // |    MARK: IBOutlets/Actions    |
    // +++++++++++++++++++++++++++++++++
	
    /// TableView of Items on the selected Grocery List
    @IBOutlet weak var groceryListTable: UITableView!
    
    /// Action to Add a new Item object to Core Data
    ///
    /// :returns: nothing. Presents a New Item dialogue
    @IBAction func addNewItem(sender: AnyObject) {
//        // UIAlertController will be displaying the alert
//        var alert = UIAlertController(title: "Add", message: "Add new item", preferredStyle: .Alert)
//        // actions are the active components of the alert
//        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action: UIAlertAction!) -> Void in
//            let textField = alert.textFields![0] as UITextField
//            let itemName = textField.text.stringByTrimmingWhitespace()
//    
//            if !itemName.isEmpty == false{
//                self.saveItem(itemName)
//                self.groceryListTable.reloadData()
//            } else {
//                /// TODO: tell user they can't save bullshit
//            }
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action: UIAlertAction!) -> Void in }
//        
//        // present alert
//        alert.addTextFieldWithConfigurationHandler( {
//            (textField: UITextField!) -> Void in } )
//        alert.addAction(cancelAction)
//        alert.addAction(saveAction)
//        presentViewController(alert, animated: true, completion: nil)
        addNewPressed(object: "item", inTable: groceryListTable, savedAs: saveItem)
    }
    
    
    // +++++++++++++++++++++++++++
    // |    MARK: Our Objects    |
    // +++++++++++++++++++++++++++
    
    /// Array of Items to populate tableView
    var tableData = [Item]()
    
    var superList: List?
    
    /// our interface to CoreData; who you Fetch from and Save to.
    /// This class's entrypoint to The Context.
    lazy var managedObjectContext: NSManagedObjectContext? =  {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        } else {
            return nil
        }
    }()
    
    // +++++++++++++++++++++++++++++++++++++
    // |    MARK: Boiletplate Overrides    |
    // +++++++++++++++++++++++++++++++++++++
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchItems()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = superList!.name
        self.setupItemTable()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // +++++++++++++++++++++++++++++++++++++++++++++
    // |    MARK: Table View Delegate Functions    |
    // +++++++++++++++++++++++++++++++++++++++++++++
	
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .Default, reuseIdentifier:  "ItemCell")
        let item = tableData[indexPath.row]
        cell.textLabel!.text = item.valueForKey("name") as String?
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("Did select row at index path \(indexPath)") // TODO: make tapping an item do something
        // one thing to do here, would be to for example slide it off, 
        // but leave it blank. Kind of like how reminds in the reminders app don't go away
        // until you close the app. So you can still revert your choice
        // if we do swiping, for example, going to other list can draw it blue (like Mailbox)
        // and removing it can make it red. Just throwing out some ideas
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // this enabled swiping, because why the fuck not.
        if (editingStyle == .Delete) {
            self.deleteItem(indexPath)
        }
    }
    
    // this is the editing actions, adds a More button. I don't know how to write code for them though.
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler:{action, indexpath in
            self.deleteItem(indexPath)
        });
        
        return [deleteRowAction];
    }
    
	
    // +++++++++++++++++++++++++++++++++++++
    // |    MARK: Homerolled Functions     |
    // +++++++++++++++++++++++++++++++++++++
    
    /// deletes swiped item from the list.
    ///
    /// :returns: Void. Removes selected item from Core Data and reloads list.
    func deleteItem(indexPath: NSIndexPath) { // TODO: consider using MGSwipeTableCell to have Mailbox-style swipable thingies.
        var error : NSError?
        let item = tableData[indexPath.row]
        managedObjectContext?.deleteObject(item)
        if !managedObjectContext!.save(&error) {
            println("Could not save! \(error)")
        }
        self.fetchItems()
        groceryListTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
    }
    
    /// grabs Items to populate TableView from Context
    ///
    /// :returns: Void. fills tableData, used to populate tableView
    func fetchItems() {
        var fetchRequest = NSFetchRequest(entityName: "Item") // grab all
        fetchRequest.predicate = NSPredicate(format: "ANY toList = %@", superList!)  // TODO: find predicate to get all items of list
        var error : NSError?
        let fetchedResults = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Item]
        
        if let results = fetchedResults {
            tableData = results
        } else {
            println("Could not fetch: \(error)")
        }
    }

    /// saves an Item into the Context
    ///
    /// :returns: Void. CoreData will save Item in PersistentStore
    func saveItem(name: String) -> Void {
        var error : NSError?
        let item = NSEntityDescription.insertNewObjectForEntityForName("Item", inManagedObjectContext: managedObjectContext!) as Item
        item.name = name
        superList!.addItem(item)
        println("List toItem \(superList!.toItems)")
        if !managedObjectContext!.save(&error) {
            println("Could not save! \(error)")
        } else {
            tableData.append(item)
        }
    }
    
    /// sets delegate and dataSource for tableView
    func setupItemTable() {
        // Do any additional setup after loading the view.
        groceryListTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "ItemCell") // what does this do? // TODO: do we need this?
        groceryListTable.delegate = self
        groceryListTable.dataSource = self
        groceryListTable.reloadData() // needed? // TODO: Do we need this?
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
