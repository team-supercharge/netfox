//
//  GTMNSDictionary+URLArguments.swift
//  netfox_ios
//
//  Created by Nagy Ádám on 2018. 09. 18..
//  Copyright © 2018. kasketis. All rights reserved.
//

import Foundation

extension Dictionary where Key == String, Value == String {
    static func gtm_dictionaryWithHttpArguments(with argString: String) -> [String: Any] {
        var ret: [String: Any] = [:]
        let components = argString.components(separatedBy: "&")

        for component in components.reversed() {
            guard component.lengthOfBytes(using: .utf16) > 0 else {
                continue
            }

            let pos = component.index(of: "=")
            var key: String = ""
            var val: String = ""

            if let _pos = pos {
                key = String(component[..<_pos])
                val = String(component[_pos...])
            } else {
                key = component.gtm_stringByEscapingForURLArgument
                val = ""
            }

            ret[key] = val
        }

        return ret
    }

    var gtm_httpArgumentsString: String {
        let _arguments = self.map { element in
            return String(format: "%@=%@",
                          element.key.gtm_stringByEscapingForURLArgument,
                          self[element.key]?.description.gtm_stringByEscapingForURLArgument ?? "")
        }

        return _arguments.joined(separator: "&")
    }
}
