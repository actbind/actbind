//
//  Date->String.swift
//  Actbind
//
//  Created by 柿本海斗 on 2021/03/24.
//

import Foundation

extension Date {
    func dateToString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = format
        formatter.locale = NSLocale.system
        
        return formatter.string(from: self)
    }
    
    func dateToStringTemplate(format: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: format, options: 0, locale: .current)
        formatter.locale = NSLocale.system
        
        return formatter.string(from: self)
    }
}
