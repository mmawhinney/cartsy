# TODONE

## V0.1.0

* added TableViews
* hard-coded one sub list for all parent lists
* included Core Data by making a new project and scrapping everything
* stole code from Ray Wenderlich

## V0.1.1

* allowed deletion of items
* made a reset button to erase all content
* introduced a nasty bug where adding a list after a reset caused a crash
* implemented relationships between items and lists
* stopped hard-coding what list to go to
* items now appear only in appropriate sublist

## V0.1.2

* No longer allow empty Lists/Items, or ones that include trailing/leading white spaces
* wrote convenience NSString extension to perform the above sanitization
* Made relationship between lists and their conjugates possible
* Generalized addButton with a UIViewController extension and Swift magic

## V0.1.3

* Fixed Predicate
* Implemented Functionality to Move Items to Fridge list

## V0.2.0

* Refactored code
* Removed UIViewController extension
* Made proper CartsyViewController to subclass both views from separately
* MainList has its own ViewController now
* Generalized DeleteObject method
* Re-logicked some function with side-effects
* Created List Deletion
* Allowed cascading Item Deletion
* Disallowed removing Fridge and one other List

## V0.2.1

* added user-feedback when input is invalid (blank)
* nested GroceryList TableView in a View so we don't have ugly black on shake