import UIKit

class sweetnoteCreateChangeViewController : UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var noteTitleTextField: UITextField!
    @IBOutlet weak var noteTextTextView: UITextView!
    @IBOutlet weak var noteDoneButton: UIButton!
    @IBOutlet weak var noteDateLabel: UILabel!
    @IBOutlet weak var noteCategoryTextField: UITextField!
    @IBOutlet weak var noteCategoryPicker: UIPickerView!
    
    private let noteCreationTimeStamp : Int64 = Date().toMinutes()
    private let noteModifiedTimeStamp : Int64 = Date().toMinutes()
    private(set) var changingsweetnote : sweetnote?
    
    // Create list for category dropdown
    var categoryList = ["Education", "Ideas", "Information", "Inspiration", "Lifestyle", "Lists", "Personal", "Recipes", "Reminders", "Other"]
    
    // Category picker view functions
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return categoryList.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.view.endEditing(true)
        return categoryList[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.noteCategoryTextField.text = self.categoryList[row]
        self.noteCategoryPicker.isHidden = true
    }

    @IBAction func noteCategoryDidBeginEditing(_ sender: UITextField) {
        self.noteCategoryPicker.isHidden = false
        self.noteCategoryPicker.layer.cornerRadius = 2
        self.noteCategoryPicker.layer.backgroundColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 0.8).cgColor
        
    }
    
    // Note title changed function
    @IBAction func noteTitleChanged(_ sender: UITextField, forEvent event: UIEvent) {
        if self.changingsweetnote != nil {
            // Change mode enabled
            noteDoneButton.isEnabled = true
        } else {
            // Create mode enabled
            if ( sender.text?.isEmpty ?? true ) || ( noteTextTextView.text?.isEmpty ?? true ) {
                noteDoneButton.isEnabled = false
            } else {
                noteDoneButton.isEnabled = true
            }
        }
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton, forEvent event: UIEvent) {
        // Distinguish between create and change
        if self.changingsweetnote != nil {
            // Change mode; change the item
            changeItem()
        } else {
            // Create mode; create the item
            addItem()
        }
    }
    
    // Change/add functions
    func setChangingsweetnote(changingsweetnote : sweetnote) {
        self.changingsweetnote = changingsweetnote
    }
    
    private func addItem() -> Void {
        let note = sweetnote(
            noteTitle:     noteTitleTextField.text!,
            noteText:      noteTextTextView.attributedText,
            noteCreated:   noteCreationTimeStamp,
            noteModified:  noteCreationTimeStamp,
            noteCategory:  noteCategoryTextField.text!)

        sweetnoteStorage.storage.addNote(noteToBeAdded: note)
        
        performSegue(
            withIdentifier: "backToMasterView",
            sender: self)
    }

    private func changeItem() -> Void {
        // Retrieve changed note instance
        if let changingsweetnote = self.changingsweetnote {
            // Change the note through note storage
            sweetnoteStorage.storage.changeNote(
                noteToBeChanged: sweetnote(
                    noteId:        changingsweetnote.noteId,
                    noteTitle:     noteTitleTextField.text!,
                    noteText:      noteTextTextView.attributedText,
                    noteCreated:   noteCreationTimeStamp,
                    noteModified:  noteModifiedTimeStamp,
                    noteCategory:  noteCategoryTextField.text!)
            )
            // Navigate back to list of notes
            performSegue(
                withIdentifier: "backToMasterView",
                sender: self)
        } else {
            // Create alert
            let alert = UIAlertController(
                title: "Unexpected error",
                message: "Cannot change the note, unexpected error occurred. Try again later.",
                preferredStyle: .alert)
            
            // Add OK action
            alert.addAction(UIAlertAction(title: "OK", style: .default ) { (_) in self.performSegue(withIdentifier: "backToMasterView", sender: self)})
            // show alert
            self.present(alert, animated: true)
        }
    }
    
    // Hide keyboard on tap functions
    func setupHideKeyboardOnTap() {
        self.view.addGestureRecognizer(self.endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }
    
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
    
    // Keyboard did show and keyboard did hide functions based on keyboard size in userInfo notification
    @objc func keyboardDidShow(notification: NSNotification) {
        // Set the keyboard size variable
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
               // If keyboard size is not available for some reason, dont do anything
               return
            }
          
          let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height - 55 , right: 0.0)
          noteTextTextView.contentInset = contentInsets
          noteTextTextView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardDidHide(notification: NSNotification) {
        // Move the root view origin back to 0
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -55.0, right: 0.0)
            
        // Reset the content inset back to zero after keyboard is gone
        noteTextTextView.contentInset = contentInsets
        noteTextTextView.scrollIndicatorInsets = contentInsets
    }
    
    // Create the toolbar functions/variables
    var accessoryDoneButton: UIBarButtonItem!
    var accessoryCameraButton: UIBarButtonItem!
    let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let accessoryToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
    
    @objc func didPressToolbarDone() {
        // Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @objc func didPressToolbarCamera() {
        //let cameraVc = UIImagePickerController()
        //cameraVc.sourceType = UIImagePickerController.SourceType.camera
        //self.present(cameraVc, animated: true, completion: nil)
        self.showAlert()
    }
    
     //Show alert to selected the media source type.
        private func showAlert() {

            let alert = UIAlertController(title: "Image Selection", message: "Where would you like to select the image from?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
                self.getImage(fromSourceType: .camera)
            }))
            alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: {(action: UIAlertAction) in
                self.getImage(fromSourceType: .photoLibrary)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

        //get image from source type
        private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {

            //Check is source type available
            if UIImagePickerController.isSourceTypeAvailable(sourceType) {

                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = sourceType
                self.present(imagePickerController, animated: false, completion: nil)
            }
        }

        //MARK:- UIImagePickerViewDelegate.
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            self.dismiss(animated: true) { [weak self] in
                
                guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
                
                let attachment = NSTextAttachment()
                attachment.image = image
                // Calculate new size
                let newImageWidth = (self!.noteTextTextView.bounds.size.width - 20)
                let scale = newImageWidth/image.size.width
                let newImageHeight = image.size.height * scale
                // Resize image function
                func resizeimage(image:UIImage,withSize:CGSize) -> UIImage {
                    var actualHeight:CGFloat = image.size.height
                    var actualWidth:CGFloat = image.size.width
                    let maxHeight:CGFloat = withSize.height
                    let maxWidth:CGFloat = withSize.width
                    var imgRatio:CGFloat = actualWidth/actualHeight
                    let maxRatio:CGFloat = maxWidth/maxHeight
                    let compressionQuality = 0.5
                    if (actualHeight>maxHeight||actualWidth>maxWidth) {
                        if (imgRatio<maxRatio){
                            //adjust width according to maxHeight
                            imgRatio = maxHeight/actualHeight
                            actualWidth = imgRatio * actualWidth
                            actualHeight = maxHeight
                        }else if(imgRatio>maxRatio){
                            // adjust height according to maxWidth
                            imgRatio = maxWidth/actualWidth
                            actualHeight = imgRatio * actualHeight
                            actualWidth = maxWidth
                        }else{
                            actualHeight = maxHeight
                            actualWidth = maxWidth
                        }
                    }
                    let rec:CGRect = CGRect(x:0.0,y:0.0,width:actualWidth,height:actualHeight)
                    UIGraphicsBeginImageContext(rec.size)
                    image.draw(in: rec)
                    let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
                    let imageData = image.jpegData(compressionQuality: CGFloat(compressionQuality))
                    UIGraphicsEndImageContext()
                    let resizedimage = UIImage(data: imageData!)
                    return resizedimage!
                }
                // Resize the attachment image
                attachment.image = resizeimage(image: attachment.image!, withSize: CGSize(width:newImageWidth, height: newImageHeight))
                //attachment.bounds = CGRect.init(x:0, y:0, width: newImageWidth, height: newImageHeight)
                // Insert attachment into attributed string
                let currentAtStr = NSMutableAttributedString(attributedString: self!.noteTextTextView.attributedText)
                let attachmentAtStr = NSAttributedString(attachment: attachment)
                if let selectedRange = self!.noteTextTextView.selectedTextRange {
                    let cursorIndex = self!.noteTextTextView.offset(from: self!.noteTextTextView.beginningOfDocument, to: selectedRange.start)
                    currentAtStr.insert(attachmentAtStr, at: cursorIndex)
                    
                    currentAtStr.addAttributes(self!.noteTextTextView.typingAttributes, range: NSRange(location: cursorIndex, length:1))
                } else {
                    currentAtStr.append(attachmentAtStr)
                }
                // Setting image into note text view attributed text
                self!.noteTextTextView.attributedText = currentAtStr
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set text view delegate so that we can react on text change
        noteTextTextView.delegate = self
        noteTextTextView.font = UIFont(name: "Verdana", size: 14.0)
        
        // Set the note text view placeholder text
        //noteTextTextView.placeholder = "Enter text here"

        // Initialize text view UI - border width, radius and color
        noteTextTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        noteTextTextView.layer.borderWidth = 1.0
        noteTextTextView.layer.cornerRadius = 5
        
        // Hide the keyboard on tap or swipe
        self.setupHideKeyboardOnTap()
        
        // Hide the category dropdown picker by default
        self.noteCategoryPicker.isHidden = true
        
        // Style the note done button with rounded corners
        noteDoneButton.layer.cornerRadius = 5
        
        // Set the toolbar within the note text view
        self.accessoryDoneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.didPressToolbarDone))
        self.accessoryCameraButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.camera, target: self, action: #selector(self.didPressToolbarCamera))
        self.accessoryToolBar.items = [self.accessoryCameraButton, self.flexBarButton, self.accessoryDoneButton]
        self.noteTextTextView.inputAccessoryView = self.accessoryToolBar
        
        // Register the view controller with the default notification center to receive keyboardwillshow or keyboardwill hide updates
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardDidShow(notification:)),name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardDidHide(notification:)),name: UIResponder.keyboardDidHideNotification, object: nil)
        
        // Check if we are in create mode or in change mode
        if let changingsweetnote = self.changingsweetnote {
            // In change mode: initialize for fields with data coming from note to be changed
            noteDateLabel.text = sweetnoteDateHelper.convertDate(date: Date.init(minutes: noteCreationTimeStamp))
            noteTextTextView.attributedText = changingsweetnote.noteText
            noteTitleTextField.text = changingsweetnote.noteTitle
            noteCategoryTextField.text = changingsweetnote.noteCategory
            // Enable done button by default
            noteDoneButton.isEnabled = true
            noteDoneButton.layer.borderWidth = 2
            noteDoneButton.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            // In create mode: set creation time stamp label
            noteDateLabel.text = sweetnoteDateHelper.convertDate(date: Date.init(minutes: noteCreationTimeStamp))
        }
        
        // For back button in navigation bar, change text
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Handle the text changes here
    func textViewDidChange(_ textView: UITextView) {
        if self.changingsweetnote != nil {
            // Change mode
            noteDoneButton.isEnabled = true
        } else {
            // Create mode
            if ( noteTitleTextField.text?.isEmpty ?? true ) || ( noteCategoryTextField.text?.isEmpty ?? true ) || ( textView.text?.isEmpty ?? true ) {
                noteDoneButton.isEnabled = false
            } else {
                // Enable and style note done button
                noteDoneButton.isEnabled = true
                noteDoneButton.layer.borderWidth = 2
                noteDoneButton.layer.borderColor = UIColor.systemBlue.cgColor
            }
        }
    }

}
