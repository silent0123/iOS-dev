//
//  EventListener.h
//  atloco
//
//  Created by liudian on 10-7-4.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPHelperDelegate.h"
#import "EventListenerDelegate.h"

@interface EventListener : NSObject {
    BOOL _continueToListen;
}
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) id<EventListenerDelegate> delegate;
-(EventListener*)initWithURL:(NSString*)u;
-(void)eventListenLoop;
-(void)stopToListen;
@end
