//
//  Date++.swift
//  Memo
//
//  Created by Aye Chan on 3/4/23.
//

import Foundation

extension Date {
    func formatDate() -> String {
        let calendar = Calendar.current
        let now = Date()
        if calendar.isDate(self, equalTo: now, toGranularity: .minute) || self > now.addingTimeInterval(-3600) {
            return "Now"
        } else {
            if calendar.isDateInYesterday(self) {
                return "Yesterday"
            } else if calendar.isDate(self, equalTo: now, toGranularity: .day) {
                return "Today"
            } else {
                let formatter = DateFormatter()
                formatter.locale = Locale.current
                formatter.dateFormat = "MMM dd, yyyy"
                return formatter.string(from: self)
            }
        }
    }

}
