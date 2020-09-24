import UIKit
import CoreData

class MasterViewController: UITableViewController, UISearchBarDelegate {
        
    var detailViewController: DetailViewController? = nil
    
    // Search results controller
    //let resultSearchController = UISearchController(searchResultsController: nil)
    //var allSweetnotes = [sweetnote]()
    //var filteredSweetnotes: [sweetnote]? = nil

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
        
        // Create the context from the app delegate container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Set context in the storage
        sweetnoteStorage.storage.setManagedContext(managedObjectContext: managedContext)
        
        
        // Set the search controller programmatically
        //resultSearchController.searchResultsUpdater = self
        //resultSearchController.hidesNavigationBarDuringPresentation = false
        //resultSearchController.obscuresBackgroundDuringPresentation = false
        //self.definesPresentationContext = true
        //tableView.tableHeaderView = resultSearchController.searchBar
        //resultSearchController.searchBar.tintColor = UIColor.darkGray
        //resultSearchController.searchBar.barTintColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.8)
        //resultSearchController.searchBar.placeholder = "Search sweetnotes"

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

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    // Dismiss the search bar when scrolling away
    //override func viewWillDisappear(_ animated: Bool) {
        //super.viewWillDisappear(animated)
        //resultSearchController.dismiss(animated: false, completion: nil)
    //}

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
            }
        }
    }

    // MARK: - Table View
    
    //func updateSearchResults(for searchController: UISearchController) {
    //    filteredSweetnotes = allSweetnotes
    //}
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return objects.count
        //if  resultSearchController.isActive && resultSearchController.searchBar.text != "" {
        //    return filteredSweetnotes!.count
        //} else {
            return sweetnoteStorage.storage.count()
        //}
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! sweetnoteUITableViewCell

        if let object = sweetnoteStorage.storage.readNote(at: indexPath.row) {
            cell.noteTitleLabel!.text = object.noteTitle
            cell.noteTextLabel!.attributedText = object.noteText
            cell.noteCategoryLabel!.text = object.noteCategory
            cell.noteDateLabel!.text = sweetnoteDateHelper.convertDate(date: Date.init(minutes: object.noteModified))
        }
        
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable
        return true
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
}
