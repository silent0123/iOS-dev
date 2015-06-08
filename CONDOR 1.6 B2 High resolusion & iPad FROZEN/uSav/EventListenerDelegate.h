//
//  EventListenerDelegate.h
//  atloco
//
//  Created by liudian on 10-7-6.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EventListener;

@protocol EventListenerDelegate
- (void)eventListener:(EventListener*)el event:(NSDictionary*)event;

@end
