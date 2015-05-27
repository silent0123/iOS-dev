//
//  HTTPHelperDelegate.h
//  QuickPoll
//
//  Created by dennis young on 10/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef QuickPoll_HTTPHelperDelegate_h
#define QuickPoll_HTTPHelperDelegate_h

@class HTTPHelper;

@protocol HTTPHelperDelegate
-(void)httpHelper:(HTTPHelper*)hh data:(NSData*)data contentType:(NSString*)ct;
-(void)httpHelper:(HTTPHelper*)hh error:(NSString*)msg;
-(void)httpHelper:(HTTPHelper*)hh httpResponseError:(int)httpErrorCode;
@end


#endif
