//
//  EventProcessor.m
//  atloco
//
//  Created by liudian on 10-7-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EventProcessor.h"
#import "USAVClient.h"
#import "APICall.h"
#import "HTTPHelper.h"
#import "API.h"
#import "JSONUtil.h"

@implementation EventProcessor

- (EventProcessor*) init {
	if (self = [super init]) {

	}
	return self;
}

/*
- (void)eventListener:(EventListener*)el event:(NSDictionary*)event {
	
	if ([[DNGClient current] delegate] != nil) {
		[[[DNGClient current] delegate] eventProcessor:self message:event];    
    }
}
*/ 

@end
