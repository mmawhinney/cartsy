Cartsy
======
## What?
Cartsy is an app that allows quick management of what's in the fridge and what's on the shopping list. 
Sync with other members of the household, barcode scanning and ???

## TODO Short-term

### MetaList
* query db for list of lists
* populate TableView from that list
* have identifiers to track which list is related to which index
* didSelectRowAtIndex will give us that identifier back
* transition to MainList, populate TableView by querying database again and 
* perhaps have two hard-coded lists: GroceryList and FridgeList, maybe **just** start with these

## TODO #2 Long-term

### Skeleton
* allowing addition of cells
* make a second list, somewhere for now, between which you can bounce items
* turn on swipe-delete for an item
* implement saving

### Data Backend
* allow saving and retrieval
* eventually dropbox/iCloud sync

### Products Backend
* figure out a free product db and/or a barcode scanning db. 
* fast fuzzy-search and autocomplete 
 
