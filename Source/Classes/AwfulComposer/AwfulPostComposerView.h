//
//  AwfulPostComposerView.h
//  Awful
//
//  Created by me on 5/7/12.
//  Copyright (c) 2012 Regular Berry Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AwfulPostComposerView : UITextView {
    @protected
    UIWebView *_webView;
}

-(void) bold;
-(void) italic;
-(void) underline;
-(void) format:(NSString*)format;

@property (nonatomic, readonly) NSString* html;
@property (nonatomic, readonly) NSString* bbcode;

@end
