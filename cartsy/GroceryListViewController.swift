//
//  GroceryListViewController.swift
//  cartsy
//
//  Created by Matheson Mawhinny and Alex Popov on 2014-12-15.
//  Copyright (c) 2014 numbits. All rights reserved.
//

import UIKit
import CoreData

class GroceryListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate {
    
	// MARK: IBOutlets/Action
	
    /// TableView of Items on the selected Grocery List
    @IBOutlet weak var groceryListTable: UITableView!
    
    /// Action to Add a new Item object to Core Data
    ///
    /// :returns: nothing. Presents a New Item dialogue
    @IBAction func addNewItem(sender: AnyObject) {
        // UIAlertController will be displaying the alert
        var alert = UIAlertController(title: "Add", message: "Add new item", preferredStyle: .Alert)
        // actions are the active components of the alert
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action: UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.saveItem(textField.text)   // TODO: don't allow empty items to be added.
            self.groceryListTable.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action: UIAlertAction!) -> Void in }
        
        // present alert
        alert.addTextFieldWithConfigurationHandler( {
            (textField: UITextField!) -> Void in } )
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // MARK: Our Objects
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
    
    // MARK: Boilerplate Code
    
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
    
    
	// MARK: TableView Functions
	
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: MGSwipeTableCell = MGSwipeTableCell(style: .Default, reuseIdentifier:  "ItemCell")
        let item = tableData[indexPath.row]
        cell.textLabel!.text = item.valueForKey("name") as String?
//        //configure left buttons // TODO: try this out. Obj-C code needs to be translated
//        cell.leftButtons = @[[MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"check.png"] backgroundColor:[UIColor greenColor]],
//        [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"fav.png"] backgroundColor:[UIColor blueColor]]];
//        cell.leftSwipeSettings.transition = MGSwipeTransition3D;
        cell.leftButtons = [MGSwipeButton(title: "Push", backgroundColor: UIColor.blueColor())]
        cell.leftExpansion.buttonIndex = 0
        cell.leftSwipeSettings.transition = MGSwipeTransition.TransitionBorder
        cell.leftExpansion.fillOnTrigger = true
//        //configure right buttons
        cell.rightButtons = [MGSwipeButton(title: "Delete", backgroundColor: UIColor.redColor())]
        cell.rightExpansion.buttonIndex = 0
        cell.rightSwipeSettings.transition = MGSwipeTransition.TransitionBorder
        cell.rightExpansion.fillOnTrigger = true
//        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor redColor]],
//        [MGSwipeButton buttonWithTitle:@"More" backgroundColor:[UIColor lightGrayColor]]];
//        cell.rightSwipeSettings.transition = MGSwipeTransition3D;
        
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
    
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        // this enabled swiping, because why the fuck not.
//        if (editingStyle == .Delete) {
//            self.deleteItem(indexPath)
//        }
//    }
    
    // this is the editing actions, adds a More button.
//    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
//        
//        var moreRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "More", handler:{action, indexpath in
//            println("MORE•ACTION");
//        });
//        moreRowAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);
//        
//        var deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler:{action, indexpath in
//            self.deleteItem(indexPath)
//            println("DELETE•ACTION");
//        });
//        
//        return [deleteRowAction, moreRowAction];
//    }
    
    // MARK: MGSwipeTable Delegate
    
    /// Delegate method to enable/disable swipe gestures
    ///
    /// :returns: YES if swipe is allowed
    func swipeTableCell(cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
        return true
    }
    
    /// Delegate method invoked when the current swipe state changes
    ///
    /// :param: state the current Swipe State
    /// :param: gestureIsActive YES if the user swipe gesture is active. No if the uses has already ended the gesture
    func swipeTableCell(cell: MGSwipeTableCell!, didChangeSwipeState state: MGSwipeState, gestureIsActive: Bool) {
        // TODO: didChangeSwipeState
    }
    
    /// Called when the user clicks a swipe button or when a expandable button is automatically triggered
    /// :returns: YES to autohide the current swipe buttons
    func swipeTableCell(cell: MGSwipeTableCell!, tappedButtonAtIndex index: Int, direction:
        MGSwipeDirection, fromExpansion: Bool) -> Bool {
        if direction == MGSwipeDirection.RightToLeft {
            println("swiped Right to Left!")
            let indexPath = groceryListTable.indexPathForCell(cell)
            self.deleteItem(indexPath!)
        }
        println("swipped or tapped!")
        return true
    }
    /// * Delegate method to setup the swipe buttons and swipe/expansion settings
    /// * Buttons can be any kind of UIView but it's recommended to use the convenience MGSwipeButton class
    /// * Setting up buttons with this delegate instead of using cell properties improves memory usage because buttons are only created in demand
    ///
    /// :param: swipeTableCell the UITableViewCell to configure. You can get the indexPath using [tableView indexPathForCell:cell]
    /// :param: direction The swipe direction (left to right or right to left)
    /// :param: swipeSettings instance to configure the swipe transition and setting (optional)
    /// :param: expansionSettings instance to configure button expansions (optional)
    /// :returns: Buttons array
    func swipeTableCell(cell: MGSwipeTableCell!, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings!, expansionSettings: MGSwipeExpansionSettings!) -> [AnyObject]! {
        // nothing
        return nil
    }
    
	
	// MARK: Homerolled Functions
    
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
        println("List toItem \(superList?.toItems)")
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
