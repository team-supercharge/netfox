//
//  URLResponse+HAR.swift
//  netfox_ios
//
//  Created by Nagy Ádám on 2018. 09. 18..
//  Copyright © 2018. kasketis. All rights reserved.
//

import Foundation

let INCLUDE_RESPONSE_BODY = true

extension URLResponse {
    var HARRepresentation: HARType {
        var responseHAR: HARType = [:]
        var HARCookies: [Any] = []

        // Sometimes (for example from a data: URL) we just get an NSURLResponse, not
        // a full NSHTTPURLResponse. Only the latter has status codes and headers.
        if !DEBUG_TIMING && self is HTTPURLResponse {
            let statusCode = (self as? HTTPURLResponse)?.statusCode ?? 0
            responseHAR[HARConstants.HARStatus] = statusCode

            let statusText = HTTPURLResponse.localizedString(forStatusCode: statusCode)
            responseHAR[HARConstants.HARStatusText] = statusText

            if let headers = (self as? HTTPURLResponse)?.allHeaderFields as? [String: String], let url = url {
                HAR.addHARHeadersFromDictionary(headers: headers, toHAR: &responseHAR)

                // derive cookies from headers
                let responseCookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: url)

                HARCookies = HAR.HARCookiesFromCookieArray(responseCookies)
            }
        } else {
            // Status code is mandatory in HAR, so we'll assume any non-HTTP responses
            // were sucessful
            responseHAR[HARConstants.HARStatus] = 200
            responseHAR[HARConstants.HARStatusText] = "OK"
            // set an empty array for the headers
            responseHAR[HARConstants.HARHeaders] = []
            // and we say the headers were zero bytes
            responseHAR[HARConstants.HARHeadersSize] = 0
        }

        // TODO(marq) find a way to determine this authoritatively
        responseHAR[HARConstants.HARHTTPVersion] = "HTTP/1.1"

        responseHAR[HARConstants.HARCookies] = HARCookies

        // TODO(marq) correctly populate this
        responseHAR[HARConstants.HARRedirectURL] = ""

        return responseHAR
    }

    func HARRepresentation(with data: Data) -> HARType {
        var HAR = HARRepresentation
        var contentLength = data.count

        if data.isEmpty, let response = self as? HTTPURLResponse {
            let contentLenghtValue = response.allHeaderFields["Content-Length"] as? String ?? ""
            contentLength = (contentLenghtValue as NSString).integerValue
        }

        HAR[HARConstants.HARBodySize] = contentLength

        var contentText = ""

        if INCLUDE_RESPONSE_BODY {
            contentText = String(data: data, encoding: .utf8) ?? ""
        } else {
            contentText = "(body suppressed)"
        }

        let HARContent: HARType = [HARConstants.HARSize: contentLength,
                                   HARConstants.HARMIMEType: mimeType ?? "missing MIME type",
                                   HARConstants.HARText: contentText]
        HAR[HARConstants.HARContent] = HARContent

        return HAR
    }
}
