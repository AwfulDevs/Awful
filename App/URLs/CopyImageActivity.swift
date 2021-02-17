//  CopyImageActivity.swift
//
//  Copyright 2014 Awful Contributors. CC BY-NC-SA 3.0 US https://github.com/Awful/Awful.app

import UIKit

final class CopyImageActivity: UIActivity {
    fileprivate var data: Data!
    fileprivate var url: URL!
    fileprivate var filetype: String!
    
   override init () {

    }
  
    // MARK: UIActivity
    override var activityType: UIActivity.ActivityType {
        return UIActivity.ActivityType("com.awfulapp.Awful.CopyImage")
    }
    override class var activityCategory: UIActivity.Category {
        return .action
    }
    override var activityTitle: String? {
        return LocalizedString("link-action.copy-image")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        var hasData = Bool(false)
        var hasURL = Bool(false)
        for activityItem in activityItems {
           if let data = activityItem as? Data {
            self.data = data
            hasData = true
           }
           else if let url = activityItem as? URL {
            self.url = url
            hasURL = true
        }
    }
        if (hasData && hasURL){
            return true
        } else {
            return false
        }
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        self.filetype = getFileTypeFromURL(self.url)!
    }
    
    // would like to get proper filetypes in a future version, but trusting file extension for now
    // png seems to work for anything not-gif
    fileprivate func getFileTypeFromURL(_ url: URL) -> String? {
        switch (url.path.lowercased()) {
        case let (path) where path.hasSuffix("gif"):
            return "com.compuserve.gif"
        default:
            return "public.png"
        }
    }

    override func perform() {
        UIPasteboard.general.setData(self.data as Data, forPasteboardType: self.filetype)
        activityDidFinish(true)
    }
}
