//
//  URLRequest+HAR.swift
//  netfox_ios
//
//  Created by Nagy Ádám on 2018. 09. 18..
//  Copyright © 2018. kasketis. All rights reserved.
//

import Foundation

public typealias HARType = [String: Any]

extension URLRequest {
    var HARRepresentation: HARType {
        var requestHAR: HARType = [
            HARConstants.HARMethod: httpMethod ?? "GET",
            HARConstants.HARURL: url?.absoluteURL.description ?? "missing url",
            HARConstants.HARHTTPVersion: "HTTP/1.1"
        ]

        var HARCookies: [HAR.HARCookie] = []
        if let url = url, let requestCookies = HTTPCookieStorage.shared.cookies(for: url), !DEBUG_TIMING {
            HARCookies = HAR.HARCookiesFromCookieArray(requestCookies)
        }
        requestHAR[HARConstants.HARCookies] = HARCookies

        HAR.addHARHeadersFromDictionary(headers: allHTTPHeaderFields ?? [:], toHAR: &requestHAR)

        // query string
        let requestQueryArguments = Dictionary<String, String>.gtm_dictionaryWithHttpArguments(with: url?.query ?? "")
        let HARQueryParameters = requestQueryArguments.map { element in
            return [HARConstants.HARName: element.key,
                    HARConstants.HARValue: element.value]
        }

        requestHAR[HARConstants.HARQueryString] = HARQueryParameters

        // post data
        if let requestPostData = httpBody, !requestPostData.isEmpty {
            let postDataText = String(data: requestPostData, encoding: .utf8) ?? ""
            let postData = [HARConstants.HARText: postDataText,
                            HARConstants.HARMIMEType: "application/octet-stream"]
            requestHAR[HARConstants.HARPostData] = postData
        }

        // body size
        requestHAR[HARConstants.HARBodySize] = httpBody?.count ?? 0

        return requestHAR
    }
}
