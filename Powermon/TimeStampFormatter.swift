//
//  TimeStampFormatter.swift
//  Powermon
//
//  Created by vshandil on 08/10/22.
//

import Foundation

class TimestampFormatter {
    let timestamp: String
    let format: String
    
    init(timestamp: String, format: String) {
        self.timestamp = timestamp
        self.format = format
    }
    
    func getFormattedLabel() -> String { // make sure str is not null or empty
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // tells the formatter that the timestamp is in utc
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm:ss a" // this is the input format
        if dateFormatter.date(from: timestamp) != nil {
            let dt = dateFormatter.date(from: timestamp)
            dateFormatter.timeZone = NSTimeZone.local
            //dateFormatter.dateFormat = "dd-MM-yyyy hh:mm a" // output date format in local timezone
            dateFormatter.dateFormat = format
            return dateFormatter.string(from: dt!)
        }
        else {
            return ""
        }
    }
}
