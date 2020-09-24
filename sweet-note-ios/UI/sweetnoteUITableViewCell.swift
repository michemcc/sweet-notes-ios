import UIKit

class sweetnoteUITableViewCell : UITableViewCell {
    private(set) var noteTitle : String = ""
    private(set) var noteText  : String = ""
    private(set) var noteDate  : String = ""
    private(set) var noteModified : String = ""
    private(set) var noteCategory : String = ""
 
    @IBOutlet weak var noteTitleLabel: UILabel!
    @IBOutlet weak var noteTextLabel: UILabel!
    @IBOutlet weak var noteDateLabel: UILabel!
    @IBOutlet weak var noteCategoryLabel: UILabel!
    
}
