//
//  HARConstants.swift
//  netfox_ios
//
//  Created by Nagy Ádám on 2018. 09. 17..
//  Copyright © 2018. kasketis. All rights reserved.
//

import Foundation

enum HARConstants {
    static let HARLog = "log"
    static let HARVersion = "version"
    static let HARCreator = "creator"
    static let HARBrowser = "browser"
    static let HARPages   = "pages"
    static let HAREntries = "entries"
    static let HARComment = "comment"
    static let HARName    = "name"
    static let HARStarted = "startedDateTime"
    static let HARId      = "id"
    static let HARTitle   = "title"
    static let HARPageTimings = "pageTimings"
    static let HAROnContentLoad = "onContentLoad"
    static let HAROnLoad   = "onLoad"
    static let HARPageRef  = "pageref"
    static let HARTime     = "time"
    static let HARRequest  = "request"
    static let HARResponse = "response"
    static let HARCache    = "cache"
    static let HARTimings  = "timings"
    static let HARServerIPAddress = "serverIPAddress"
    static let HARConnection = "connection"
    static let HARMethod   = "method"
    static let HARURL      = "url"
    static let HARHTTPVersion = "httpVersion"
    static let HARCookies  = "cookies"
    static let HARHeaders  = "headers"
    static let HARQueryString = "queryString"
    static let HARPostData = "postData"
    static let HARHeadersSize = "headersSize"
    static let HARBodySize = "bodySize"
    static let HARStatus   = "status"
    static let HARStatusText = "statusText"
    static let HARContent  = "content"
    static let HARRedirectURL = "redirectURL"

    // cookies
    static let HARValue = "value"
    static let HARPath  = "path"
    static let HARDomain = "domain"
    static let HARExpires = "expires"
    static let HARHTTPOnly = "httpOnly"
    static let HARSecure = "secure"

    // post data
    static let HARMIMEType = "mimeType"
    static let HARParams   = "params"
    static let HARText     = "text"
    static let HARFileName = "fileName"
    static let HARContentType = "contentType"

    // content
    static let HARSize = "size"
    static let HARCompression = "compression"
    static let HAREncoding = "encoding"

    // cache
    static let HARBeforeRequest = "beforeRequest"
    static let HARAfterRequest = "afterRequest"
    static let HARLastAccess = "lastAccess"
    static let HAReTag = "eTag"
    static let HARHitCount = "hitCount"

    // timings
    static let HARBlocked = "blocked"
    static let HARDNS = "dns"
    static let HARConnect = "connect"
    static let HARSend = "send"
    static let HARWait = "wait"
    static let HARReceive = "receive"
    static let HARSSL = "ssl"

    // Any unknown time interval is represented by -1.
    static let HARUnknownTimeInterval: TimeInterval = -1

    // The HAR spec allows extensions so long as the extra data starts with an
    // underscore.  The following keys are used to add data outside the HAR spec.

    // We add an object _onloadByMethod to each page object, which holds the onload
    // time found using different methods.
    static let HAROnloadByMethod = "_onloadByMethod"
    static let HarOnloadUIWebViewCallback = "_UIWebviewCallback"
    static let HarOnloadInjectedJS = "_injectedJS"
}
