//
//  TimeFormatter.swift
//  Powermon
//
//  Created by vshandil on 07/01/25.
//

import Foundation

class TimeFormatter {
    private var lastProcessedDate: Date?

    func formatTime(timestamp: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = isoFormatter.date(from: timestamp) else {
            return "Invalid Date" // Handle parsing failure
        }

        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()

        // Formatters for date and time
        dateFormatter.dateFormat = "dd MMM"
        timeFormatter.dateFormat = "hh:mm a"

        var formattedString = ""

        // Add date only if it's a new day compared to the last processed date
        if lastProcessedDate == nil || !Calendar.current.isDate(date, inSameDayAs: lastProcessedDate!) {
            formattedString += dateFormatter.string(from: date) + " " // Add date prefix
        }

        formattedString += timeFormatter.string(from: date) // Add time
        lastProcessedDate = date // Update the last processed date

        return formattedString
    }
}
