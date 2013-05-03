//
//  AwfulPocketHelper.h
//  Awful
//
//  Created by Simon Frost on 03/05/2013.
//  Copyright (c) 2013 Awful Contributors. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AwfulPocketHelper : NSObject

+ (BOOL) isLoggedIn;
+ (void) attemptToSaveURL:(NSURL*)url;

@end
