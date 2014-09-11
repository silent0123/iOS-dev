//
//  APICall.h
//  QuickPoll
//
//  Created by dennis young on 10/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPHelperDelegate.h"

@class HTTPHelper;

@interface APICall : NSObject <HTTPHelperDelegate> {
	
	id _target;
	SEL _sel;
}

@property (nonatomic) BOOL convertToJson;
@property (nonatomic, strong) HTTPHelper *httpHelper;
@property (nonatomic, strong) id context;

-(APICall*)initWithTarget:(id)target selector:(SEL)sel;
-(void)httpHelper:(HTTPHelper*)hh data:(NSData*)data contentType:(NSString*)ct;
-(void)httpHelper:(HTTPHelper*)hh httpResponseError:(int)httpErrorCode;
-(void)httpHelper:(HTTPHelper*)hh error:(NSString*)msg;

@end
