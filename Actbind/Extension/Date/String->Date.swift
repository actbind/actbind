//
//  String->Date.swift
//  Actbind
//
//  Created by 柿本海斗 on 2021/03/24.
//

import Foundation

extension String {
    func stringToDate(format: String) -> Date {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = format
        formatter.locale = NSLocale.system
        
        return formatter.date(from: self)!
    }
}
