//
//  AwfulEditPostComposerViewController.m
//  Awful
//
//  Created by me on 1/8/13.
//  Copyright (c) 2013 Regular Berry Software LLC. All rights reserved.
//

#import "AwfulEditPostComposerViewController.h"

@implementation AwfulEditPostComposerViewController

- (void)editPost:(AwfulPost *)post text:(NSString *)text
{
    self.post = post;
    self.thread = nil;
    self.composerTextView.text = text;
    self.title = [post.thread.title stringByCollapsingWhitespace];
    self.navigationItem.titleLabel.text = self.title;
    self.sendButton.title = @"Save";
    self.images = [NSMutableDictionary new];
}


- (void)sendEdit:(NSString *)edit
{
    id op = [[AwfulHTTPClient client] editPostWithID:self.post.postID
                                                text:edit
                                             andThen:^(NSError *error)
             {
                 if (error) {
                     [SVProgressHUD dismiss];
                     [AwfulAlertView showWithTitle:@"Network Error" error:error buttonTitle:@"OK"];
                     return;
                 }
                 [SVProgressHUD showSuccessWithStatus:@"Edited"];
                 [self.delegate composerViewController:self didSend:self.post];
             }];
    self.networkOperation = op;
}
@end
