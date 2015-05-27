//
//  NSArray+Helpers.m
//  mystar
//
//  Created by mos on 13-2-22.
//  Copyright (c) 2013年 medev. All rights reserved.
//

#import "NSArray+Helpers.h"

@implementation NSArray (Utility)

- (id)objectForIndexNotNull:(NSInteger)index {
    id object = [self objectAtIndex:index];
    if (object == [NSNull null])
        return @"N/A";
    return object;
}

@end
