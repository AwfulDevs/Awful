//  WebArchive.swift
//
//  Copyright 2014 Awful Contributors. CC BY-NC-SA 3.0 US https://github.com/Awful/Awful.app

import Foundation
import Smileys

class WebArchive {
    private let plist: NSDictionary
    private lazy var subresourcesByURL: [String:[String:AnyObject]] = { [unowned self] in
        var subresourcesByURL = [String:[String:AnyObject]]()
        for resource in self.plist["WebSubresources"] as [[String:AnyObject]] {
            let URL = resource["WebResourceURL"]! as String
            subresourcesByURL[URL] = resource
        }
        return subresourcesByURL
        }()
    
    required init(URL: NSURL) {
        let stream = NSInputStream(URL: URL)
        stream.open()
        var error: NSError?
        let plist = NSPropertyListSerialization.propertyListWithStream(stream, options: 0, format: nil, error: &error) as NSDictionary!
        assert(plist != nil, "error loading webarchive at \(URL): \(error)")
        self.plist = plist
    }
    
    var mainFrameHTML: String {
        get {
            let mainResource = plist["WebMainResource"] as NSDictionary
            let data = mainResource["WebResourceData"] as NSData
            return NSString(data: data, encoding: NSUTF8StringEncoding)
        }
    }
    
    func dataForSubresourceWithURL(URL: String) -> NSData? {
        return subresourcesByURL[URL]?["WebResourceData"] as NSData?
    }
}

class WebArchiveSmileyDownloader: SmileyDownloader {
    let archive: WebArchive
    
    init(_ archive: WebArchive) {
        self.archive = archive
    }
    
    func downloadImageDataFromURL(URL: NSURL, completionBlock: (imageData: NSData!, error: NSError!) -> Void) {
        let imageData = archive.dataForSubresourceWithURL(URL.absoluteString!)
        let error: NSError? = imageData == nil ? NSError(domain: "SmileyErrorDomain", code: 2, userInfo: nil) : nil
        completionBlock(imageData: imageData, error: error)
    }
}
