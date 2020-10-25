import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var noteTitleLabel: UILabel!
    @IBOutlet weak var noteTextTextView: UITextView!
    @IBOutlet weak var noteDate: UILabel!
    @IBOutlet weak var noteCategory: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let topicLabel = noteTitleLabel,
               let dateLabel = noteDate,
               let categoryLabel = noteCategory,
               let textView = noteTextTextView {
                topicLabel.text = detail.noteTitle
                categoryLabel.text = detail.noteCategory
                dateLabel.text = "Created " + sweetnoteDateHelper.convertDate(date: Date.init(minutes: detail.noteCreated)) + "  |  Last modified " + sweetnoteDateHelper.convertDate(date: Date.init(minutes: detail.noteModified))
                textView.attributedText = detail.noteText
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        
        // Style the edit button with a border
        editButton.layer.cornerRadius = 5
        editButton.layer.borderWidth = 2
        editButton.layer.borderColor = UIColor.systemBlue.cgColor
        
        // Do not adjust title font size
        //noteTitleLabel.adjustsFontSizeToFitWidth = false
        
        // Do not display large title in the detail view
        self.navigationController?.navigationItem.largeTitleDisplayMode = .never
    }

    var detailItem: sweetnote? {
        didSet {
            // Update the view
            configureView()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChangeNoteSegue" {
            let changeNoteViewController = segue.destination as! sweetnoteCreateChangeViewController
            if let detail = detailItem {
                changeNoteViewController.setChangingsweetnote(
                    changingsweetnote: detail)
            }
        }
    }
}

