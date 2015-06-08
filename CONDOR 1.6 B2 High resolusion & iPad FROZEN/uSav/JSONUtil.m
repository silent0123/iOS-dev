//
//  JSONUtil.m
//  atloco
//
//  Created by liudian on 10-7-4.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "JSONUtil.h"
#import "JSON.h"

static SBJSON *json = nil;
@implementation JSONUtil

+ (NSDictionary*)stringToObject:(NSString*)string {
	if (nil == json) {
		json = [SBJSON new];
	}
	return [json objectWithString:string];
}
+ (NSString*)objectToString:(NSDictionary*)object {
	if (nil == json) {
		json = [SBJSON new];
	}
	return [json stringWithObject:object];
}
@end
