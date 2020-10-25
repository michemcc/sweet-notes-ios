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
    
    /*override var frame: CGRect {
            get {
                return super.frame
            }
            set {
                let inset: CGFloat = 15
                var frame = newValue
                frame.origin.x += inset
                frame.size.width -= 2 * inset
                super.frame = frame
            }
        }*/
    
}
