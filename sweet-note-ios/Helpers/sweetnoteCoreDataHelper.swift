import Foundation
import CoreData

class sweetnoteCoreDataHelper {
    
    private(set) static var count: Int = 0
    
    static func createNoteInCoreData(
        noteToBeCreated:          sweetnote,
        intoManagedObjectContext: NSManagedObjectContext) {
        
        // Create a note entity and new note record
        let noteEntity = NSEntityDescription.entity(
            forEntityName: "Note",
            in:            intoManagedObjectContext)!
        
        let newNoteToBeCreated = NSManagedObject(
            entity:     noteEntity,
            insertInto: intoManagedObjectContext)

        newNoteToBeCreated.setValue(
            noteToBeCreated.noteId,
            forKey: "noteId")
        
        newNoteToBeCreated.setValue(
            noteToBeCreated.noteTitle,
            forKey: "noteTitle")
        
        newNoteToBeCreated.setValue(
            noteToBeCreated.noteText,
            forKey: "noteText")
        
        newNoteToBeCreated.setValue(
            noteToBeCreated.noteCreated,
            forKey: "noteCreated")
        
        newNoteToBeCreated.setValue(
            noteToBeCreated.noteModified,
            forKey: "noteModified")
        
        newNoteToBeCreated.setValue(
            noteToBeCreated.noteCategory,
            forKey: "noteCategory")
        
        do {
            try intoManagedObjectContext.save()
            count += 1
        } catch let error as NSError {
            // TODO error handling
            print("Could not save object. \(error), \(error.userInfo)")
        }
    }
    
    static func changeNoteInCoreData(
        noteToBeChanged:        sweetnote,
        inManagedObjectContext: NSManagedObjectContext) {
        
        // Read managed object
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        let noteIdPredicate = NSPredicate(format: "noteId = %@", noteToBeChanged.noteId as CVarArg)
        
        fetchRequest.predicate = noteIdPredicate
        
        do {
            let fetchedNotesFromCoreData = try inManagedObjectContext.fetch(fetchRequest)
            let noteManagedObjectToBeChanged = fetchedNotesFromCoreData[0] as! NSManagedObject
            
            // Perform the changes
            noteManagedObjectToBeChanged.setValue(
                noteToBeChanged.noteTitle,
                forKey: "noteTitle")

            noteManagedObjectToBeChanged.setValue(
                noteToBeChanged.noteText,
                forKey: "noteText")
            
            noteManagedObjectToBeChanged.setValue(
                noteToBeChanged.noteModified,
                forKey: "noteModified")
            
            noteManagedObjectToBeChanged.setValue(
                noteToBeChanged.noteCategory,
                forKey: "noteCategory")

            // Save object
            try inManagedObjectContext.save()

        } catch let error as NSError {
            // TODO error handling
            print("Could not update object. \(error), \(error.userInfo)")
        }
    }
    
    static func readNotesFromCoreData(fromManagedObjectContext: NSManagedObjectContext) -> [sweetnote] {

        var returnedNotes = [sweetnote]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        fetchRequest.predicate = nil
        
        do {
            let fetchedNotesFromCoreData = try fromManagedObjectContext.fetch(fetchRequest)
            fetchedNotesFromCoreData.forEach { (fetchRequestResult) in
                let noteManagedObjectRead = fetchRequestResult as! NSManagedObject
                returnedNotes.append(sweetnote.init(
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
        
        // Set note count
        self.count = returnedNotes.count
        
        // Sort by modified date
        return returnedNotes.sorted() {
            $0.noteModified > $1.noteModified
        }
    }
    
    static func readNoteFromCoreData(
        noteIdToBeRead:           UUID,
        fromManagedObjectContext: NSManagedObjectContext) -> sweetnote? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        let noteIdPredicate = NSPredicate(format: "noteId = %@", noteIdToBeRead as CVarArg)
        
        fetchRequest.predicate = noteIdPredicate
        
        do {
            let fetchedNotesFromCoreData = try fromManagedObjectContext.fetch(fetchRequest)
            let noteManagedObjectToBeRead = fetchedNotesFromCoreData[0] as! NSManagedObject
            return sweetnote.init(
                noteId:        noteManagedObjectToBeRead.value(forKey: "noteId")        as! UUID,
                noteTitle:     noteManagedObjectToBeRead.value(forKey: "noteTitle")     as! String,
                noteText:      noteManagedObjectToBeRead.value(forKey: "noteText")      as! NSAttributedString,
                noteCreated:   noteManagedObjectToBeRead.value(forKey: "noteCreated")   as! Int64,
                noteModified:  noteManagedObjectToBeRead.value(forKey: "noteModified")  as! Int64,
                noteCategory:  noteManagedObjectToBeRead.value(forKey: "noteCategory") as! String
            )
        } catch let error as NSError {
            // TODO error handling
            print("Could not read note from core data. \(error), \(error.userInfo)")
            return nil
        }
    }

    static func deleteNoteFromCoreData(
        noteIdToBeDeleted:        UUID,
        fromManagedObjectContext: NSManagedObjectContext) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        let noteIdAsCVarArg: CVarArg = noteIdToBeDeleted as CVarArg
        let noteIdPredicate = NSPredicate(format: "noteId == %@", noteIdAsCVarArg)
        
        fetchRequest.predicate = noteIdPredicate
        
        do {
            let fetchedNotesFromCoreData = try fromManagedObjectContext.fetch(fetchRequest)
            let noteManagedObjectToBeDeleted = fetchedNotesFromCoreData[0] as! NSManagedObject
            fromManagedObjectContext.delete(noteManagedObjectToBeDeleted)
            
            do {
                try fromManagedObjectContext.save()
                self.count -= 1
            } catch let error as NSError {
                // TODO error handling
                print("Could not save. \(error), \(error.userInfo)")
            }
        } catch let error as NSError {
            // TODO error handling
            print("Could not delete. \(error), \(error.userInfo)")
        }
        
    }

}

