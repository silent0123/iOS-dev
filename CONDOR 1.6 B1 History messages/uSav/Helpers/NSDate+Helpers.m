//
//  NSDate+Helpers.m
//  mystar
//
//  Created by mos on 13-2-1.
//  Copyright (c) 2013年 medev. All rights reserved.
//

#import "NSDate+Helpers.h"

@implementation NSDate (Helpers)

+(NSString *)DateFromUnixMilliseconds:(long long)milliseconds{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    if(milliseconds == 0)
        return @"";
    return[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(milliseconds / 1000)]];
    
}
@end
