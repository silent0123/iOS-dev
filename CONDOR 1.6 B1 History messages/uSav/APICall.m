//
//  APICall.m
//  QuickPoll
//
//  Created by dennis young on 10/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "APICall.h"
#import "HTTPHelper.h"
#import "JSONUtil.h"

@implementation APICall
@synthesize httpHelper;
@synthesize convertToJson;
@synthesize context;
-(void)httpHelper:(HTTPHelper*)hh data:(NSData*)data contentType:(NSString*)ct {
	if (convertToJson) {
		NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		
        // NSDictionary *obj = [JSONUtil stringToObject:str];
        
        // DY: temp fix to add non json data to an obj to make consistent for upper level
        NSDictionary *obj;
        obj = [JSONUtil stringToObject:str];
        if ((obj == nil) && (str != nil)) {
            obj = [NSDictionary dictionaryWithObjectsAndKeys:str, @"rawStringStatus", nil];
        }
        
        // the following alloc causes a crash, need to use mutableCopy instead, maybe ios5 thing
		//NSMutableDictionary *clone = [[NSMutableDictionary alloc] initWithDictionary:obj];
        NSMutableDictionary *clone = [obj mutableCopy];
        
		if (self.context != nil) {
			[clone setObject:self.context forKey:@"context"];
		}
		
		[_target performSelector:_sel withObject:clone];
	}
	else {
		if (self.context != nil) {
			[_target performSelector:_sel withObject:data withObject:self.context];
		}
		else {
			[_target performSelector:_sel withObject:data];
		}
	}
}

-(void)httpHelper:(HTTPHelper*)hh httpResponseError:(NSInteger)httpErrorCode {
    NSDictionary *errDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:httpErrorCode] forKey:@"httpErrorCode"];
	// [_target performSelector:_sel withObject:nil];
    [_target performSelector:_sel withObject:errDict];
	//NSLog(@"httpHelper: httpErrorCode: %zi", httpErrorCode);
    errDict = nil;
}

-(void)httpHelper:(HTTPHelper*)hh error:(NSString*)msg {
	[_target performSelector:_sel withObject:nil];
	//NSLog(@"httpHelper: error in APICall %@", msg);
}

-(APICall*)initWithTarget:(id)target selector:(SEL)sel {
	if (self = [super init]) {
		convertToJson = YES;
		httpHelper = [[HTTPHelper alloc] initWithDelegate:self];
		_target = target;
		_sel = sel;
	}
	return self;
}

@end