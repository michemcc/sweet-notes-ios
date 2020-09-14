import Foundation

class sweetnoteDateHelper {
    
    static func convertDate(date: Date) -> String {
        //let dateFormatter = DateFormatter()
        // Set initial date format based on server string
        //dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // Convert the date to a string
        //let myString = dateFormatter.string(from: date)
        // Convert the string to a date
        //let yourDate = dateFormatter.date(from: myString)
        // Convert the date format to the desired output
        //dateFormatter.dateFormat = "dd-MMM-yyyy H:mm aa"
        //dateFormatter.dateFormat = "EEEE"
        // Convert your date to string
        //let myStringafd = dateFormatter.string(from: yourDate!)
        //return myStringafd
        
        // Set up relative formatter
        let relDateFormatter = DateFormatter()
        relDateFormatter.doesRelativeDateFormatting = true
        relDateFormatter.dateStyle = .long
        relDateFormatter.timeStyle = .medium
        
        // Set up absolute formatter
        let absDateFormatter = DateFormatter()
        absDateFormatter.dateStyle = .long
        absDateFormatter.timeStyle = .medium

        // Get the result of both formatters
        let rel = relDateFormatter.string(from: date)
        let abs = absDateFormatter.string(from: date)
        
        // If the results are the same then it isn't a relative date.
        // Use your custom formatter. If different, return the relative result.
        if (rel == abs) {
            let fullDateFormatter = DateFormatter()
            fullDateFormatter.setLocalizedDateFormatFromTemplate("dd-MMM-yyyy H:mm aa")
            return fullDateFormatter.string(from: date)
        } else {
            return rel
        }
    }
    

}

extension Date {
    func toMinutes() -> Int64! {
        return Int64((self.timeIntervalSince1970).rounded())
    }
    
    init(minutes:Int64!) {
        self = Date(timeIntervalSince1970: TimeInterval(Double.init(minutes)))
    }
}
