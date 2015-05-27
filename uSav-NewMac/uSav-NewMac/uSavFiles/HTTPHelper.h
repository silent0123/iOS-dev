//
//  HTTPHelper.h
//  QuickPoll
//
//  Created by dennis young on 10/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPHelperDelegate.h"

@interface HTTPHelper : NSObject {
	NSMutableData *dataBuffer;
}

@property (nonatomic, strong) NSString *responseContentType;
@property (nonatomic, strong) id<HTTPHelperDelegate> delegate;

- (void) get: (NSString*)url;
- (void) post: (NSString*)url data:(NSData*)data contentType:(NSString*)contentType;
- (void) put: (NSString*)url data:(NSData*)data contentType:(NSString*)contentType;
- (void) del: (NSString*)url;
- (HTTPHelper*) initWithDelegate:(id)del;

@end
   