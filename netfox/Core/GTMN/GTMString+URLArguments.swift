//
//  GTMString+URLArguments.swift
//  netfox_ios
//
//  Created by Nagy Ádám on 2018. 09. 18..
//  Copyright © 2018. kasketis. All rights reserved.
//

import Foundation

extension String {
    var gtm_stringByEscapingForURLArgument: String {
        // Encode all the reserved characters, per RFC 3986
        // (<http://www.ietf.org/rfc/rfc3986.txt>)
        return addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]")) ?? ""
    }

    var gtm_stringByUnescapingFromURLArgument: String {
        return self.replacingOccurrences(of: "+", with: " ").removingPercentEncoding!
    }
}
