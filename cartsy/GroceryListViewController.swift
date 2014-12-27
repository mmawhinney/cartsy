//
//  GroceryListViewController.swift
//  cartsy
//
//  Created by Matheson Mawhinny and Alex Popov on 2014-12-15.
//  Copyright (c) 2014 numbits. All rights reserved.
//

import UIKit
import CoreData

class GroceryListViewController: CartsyViewController {
    
    // +++++++++++++++++++++++++++++++++
    // |    MARK: IBOutlets/Actions    |
    // +++++++++++++++++++++++++++++++++
	
    /// TableView of Items on the selected Grocery List
    @IBOutlet weak var groceryListTable: UITableView!
    
    /// Action to Add a new Item object to Core Data
    ///
    /// :returns: nothing. Presents a New Item dialogue
    @IBAction func addNewItem(sender: AnyObject) {
        addNewPressed(object: "item", inTable: groceryListTable, savedAs: saveItem)
    }
    
    
    // +++++++++++++++++++++++++++
    // |    MARK: Our Objects    |
    // +++++++++++++++++++++++++++
    
    /// Array of Items to populate tableView
    var tableData = [Item]()
    var superList: List?
    
    
    // +++++++++++++++++++++++++++++++++++++
    // |    MARK: Boiletplate Overrides    |
    // +++++++++++++++++++++++++++++++++++++
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableData = self.fetchItems()!
        mainList = self.fetchLists(self.managedObjectContext!, mainList: true)![0]
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
	
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .Default, reuseIdentifier:  "ItemCell")
        let item = tableData[indexPath.row]
        cell.textLabel!.text = item.valueForKey("name") as String?
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("Did select row at index path \(indexPath)") // TODO: make tapping an item do something
        // one thing to do here, would be to for example slide it off, 
        // but leave it blank. Kind of like how reminds in the reminders app don't go away
        // until you close the app. So you can still revert your choice
        // if we do swiping, for example, going to other list can draw it blue (like Mailbox)
        // and removing it can make it red. Just throwing out some ideas
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // this enabled swiping, because why the fuck not.
    }
    
    // this is the editing actions, adds a More button. I don't know how to write code for them though.
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler:{action, indexpath in
            self.deleteObject(self.tableData, atIndexPath: indexPath)
            self.tableData = self.fetchItems()!
            self.groceryListTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
        });
        var moveRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Move", handler:{action, indexpath in
            self.moveItem(indexPath)
        });
    
        moveRowAction.backgroundColor = UIColor.blueColor()
        
        return [deleteRowAction, moveRowAction];
    }
    
	
    // +++++++++++++++++++++++++++++++++++++
    // |    MARK: Homerolled Functions     |
    // +++++++++++++++++++++++++++++++++++++
    
    
    /// grabs Items to populate TableView from Context
    ///
    /// :returns: Void. fills tableData, used to populate tableView
    func fetchItems() -> [Item]?{                                                     /// TODO: make this return an array of Items that will be asigned to tableData. I don't like methods with side-effects
        var fetchRequest = NSFetchRequest(entityName: "Item") // grab all
        println("\(superList!.name) has items: \(superList!.toItems)")
        fetchRequest.predicate = NSPredicate(format: "toList = %@", superList!)
        var error : NSError?
        let fetchedResults = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Item]
        
        if let results = fetchedResults {
            return results
        } else {
            println("Could not fetch: \(error)")
            return nil // TODO: instead of crashing, make this error our elegantly
        }
    }
    
    /// moves an Item to the Fridge. Only works from shopping lists
    func moveItem(indexPath: NSIndexPath) { // TODO: does not work from Fridge! We'll need a picker of some kind when moving from the fridge
        let item = tableData[indexPath.row]
        println("Moving item from \(item.toList.name)")
        item.toList = mainList!
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.saveContext()
        tableData = self.fetchItems()! // TODO: figure out why swapping this line and the next one crashes the app on move.
        groceryListTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    /// saves an Item into the Context
    ///
    /// :returns: Void. CoreData will save Item in PersistentStore
    func saveItem(name: String) -> Void {
        var error : NSError?
        let item = NSEntityDescription.insertNewObjectForEntityForName("Item", inManagedObjectContext: managedObjectContext!) as Item
        item.name = name
        superList!.addItem(item)        // TODO: maybe remove this Side-Effect
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
    
}
