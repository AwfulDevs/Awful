//  SmileyKeyboardViewController.swift
//
//  Copyright 2014 Awful Contributors. CC BY-NC-SA 3.0 US https://github.com/Awful/Awful.app

import CoreData
import Smileys
import UIKit

class SmileyKeyboardViewController: UIInputViewController {

    private var nextKeyboardButton: UIButton!
    private var keyboardView: SmileyKeyboardView!
    private var dataStack: SmileyDataStack!
    private var imageDatas: [NSData]!

    override func updateViewConstraints() {
        super.updateViewConstraints()
    
        // Add custom view sizing constraints here
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataStack = SmileyDataStack()
        let fetchRequest = NSFetchRequest(entityName: "Smiley")
        fetchRequest.resultType = .DictionaryResultType
        fetchRequest.propertiesToFetch = ["imageData"]
        fetchRequest.fetchLimit = 100
        var error: NSError?
        let results = dataStack.managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as [NSDictionary]!
        assert(results != nil, "error fetching image data: \(error)")
        imageDatas = results.map{ $0["imageData"] as NSData }
        
        keyboardView = SmileyKeyboardView(frame: CGRectZero)
        keyboardView.delegate = self
        keyboardView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(keyboardView)
        
        let views = ["keyboard": keyboardView]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[keyboard]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[keyboard]|", options: nil, metrics: nil, views: views))
    
        // Perform custom UI setup here
        self.nextKeyboardButton = UIButton.buttonWithType(.System) as UIButton
    
        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), forState: .Normal)
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    
        self.nextKeyboardButton.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(self.nextKeyboardButton)
    
        var nextKeyboardButtonLeftSideConstraint = NSLayoutConstraint(item: self.nextKeyboardButton, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0.0)
        var nextKeyboardButtonBottomConstraint = NSLayoutConstraint(item: self.nextKeyboardButton, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        self.view.addConstraints([nextKeyboardButtonLeftSideConstraint, nextKeyboardButtonBottomConstraint])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    override func textDidChange(textInput: UITextInput) {
        // The app has just changed the document's contents, the document context has been updated.
    
        var textColor: UIColor
        var proxy = self.textDocumentProxy as UITextDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
            textColor = UIColor.whiteColor()
        } else {
            textColor = UIColor.blackColor()
        }
        self.nextKeyboardButton.setTitleColor(textColor, forState: .Normal)
    }

}

extension SmileyKeyboardViewController: SmileyKeyboardViewDelegate {
    func smileyKeyboard(keyboardView: SmileyKeyboardView, numberOfKeysInSection section: Int) -> Int {
        return imageDatas.count
    }
    
    func smileyKeyboard(keyboardView: SmileyKeyboardView, imageDataForKeyAtIndexPath indexPath: NSIndexPath) -> NSData {
        return imageDatas[indexPath.item]
    }
}
