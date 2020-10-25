import Foundation

class sweetnote: NSObject {
    
    private(set) var noteId        : UUID
    private(set) var noteTitle     : String
    private(set) var noteText      : NSAttributedString
    private(set) var noteCreated   : Int64
    private(set) var noteModified  : Int64
    private(set) var noteCategory  : String
    
    init(noteTitle:String, noteText:NSAttributedString, noteCreated:Int64, noteModified:Int64, noteCategory:String) {
        self.noteId        = UUID()
        self.noteTitle     = noteTitle
        self.noteText      = noteText
        self.noteCreated   = noteCreated
        self.noteModified  = noteModified
        self.noteCategory  = noteCategory
    }

    init(noteId: UUID, noteTitle:String, noteText:NSAttributedString, noteCreated:Int64, noteModified:Int64, noteCategory:String) {
        self.noteId        = noteId
        self.noteTitle     = noteTitle
        self.noteText      = noteText
        self.noteCreated   = noteCreated
        self.noteModified  = noteModified
        self.noteCategory  = noteCategory
    }

}
