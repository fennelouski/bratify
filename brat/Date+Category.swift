//
//  Date+Category.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/13/24.
//

import Foundation

enum DateCategoryRelativeToNow: Int, Codable, Equatable, Hashable, CaseIterable {
    case lastHour
    case today
    case yesterday
    case last7Days
    case last30Days
    case olderThan30Days
    
    var name: String {
        switch self {
        case .lastHour:
            return NSLocalizedString("LastHour", comment: "Label for events within the last hour")
        case .today:
            return NSLocalizedString("Today", comment: "Label for events today")
        case .yesterday:
            return NSLocalizedString("Yesterday", comment: "Label for events yesterday")
        case .last7Days:
            return NSLocalizedString("Last7Days", comment: "Label for events within the last 7 days")
        case .last30Days:
            return NSLocalizedString("Last30Days", comment: "Label for events within the last 30 days")
        case .olderThan30Days:
            return NSLocalizedString("OlderThan30Days", comment: "Label for events older than 30 days")
        }
    }
}

extension Date {
    func categoryRelativeToToday() -> DateCategoryRelativeToNow {
        let calendar = Calendar.current
        let now = Date()
        let hourAgo = calendar.date(
            byAdding: .hour,
            value: -1,
            to: now
        )!
        let startOfToday = calendar.startOfDay(for: now)
        let startOfYesterday = calendar.startOfDay(
            for: calendar.date(
                byAdding: .day,
                value: -1,
                to: now
            )!
        )
        let sevenDaysAgo = calendar.date(
            byAdding: .day,
            value: -7,
            to: now
        )!
        let thirtyDaysAgo = calendar.date(
            byAdding: .day,
            value: -30,
            to: now
        )!

        if self >= hourAgo {
            return .lastHour
        } else if self >= startOfToday {
            return .today
        } else if self >= startOfYesterday {
            return .yesterday
        } else if self >= sevenDaysAgo {
            return .last7Days
        } else if self >= thirtyDaysAgo {
            return .last30Days
        } else {
            return .olderThan30Days
        }
    }
}
