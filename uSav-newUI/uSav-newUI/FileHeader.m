//
//  FileHeader.m
//  RandomPossessions
//
//  Created by NWHKOSX49 on 20/11/12.
//  Copyright (c) 2012 nwStor. All rights reserved.
//

#import "FileHeader.h"

@implementation FileHeader

@synthesize lenInByte, endian;

- (id)initWithHeaderLen:(int) len
                 endian: (int) mode
{
    self = [super init];
    
    if (self)
    {
        [self setLenInByte:len];
        [self setEndian:mode];
    }
    
    return self;
}

- (id)initWithHeaderLen:(int)len
{
    return [self initWithHeaderLen:len endian:1];
}

-(id)init
{
    return [self initWithHeaderLen:1024 endian:1];
}

@end
