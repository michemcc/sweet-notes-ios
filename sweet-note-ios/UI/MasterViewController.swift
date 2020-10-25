import UIKit
import Foundation
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    var detailViewController: DetailViewController? = nil
    var searchtemplate: String? {didSet {print (searchtemplate as Any)}}
    
    // Search results controller
    let resultSearchController = UISearchController(searchResultsController: nil)
    var sweetnotes: [sweetnote] = []
    var searchResults: [sweetnote] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Core data initialization
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            // Create alert controller
            let alert = UIAlertController(
                title: "Could note get app delegate",
                message: "Could note get app delegate, unexpected error occurred. Try again later.",
                preferredStyle: .alert)

            // Add OK action
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .default))
            // Show alert
            self.present(alert, animated: true)
            return
        }
        
        // Pass the context forward from the app delegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Set context in the storage
        sweetnoteStorage.storage.setManagedContext(managedObjectContext: managedContext)
        
        // Set the search controller programmatically
        resultSearchController.searchResultsUpdater = self
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.obscuresBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        // Scope bar
        //resultSearchController.searchBar.scopeButtonTitles = ["All", "Ideas", "Information", "Lifestyle", "Lists", "Recipes", "Other"]
        //searchView.addSubview(resultSearchController.searchBar)
        tableView.tableHeaderView = resultSearchController.searchBar
        resultSearchController.searchBar.tintColor = UIColor.darkGray
        resultSearchController.searchBar.barTintColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.8)
        resultSearchController.searchBar.placeholder = "Search sweetnotes"
        
        // Prefer large titles
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        // Edit-note button
        navigationItem.leftBarButtonItem = editButtonItem

        // Add-note button
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        self.tableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*let inset: CGFloat = 15
        
        self.tableView.frame.origin.x += inset
        self.tableView.frame.origin.y += 7 * inset
        //self.tableView.frame.size.height -= 14 * inset
        self.tableView.frame.size.width -= 2 * inset
        */
        self.tableView.layer.borderColor = tableView.separatorColor?.cgColor
        self.tableView.layer.borderWidth = 1.4
        self.tableView.layer.cornerRadius = 8.0
        
        
        //self.tableView.contentInset = UIEdgeInsets(top: 200, left: 0, bottom: 0, right: 0);
        //self.tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: -80).isActive = true
        
        // Set the search bar's frame
        //resultSearchController.searchBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50)

        // Constraint to pin the search bar to the top of the view
        //let topConstraint = NSLayoutConstraint(item: resultSearchController.searchBar, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 30)

        //self.view.addSubview(resultSearchController.searchBar)
        //self.view.addConstraint(topConstraint)
        
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    // Dismiss search bar on scroll-down
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resultSearchController.dismiss(animated: false, completion: nil)
    }

    @objc
    func insertNewObject(_ sender: Any) {
        performSegue(withIdentifier: "showCreateNoteSegue", sender: self)
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                //let object = objects[indexPath.row]
                let object = sweetnoteStorage.storage.readNote(at: indexPath.row)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                //controller.detailItem = resultSearchController.isActive ? searchResults[indexPath.row] : sweetnotes[indexPath.row]
            }
        }
    }
    
    // MARK: - Table View
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
            print(text)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        searchtemplate = searchText
        tableView.reloadData()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController, fromManagedObjectContext: NSManagedObjectContext) {
        let searchText = searchController.searchBar.text!
        let predicate = NSPredicate(format: "%K CONTAINS[c] %@", argumentArray: ["noteText", searchText])
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        fetchRequest.predicate = predicate
        
        do {
            let fetchedNotesFromCoreData = try fromManagedObjectContext.fetch(fetchRequest)
            fetchedNotesFromCoreData.forEach { (fetchRequestResult) in
                let noteManagedObjectRead = fetchRequestResult as! NSManagedObject
                searchResults.append(sweetnote.init(
                    noteId:        noteManagedObjectRead.value(forKey: "noteId")        as! UUID,
                    noteTitle:     noteManagedObjectRead.value(forKey: "noteTitle")     as! String,
                    noteText:      noteManagedObjectRead.value(forKey: "noteText")      as! NSAttributedString,
                    noteCreated:   noteManagedObjectRead.value(forKey: "noteCreated")   as! Int64,
                    noteModified:  noteManagedObjectRead.value(forKey: "noteModified")  as! Int64,
                    noteCategory:  noteManagedObjectRead.value(forKey: "noteCategory")
                        as! String))
            }
        } catch let error as NSError {
            // TODO error handling
            print("Could not read notes from core data. \(error), \(error.userInfo)")
        }
            tableView.reloadData()
    }
    
    /*func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        fetchedResultsController!.fetchRequest.predicate = nil
        do {
            try self.fetchedResultsController!.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        tableView.reloadData()
    }*/
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if resultSearchController.isActive && resultSearchController.searchBar.text != "" {
                return searchResults.count
            } else {
                return sweetnoteStorage.storage.count()
            }
        }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! sweetnoteUITableViewCell
        
        //let note = fetchedResultsController.object(at: indexPath)
            //configureCell(cell, withEvent: note)

        if let object = sweetnoteStorage.storage.readNote(at: indexPath.row) {
            cell.noteTitleLabel!.text = object.noteTitle
            cell.noteTextLabel!.attributedText = object.noteText
            cell.noteCategoryLabel!.text = object.noteCategory
            cell.noteDateLabel!.text = sweetnoteDateHelper.convertDate(date: Date.init(minutes: object.noteModified))
        }
        
        //cell.contentView.layer.cornerRadius = 6.0
        //cell.contentView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        //cell.contentView.layer.borderWidth = 1.0
        //cell.contentView.layer.masksToBounds = true
        //cell.contentView.clipsToBounds = true
        
        cell.backgroundColor = UIColor.white
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable
        if resultSearchController.isActive {
            return false
        } else {
            return true
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presentDeletionFailsafe(indexPath: indexPath)
            //objects.remove(at: indexPath.row)
            //sweetnoteStorage.storage.removeNote(at: indexPath.row)
            //tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    // Deletion failsafe function
    func presentDeletionFailsafe(indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: "Are you sure you would like to delete this note?", preferredStyle: .alert)

        // Delete the note
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            // replace data variable with your own data array
            sweetnoteStorage.storage.removeNote(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }

        alert.addAction(yesAction)

        // Cancel and don't delete note
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func configureCell(_ cell: sweetnoteUITableViewCell, withEvent note: Note) {
        cell.noteTitleLabel!.text = note.noteTitle
        cell.noteTextLabel!.attributedText = note.noteText
        cell.noteCategoryLabel!.text = note.noteCategory
        cell.noteDateLabel!.text = sweetnoteDateHelper.convertDate(date: Date.init(minutes: note.noteModified))
    }
    
}
