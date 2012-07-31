//
//  AwfulHTTPClient+PrivateMessages.h
//  Awful
//
//  Created by me on 7/23/12.
//  Copyright (c) 2012 Regular Berry Software LLC. All rights reserved.
//

#import "AwfulHTTPClient.h"
#import "AwfulDraft.h"

typedef void (^PrivateMessagesListResponseBlock)(NSMutableArray *messages);

@interface AwfulHTTPClient (PrivateMessages)

-(NSOperation *)privateMessageListOnCompletion:(PrivateMessagesListResponseBlock)PMListResponseBlock 
                                       onError:(AwfulErrorBlock)errorBlock;

-(NSOperation *)sendPrivateMessage:(AwfulDraft*)draft onCompletion:(CompletionBlock)completionBlock onError:(AwfulErrorBlock)errorBlock;
@end
