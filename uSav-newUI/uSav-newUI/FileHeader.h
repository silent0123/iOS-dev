//
//  FileHeader.h
//  RandomPossessions
//
//  Created by NWHKOSX49 on 20/11/12.
//  Copyright (c) 2012 nwStor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileHeader : NSObject
{
}

@property (nonatomic) int lenInByte;
//o for big, 1 for small
@property (nonatomic) int endian;

- (id)initWithHeaderLen:(int) len
                 endian: (int) mode;

- (id)initWithHeaderLen:(int)len;

@end
