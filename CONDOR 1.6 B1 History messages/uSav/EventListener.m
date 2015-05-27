//
//  EventListener.m
//  atloco
//
//  Created by liudian on 10-7-4.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EventListener.h"
#import "HTTPHelper.h"
#import "USAVClient.h"
#import "API.h"

@implementation EventListener

//@synthesize httpHelper;
@synthesize url;
@synthesize delegate;

/*
-(void)recvJson:(NSDictionary*)obj {
	NSLog(@"event=%@", obj);
	
    if ((nil != obj) && (nil != delegate)) {
        [delegate eventListener:self event:obj];
	}   
    
    [self loop];
}

-(void)loop {
        [[DNGClient current].api call:url target:self selector:@selector(recvJson:)];
}

-(EventListener*)initWithURL:(NSString*)u {
	if (self = [super init]) {
		self.url = u;
		[self loop];
	}
	return self;
}
*/

-(void)eventListenLoop {
    dispatch_queue_t downloadQueue = dispatch_queue_create("EventListenLoop", NULL);
    dispatch_async(downloadQueue, ^{
        while (_continueToListen == TRUE) {   
            NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
            NSURLResponse *resp = nil;
            NSError *err = nil;
            NSData *eventData = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &err];
            dispatch_async(dispatch_get_main_queue(), ^{                    
                if (resp == nil) {
                    if (err != nil) {
                        NSLog(@"eventListenLoop: error:  url:%@ error_desc:%@ ", self.url, [err localizedDescription]);
                    }
                }
                if ((nil != eventData)  && (nil != delegate)) {
                    NSString *str = [[NSString alloc] initWithData:eventData encoding:NSUTF8StringEncoding];
                    NSDictionary *eventObj = [JSONUtil stringToObject:str];
                    [delegate eventListener:self event:eventObj];
                }           
            });
        }
    });
    // dispatch_release(downloadQueue);
}

-(EventListener*)initWithURL:(NSString*)u {
	if (self = [super init]) {
		self.url = u;
        _continueToListen = TRUE;
		[self eventListenLoop];
	}
	return self;
}

-(void)stopToListen {
    _continueToListen = FALSE;
}


@end
