//
//  Date+ISO8601.swift
//  netfox_ios
//
//  Created by Nagy Ádám on 2018. 09. 18..
//  Copyright © 2018. kasketis. All rights reserved.
//

import Foundation

/// constants
let iso_timezone_utc_format: String = "Z"
let iso_timezone_offset_format: String = "%+03ld:%02ld"

extension Date {
    var ISO8601Representation: String {
        let formatter = DateFormatter()
        let timeZone = TimeZone.current
        let offset = timeZone.secondsFromGMT() / 60 // bring down to minutes

        var strFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        if offset == 0 {
            strFormat += iso_timezone_utc_format
        } else {
            strFormat += String(format: iso_timezone_offset_format, (offset/60), (offset%60))
        }

        formatter.timeStyle = .full
        formatter.dateFormat = strFormat

        return formatter.string(from: self)
    }
}
