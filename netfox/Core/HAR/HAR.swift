//
//  HAR.swift
//  netfox_ios
//
//  Created by Nagy Ádám on 2018. 09. 17..
//  Copyright © 2018. kasketis. All rights reserved.
//

import Foundation.NSHTTPCookie
import UIKit

let DEBUG_TIMING = false

class HAR {
    // returns a new HAR dictionary populated with Creator and Browser entries
    // and including an empty mutable Entries array
    static var HAR: [String: Any] {
        var log: [String: Any] = ["1.2": HARConstants.HARVersion]

        // retrieve the app name and version from the main bundle to put in the HAR Creator record.
        guard
            let infoDictionary = Bundle.main.infoDictionary,
            let bundleDisplayName = infoDictionary["CFBundleDisplayName"],
            let bundleVersion = infoDictionary["CFBundleVersion"]
        else {
            return [:]
        }

        // put datas to the HAR Creator record.
        let HARCreator: [String: Any] = [
            HARConstants.HARName: bundleDisplayName,
            HARConstants.HARVersion: bundleVersion
        ]

        // use "UIWebView" and the current OS version for the HAR Browser record
        // TODO(marq) support optional browser name
        let HARBrowser: [String: Any] = [
            HARConstants.HARName: "UIWebView",
            HARConstants.HARVersion: UIDevice.current.systemVersion
        ]

        log[HARConstants.HARCreator] = HARCreator
        log[HARConstants.HARBrowser] = HARBrowser

        // create an empty (but mutable) array for HAR entries.
        log[HARConstants.HAREntries] = []


        // At this point the dictionary is a valid HAR log when transformed to JSON.
        return log
    }

    // Creates a HAR page dictionary with an id of |pageId| and a title of |title|,
    // and a boilerplate pageTimings value with -1s for both OnLoad and
    // OnContentLoad
    static func HARPage(with pageId: String, title: String, pageProperties: [String: Any]) -> [String: Any] {
        let pageTimings = [
            HARConstants.HAROnContentLoad:
            HARConstants.HARUnknownTimeInterval
        ]

        var result: [String: Any] = [
            HARConstants.HARStarted: Date().ISO8601Representation,
            HARConstants.HARId: pageId,
            HARConstants.HARTitle: title,
            HARConstants.HARPageTimings: pageTimings
        ]

        for element in pageProperties {
            result[element.key] = element.value
        }

        return result
    }

    // For debugging: walks through the entries in |HAR| and validates that they
    // contain responses and send and wait timings. Exceptions are logged to the
    // console.
    static func HARAudit(_ HAR: [String: Any]) {
        guard let entries = HAR[HARConstants.HAREntries] as? Array<[String: Any]> else {
            return
        }

        for (idx, entry) in entries.enumerated() {
            let response = entry[HARConstants.HARResponse] as? [String: Any]
            let request = entry[HARConstants.HARRequest] as? [String: Any]
            let timings = entry[HARConstants.HARTimings] as? [String: Any]

            let url = request?[HARConstants.HARURL] ?? "missing url"

            // does the entry have a response?
            if (response == nil) {
                print("Entry \(idx) for \(url) missing response")
            }

            // does the entry have a timings record?
            if let _timings = timings {
                let redirectUrl = request?[HARConstants.HARRedirectURL] ?? "missing redirect url"

                if (_timings[HARConstants.HARSend] == nil) {
                    print("Timings \(idx) for \(redirectUrl) missing send")
                }

                if (_timings[HARConstants.HARWait] == nil) {
                    print("Timings \(idx) for \(redirectUrl) missing send")
                }
            } else {
                print("Entry \(idx) for \(url) missing timings")
            }
        }
    }

    // Returns an array of HAR HTTP cookie structures corresponding to the
    // contents of |cookies|. |cookies| is expected to be an array containing only
    // NSHTTPCookie objects.
    typealias HARCookie = [String: Any]
    static func HARCookiesFromCookieArray(_ cookies: [HTTPCookie]) -> [HARCookie] {
        let HARCookies: [HARCookie] = cookies.map { cookie -> HARCookie in
            let expiresDate = cookie.expiresDate?.ISO8601Representation ?? Date().ISO8601Representation
            let HARCookie: HARCookie = [
                HARConstants.HARName: cookie.name,
                HARConstants.HARValue: cookie.value,
                HARConstants.HARPath: cookie.path,
                HARConstants.HARDomain: cookie.domain,
                HARConstants.HARExpires: expiresDate,
                HARConstants.HARHTTPOnly: cookie.isHTTPOnly,
            ]
            return HARCookie
        }

        return HARCookies
    }

    // Given a dictionary of name-value pairs (|headers|) which correspond to
    // HTTP request or response headers, update the HAR request or response structure
    // |HAR| by adding a Headers array of HAR headers structures, and adding a
    // headersSize value corresponding to the totaly bytes of header data implied
    // by |headers|
    //
    // Note that if |DEBUG_TIMING| is true, the header array that's added to |HAR|
    // is always empty
    typealias HARHeader = [String: String]
    static func addHARHeadersFromDictionary(headers: [String: String], toHAR HAR: inout [String: Any]) {
        var headerBytes: Int = 0
        var HARHeaders: [HARHeader] {
            return headers.map { header in
                // Since the header has already been parsed for us, we assume that it was
                // formatted with a colon and space after the name (two bytes) and
                // a CRLF after the value (two more bytes)
                headerBytes += header.key.lengthOfBytes(using: .utf16)
                headerBytes += header.value.lengthOfBytes(using: .utf16)

                return [HARConstants.HARName: header.key,
                        HARConstants.HARValue: header.value]
            }
        }

        headerBytes += 2 // final CR LF

        if DEBUG_TIMING {
            HAR[HARConstants.HARHeaders] = []
        } else {
            HAR[HARConstants.HARHeaders] = HARHeaders
        }

        HAR[HARConstants.HARHeadersSize] = headerBytes
    }

    static func generateWithModelObjects(modelObjects: [NFXHTTPModel]) -> URL? {
        let harVersion = "1.2"

        // creator
        let creator = [
            HARConstants.HARName: "Netfox",
            HARConstants.HARVersion: "2.0.0",
            HARConstants.HARComment: "TODOO:"
        ]

        // browser
        let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] ?? "missing bundle name"
        let shortVersionKey = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
        let versionKey = (Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String) ?? ""
        let versionNumber = String(format: "%@ (%@)", shortVersionKey, versionKey)
        let appNameVersionCombined = "\(appName) \(versionNumber)"
        let browser = [HARConstants.HARName: appName,
                       HARConstants.HARVersion: versionNumber]

        // pages
        let pages: [[String: Any]] = [[
            HARConstants.HARStarted: modelObjects.last?.requestDate?.ISO8601Representation ?? Date().ISO8601Representation,
            HARConstants.HARId: appNameVersionCombined,
            HARConstants.HARTitle: appNameVersionCombined,
            HARConstants.HARPageTimings: [
                HARConstants.HAROnContentLoad: 0.0,
                HARConstants.HAROnLoad: 0.0
            ]]
        ]

        // entries
        typealias HAREntry = [String: Any]
        let entries: [HAREntry] = modelObjects.map { model in
            let seconds = (model.responseDate ?? Date()).timeIntervalSince(model.requestDate ?? Date())
            let wait = seconds / 1000.0

            let timings: [String: Double] = [
                HARConstants.HARBlocked: -1.0,
                HARConstants.HARDNS: -1.0,
                HARConstants.HARConnect: -1.0,
                HARConstants.HARSend: -1.0,
                HARConstants.HARWait: (wait),
                HARConstants.HARReceive: -1.0,
                HARConstants.HARSSL: -1.0
            ]

            let anEntry: HAREntry = [
                HARConstants.HARPageRef: appNameVersionCombined,
                HARConstants.HARStarted: (model.requestDate ?? Date()).ISO8601Representation,
                HARConstants.HARTime: wait,
                HARConstants.HARRequest: model.HARRequest ?? [:],
                HARConstants.HARResponse: model.HARresponse ?? [:],
                HARConstants.HARCache: ["": ""],
                HARConstants.HARTimings: timings
            ]

            return anEntry
        }

        let resultDictionary = [
            HARConstants.HARLog: [
                HARConstants.HARVersion: harVersion,
                HARConstants.HARCreator: creator,
                HARConstants.HARBrowser: browser,
                HARConstants.HARPages: pages,
                HARConstants.HAREntries: entries
            ]
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: resultDictionary,
                                                      options: JSONSerialization.WritingOptions.prettyPrinted)
            let resultString = String(data: jsonData, encoding: .utf8) ?? "wrong string"

            print("👉\(resultString)👈")

            let fileName = String(format: "%@ %@.har", appNameVersionCombined, Date().description)
            let filePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                .first as NSString?)?.appendingPathComponent(fileName) ?? ""
            try resultString.write(toFile: filePath, atomically: true, encoding: .utf8)
            let filePathURL = URL(fileURLWithPath: filePath)
            return filePathURL
        } catch {
            return nil
        }
    }
}
